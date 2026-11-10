import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:serverpod/serverpod.dart';

import '../../../domain/exceptions.dart';
import '../../../domain/models/ranked_score.dart';
import '../../../domain/repositories/ranking_repository.dart';
import '../../../generated/protocol.dart' show ChallengeRevisionRow;
import '../mappers/play_mode_mapper.dart';

// Listと本人Getで同じ順位規則を使い、Listは索引順のまま100件で止める。
const _rankingOrder = 'b.score DESC, b.achieved_at ASC, b.user_profile_id ASC';
const _rankedScoresSql =
    '''
SELECT ROW_NUMBER() OVER (ORDER BY $_rankingOrder) AS rank,
  b.user_profile_id, p.nickname, b.score, b.achieved_at
FROM best_score b
JOIN user_profile p ON p.id = b.user_profile_id
WHERE b.revision_id = @revisionId AND b.mode = @mode
''';

/// integrationで実クエリのEXPLAINにも使う。
const listRankingSql = '$_rankedScoresSql ORDER BY $_rankingOrder LIMIT @limit';
const myRankingSql =
    'SELECT * FROM ($_rankedScoresSql) AS ranked '
    'WHERE user_profile_id = @profileId';

class SqliteRankingRepository(
  final DatabaseSession session, {
  final Transaction? transaction,
}) implements RankingRepository {
  @override
  Future<bool> publishedRevisionExists(int revisionId) async =>
      await ChallengeRevisionRow.db.count(
        session,
        where: (t) => t.id.equals(revisionId) & t.publishedAt.notEquals(null),
        transaction: transaction,
      ) >
      0;

  @override
  Future<List<RankedScore>> listTop({
    required int revisionId,
    required PlayMode mode,
    required int limit,
  }) async {
    if (limit < 1) throw ArgumentError.value(limit, 'limit');
    final result = await session.db.unsafeQuery(
      listRankingSql,
      parameters: QueryParameters.named({
        'revisionId': revisionId,
        'mode': playModeToRow(mode).name,
        'limit': limit,
      }),
      transaction: transaction,
    );
    return [for (final row in result) _fromRow(row)];
  }

  @override
  Future<RankedScore?> findMine({
    required int revisionId,
    required PlayMode mode,
    required int userProfileId,
  }) async {
    final result = await session.db.unsafeQuery(
      myRankingSql,
      parameters: QueryParameters.named({
        'revisionId': revisionId,
        'mode': playModeToRow(mode).name,
        'profileId': userProfileId,
      }),
      transaction: transaction,
    );
    return result.isEmpty ? null : _fromRow(result.single);
  }
}

RankedScore _fromRow(DatabaseResultRow row) {
  if (row.toColumnMap() case {
    'rank': final int rank,
    'user_profile_id': final int profileId,
    'nickname': final String nickname,
    'score': final int score,
    'achieved_at': final int milliseconds,
  }) {
    // Serverpod 4.1.1のSQLite encoderはDateTimeをepoch millisecondsで保存する。
    return RankedScore(
      rank: rank,
      userProfileId: profileId,
      nickname: nickname,
      score: score,
      achievedAt: DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      ),
    );
  }
  throw const CorruptedDataException(
    entity: 'best_score',
    field: 'ranking',
    message: 'ランキング行の型が不正です',
  );
}
