import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/play_session_repository.dart';
import '../../domain/repositories/shot_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../dto/play_result.dart';
import 'play_result_loader.dart';

/// テストが [GetPlaySession.execute] を差し替える。本番は null。
Future<PlayResult> Function(UuidValue authUserId, UuidValue playSessionId)?
getPlaySessionExecuteForTest;

/// 開始済みのプレイの現在状態を返す。
///
/// 所有者を必ず照合する（UUID は認証の代わりにならない）。他人のプレイは、相手の
/// 名前・版・結果を応答に含めず `notSessionOwner` にする。撮影済みなら [PlayResult.shot]
/// が入る。期限後も取得できる。開始済みの版は、公開が切り替わった後も使える。
class GetPlaySession(
  final ChallengeRepository _challenges,
  final PlaySessionRepository _sessions,
  final ShotRepository _shots,
  final UserProfileRepository _profiles,
) {
  Future<PlayResult> execute(
    UuidValue authUserId,
    UuidValue playSessionId,
  ) async {
    final replacement = getPlaySessionExecuteForTest;
    if (replacement != null) return replacement(authUserId, playSessionId);
    final profileId = (await _profiles.findByAuthUserId(authUserId))?.id;
    if (profileId == null) throw const PlayException(.profileNotInitialized);

    final session = await _sessions.findById(playSessionId);
    if (session == null) throw const PlayException(.sessionNotFound);
    if (session.userProfileId != profileId) {
      throw const PlayException(.notSessionOwner);
    }
    return loadPlayResult(session, challenges: _challenges, shots: _shots);
  }
}
