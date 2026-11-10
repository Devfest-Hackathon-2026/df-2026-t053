import 'dart:math' as math;

import '../generated/point_xz.dart';

/// 角度を [0, 360) に正規化する。-0 は 0 にする。
double normalizeYaw(double degrees) {
  // Dart の double の % は結果が 0 以上になる。
  final r = degrees % 360;
  // 負のごく小さい値は 360.0 に丸まるため、0 に戻す。
  if (r == 0 || r >= 360) return 0;
  return r;
}

/// 角度を [-180, 180) に正規化する。
double normalizeSigned(double degrees) => normalizeYaw(degrees + 180) - 180;

/// 2 つの yaw の差（0〜180 度）。向きは見ない。
double yawDiff(double a, double b) => (((a - b + 540) % 360) - 180).abs();

/// [from] から見た [to] の方位。北（−Z）が 0°、東（＋X）が 90°。
double bearingDegrees(PointXZ from, PointXZ to) {
  final dx = to.x - from.x;
  final dz = to.z - from.z;
  return normalizeYaw(math.atan2(dx, -dz) * 180 / math.pi);
}
