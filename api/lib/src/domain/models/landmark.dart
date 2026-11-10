/// 版に固定した会場図上の地点。表示座標と地理座標は別物。
class const Landmark({
  required final int id,
  required final int revisionId,
  required final int pavilionId,
  required final String displayName,
  required final double posX,
  required final double posZ,
  required final double? lat,
  required final double? lon,
});
