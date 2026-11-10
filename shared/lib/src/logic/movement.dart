import 'dart:math' as math;

import '../generated/point_xz.dart';

double _toRadians(double degrees) => degrees * math.pi / 180;

/// yaw の向きの前進ベクトル `(sin(yaw), -cos(yaw))`。北（0°）が −Z、東（90°）が ＋X。
PointXZ forwardVector(double yawDegrees) {
  final r = _toRadians(yawDegrees);
  return PointXZ(x: math.sin(r), z: -math.cos(r));
}

/// yaw の向きの右ベクトル `(cos(yaw), sin(yaw))`。
PointXZ rightVector(double yawDegrees) {
  final r = _toRadians(yawDegrees);
  return PointXZ(x: math.cos(r), z: math.sin(r));
}

/// 前後・左右の入力を合成し、長さを最大 1 に抑える。
///
/// 斜め入力で速くならないようにする。長さが 1 以下の入力はそのまま返す。
({double forward, double right}) combineInput(double forward, double right) {
  final length = math.sqrt(forward * forward + right * right);
  if (length <= 1) return (forward: forward, right: right);
  return (forward: forward / length, right: right / length);
}
