import '../../domain/models/models.dart';
import '../../domain/repositories/challenge_repository.dart';

/// テストが [ListChallenges.execute] を差し替える。本番は null。
Future<List<Challenge>> Function()? listChallengesExecuteForTest;

/// 公開中の出題を id の昇順で返す。提出版では最大 1 件（seed の公開処理が担保する）。
class ListChallenges(final ChallengeRepository _challenges) {
  Future<List<Challenge>> execute() {
    final replacement = listChallengesExecuteForTest;
    if (replacement != null) return replacement();
    return _challenges.listPublished();
  }
}
