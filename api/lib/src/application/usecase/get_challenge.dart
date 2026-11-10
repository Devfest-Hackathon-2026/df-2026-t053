import '../../domain/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/challenge_repository.dart';

/// 出題を返す。公開終了した出題は [Challenge.currentRevisionId] が null のまま返す。
/// 一度も公開されていない出題（下書きだけ）は、存在を公開しないよう、ない場合と同じにする。
class GetChallenge(final ChallengeRepository _challenges) {
  Future<Challenge> execute(int challengeId) async {
    if (challengeId <= 0) {
      throw const ChallengeException(.invalidRequest);
    }
    final challenge = await _challenges.findPublicById(challengeId);
    if (challenge == null) {
      throw const ChallengeException(.challengeNotFound);
    }
    return challenge;
  }
}
