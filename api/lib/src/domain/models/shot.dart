import 'package:uuid/uuid_value.dart';

/// 撮影の確定結果。書き換えない。[id] は保存前だけ null。
class const Shot({
  required final int? id,
  required final UuidValue requestId,
  required final UuidValue playSessionId,
  required final double x,
  required final double y,
  required final double z,
  required final double yawDeg,
  required final double pitchDeg,
  required final double fovDeg,
  required final double distanceM,
  required final double yawDiffDeg,
  required final double pitchDiffDeg,

  /// 0〜1000。
  required final int score,
  required final int rankAtSubmission,
  required final int bestScoreAtSubmission,
  required final String nicknameAtSubmission,
  required final DateTime bestAchieveTimeAtSubmission,
  required final DateTime createdAt,
});
