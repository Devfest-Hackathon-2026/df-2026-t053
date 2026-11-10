import 'dart:math' as math;

import '../generated/point_xz.dart';

/// 歩行領域の判定と検証が共有する、線分・多角形の基本演算。
/// 公開 API には含めない（`photohunt_shared.dart` から export しない）。

double cross(double ax, double az, double bx, double bz) => ax * bz - az * bx;

double _dot(double ax, double az, double bx, double bz) => ax * bx + az * bz;

/// 点 (px, pz) から線分 a→b までの最短距離。
double distancePointToSegment(
  double px,
  double pz,
  double ax,
  double az,
  double bx,
  double bz,
) {
  final abx = bx - ax;
  final abz = bz - az;
  final lengthSquared = abx * abx + abz * abz;
  if (lengthSquared == 0) return math.sqrt(_sq(px - ax) + _sq(pz - az));
  final t = (_dot(px - ax, pz - az, abx, abz) / lengthSquared).clamp(0.0, 1.0);
  return math.sqrt(_sq(px - (ax + abx * t)) + _sq(pz - (az + abz * t)));
}

double _sq(double v) => v * v;

int _orientation(PointXZ a, PointXZ b, PointXZ c) =>
    cross(b.x - a.x, b.z - a.z, c.x - a.x, c.z - a.z).sign.toInt();

bool _onSegment(PointXZ a, PointXZ b, PointXZ p) =>
    p.x >= math.min(a.x, b.x) &&
    p.x <= math.max(a.x, b.x) &&
    p.z >= math.min(a.z, b.z) &&
    p.z <= math.max(a.z, b.z);

/// 線分 a0→a1 と b0→b1 が（端点での接触・重なりを含めて）交わるか。
bool segmentsIntersect(PointXZ a0, PointXZ a1, PointXZ b0, PointXZ b1) {
  final o1 = _orientation(a0, a1, b0);
  final o2 = _orientation(a0, a1, b1);
  final o3 = _orientation(b0, b1, a0);
  final o4 = _orientation(b0, b1, a1);
  if (o1 != o2 && o3 != o4) return true;
  if (o1 == 0 && _onSegment(a0, a1, b0)) return true;
  if (o2 == 0 && _onSegment(a0, a1, b1)) return true;
  if (o3 == 0 && _onSegment(b0, b1, a0)) return true;
  if (o4 == 0 && _onSegment(b0, b1, a1)) return true;
  return false;
}

/// 2 本の線分の最短距離。交わるなら 0。
double distanceSegmentToSegment(
  PointXZ a0,
  PointXZ a1,
  PointXZ b0,
  PointXZ b1,
) {
  if (segmentsIntersect(a0, a1, b0, b1)) return 0;
  return math.min(
    math.min(
      distancePointToSegment(a0.x, a0.z, b0.x, b0.z, b1.x, b1.z),
      distancePointToSegment(a1.x, a1.z, b0.x, b0.z, b1.x, b1.z),
    ),
    math.min(
      distancePointToSegment(b0.x, b0.z, a0.x, a0.z, a1.x, a1.z),
      distancePointToSegment(b1.x, b1.z, a0.x, a0.z, a1.x, a1.z),
    ),
  );
}

/// 閉じた多角形 [ring]（終点から始点へ戻る辺を含む）の境界までの最短距離。
double distanceToRing(List<PointXZ> ring, double x, double z) {
  var best = double.infinity;
  for (var i = 0; i < ring.length; i++) {
    final a = ring[i];
    final b = ring[(i + 1) % ring.length];
    best = math.min(best, distancePointToSegment(x, z, a.x, a.z, b.x, b.z));
  }
  return best;
}

/// 偶奇則（ray casting）で多角形の内側か。境界上の扱いは呼び出し側で決める。
bool pointInPolygon(List<PointXZ> ring, double x, double z) {
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final a = ring[i];
    final b = ring[j];
    if ((a.z > z) != (b.z > z) &&
        x < (b.x - a.x) * (z - a.z) / (b.z - a.z) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}
