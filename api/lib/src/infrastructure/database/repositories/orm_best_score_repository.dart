// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;
import 'package:serverpod/serverpod.dart';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/best_score_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/best_score_mapper.dart';
import '../mappers/play_mode_mapper.dart';
import '../unique_violation.dart';

class OrmBestScoreRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements BestScoreRepository {
  @override
  Future<BestScore?> find(
    int userProfileId,
    int revisionId,
    PlayMode mode,
  ) async {
    final row = await _findRow(userProfileId, revisionId, mode);
    return row == null ? null : bestScoreFromRow(row);
  }

  Future<BestScoreRow?> _findRow(
    int userProfileId,
    int revisionId,
    PlayMode mode,
  ) {
    final persisted = playModeToRow(mode);
    return BestScoreRow.db.findFirstRow(
      _session,
      where: (t) =>
          t.userProfileId.equals(userProfileId) &
          t.revisionId.equals(revisionId) &
          t.mode.equals(persisted),
      transaction: _transaction,
    );
  }

  @override
  Future<BestScore> upsert(BestScore score) {
    return translateUniqueViolation(() async {
      final existing = await _findRow(
        score.userProfileId,
        score.revisionId,
        score.mode,
      );
      final BestScoreRow saved;
      if (existing == null) {
        saved = await BestScoreRow.db.insertRow(
          _session,
          bestScoreToRow(score),
          transaction: _transaction,
        );
      } else {
        saved = await BestScoreRow.db.updateRow(
          _session,
          existing.copyWith(
            shotId: score.shotId,
            score: score.score,
            achievedAt: score.achievedAt.toUtc(),
          ),
          columns: (t) => [t.shotId, t.score, t.achievedAt],
          transaction: _transaction,
        );
      }
      return bestScoreFromRow(saved);
    });
  }

  @override
  Future<List<BestScore>> listTop(
    int revisionId,
    PlayMode mode,
    int limit,
  ) async {
    final persisted = playModeToRow(mode);
    final rows = await BestScoreRow.db.find(
      _session,
      where: (t) => t.revisionId.equals(revisionId) & t.mode.equals(persisted),
      orderByList: (t) => [
        t.score.desc(),
        t.achievedAt.asc(),
        t.userProfileId.asc(),
      ],
      limit: limit,
      transaction: _transaction,
    );
    return rows.map(bestScoreFromRow).toList();
  }

  @override
  Future<int> rankOf({
    required int revisionId,
    required PlayMode mode,
    required int score,
    required DateTime achievedAt,
    required int userProfileId,
  }) async {
    final persisted = playModeToRow(mode);
    final at = achievedAt.toUtc();
    final ahead = await BestScoreRow.db.count(
      _session,
      where: (t) =>
          t.revisionId.equals(revisionId) &
          t.mode.equals(persisted) &
          ((t.score > score) |
              (t.score.equals(score) & (t.achievedAt < at)) |
              (t.score.equals(score) &
                  t.achievedAt.equals(at) &
                  (t.userProfileId < userProfileId))),
      transaction: _transaction,
    );
    return ahead + 1;
  }
}
