import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../dto/ranking_result.dart';
import 'ranking_access.dart';

class GetMyRankingEntry(
  final RankingRepository rankings,
  final UserProfileRepository profiles,
) {
  Future<RankingResult> execute(
    UuidValue authUserId,
    int revisionId,
    PlayMode mode,
  ) async {
    final profileId = await requireRankingProfile(
      rankings: rankings,
      profiles: profiles,
      authUserId: authUserId,
      revisionId: revisionId,
      mode: mode,
    );
    final row = await rankings.findMine(
      revisionId: revisionId,
      mode: mode,
      userProfileId: profileId,
    );
    if (row == null) throw const RankingException(.entryNotFound);
    return RankingResult(
      rank: row.rank,
      nickname: row.nickname,
      score: row.score,
      achieveTime: row.achievedAt,
      mine: true,
    );
  }
}
