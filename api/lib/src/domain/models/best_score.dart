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

/// 本人・版・モードごとの自己ベスト。[id] は保存前だけ null。
class const BestScore({
  required final int? id,
  required final int userProfileId,
  required final int revisionId,
  required final PlayMode mode,
  required final int shotId,
  required final int score,
  required final DateTime achievedAt,
});
