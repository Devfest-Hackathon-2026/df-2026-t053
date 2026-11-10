import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:uuid/uuid_value.dart';

import '../../domain/repositories/ranking_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../dto/ranking_result.dart';
import 'ranking_access.dart';

/// テストが [ListRankingEntries.execute] を差し替える。本番は null。
Future<List<RankingResult>> Function(
  UuidValue authUserId,
  int revisionId,
  PlayMode mode,
)?
listRankingEntriesExecuteForTest;

class ListRankingEntries(
  final RankingRepository rankings,
  final UserProfileRepository profiles,
) {
  Future<List<RankingResult>> execute(
    UuidValue authUserId,
    int revisionId,
    PlayMode mode,
  ) async {
    final replacement = listRankingEntriesExecuteForTest;
    if (replacement != null) {
      return replacement(authUserId, revisionId, mode);
    }
    final profileId = await requireRankingProfile(
      rankings: rankings,
      profiles: profiles,
      authUserId: authUserId,
      revisionId: revisionId,
      mode: mode,
    );
    final rows = await rankings.listTop(
      revisionId: revisionId,
      mode: mode,
      limit: 100,
    );
    return [
      for (final row in rows)
        RankingResult(
          rank: row.rank,
          nickname: row.nickname,
          score: row.score,
          achieveTime: row.achievedAt,
          mine: row.userProfileId == profileId,
        ),
    ];
  }
}
