import '../repositories/best_score_repository.dart';
import '../repositories/challenge_repository.dart';
import '../repositories/play_session_repository.dart';
import '../repositories/shot_repository.dart';
import '../repositories/user_profile_repository.dart';

/// 読み取りから撮影・自己ベストの保存までを同じ更新トランザクションで行う。
abstract interface class ShotTransaction() {
  Future<T> run<T>(Future<T> Function(ShotRepositories repositories) action);
}

class const ShotRepositories({
  required final ChallengeRepository challenges,
  required final PlaySessionRepository sessions,
  required final ShotRepository shots,
  required final UserProfileRepository profiles,
  required final BestScoreRepository bestScores,
});
