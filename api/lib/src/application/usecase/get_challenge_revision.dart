import '../../domain/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/challenge_repository.dart';

/// 公開済みの版を返す。現在公開中でない旧版も返す（開始できるかは play が判定する）。
///
/// 正解姿勢・解説は読まない（[ChallengeRevision.secrets] は null）。未公開の下書き版は、
/// 存在を公開しないよう、版がない場合と同じ [ChallengeFailure.revisionNotFound] にする。
class GetChallengeRevision(final ChallengeRepository _challenges) {
  Future<ChallengeRevision> execute(int revisionId) async {
    if (revisionId <= 0) {
      throw const ChallengeException(.invalidRequest);
    }
    final revision = await _challenges.findPublishedRevision(revisionId);
    if (revision == null) {
      throw const ChallengeException(.revisionNotFound);
    }
    return revision;
  }
}
