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

import '../models/models.dart';

abstract interface class BestScoreRepository() {
  Future<BestScore?> find(int userProfileId, int revisionId, PlayMode mode);

  /// `(user_profile_id, revision_id, mode)` の行を作る。あれば shot・score・
  /// achievedAt を置き換える。更新してよいか（自己ベストを超えたか）は呼び出し側が決める。
  Future<BestScore> upsert(BestScore score);

  /// 版・モード別の上位。score 降順 → achievedAt 昇順 → userProfileId 昇順。
  Future<List<BestScore>> listTop(int revisionId, PlayMode mode, int limit);

  /// 指定の (score, achievedAt, userProfileId) の順位（1 始まり）。
  /// 同じ並び順で、それより上にいる行の数に 1 を足す。
  Future<int> rankOf({
    required int revisionId,
    required PlayMode mode,
    required int score,
    required DateTime achievedAt,
    required int userProfileId,
  });
}
