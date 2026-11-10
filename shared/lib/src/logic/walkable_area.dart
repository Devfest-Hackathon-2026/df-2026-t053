import 'dart:math' as math;

import '../generated/point_xz.dart';
import '../generated/walkable_area.dart';
import 'segment_geometry.dart';

/// 境界付近の数値誤差として扱う長さ（1 mm）。
///
/// 出題の登録時検証と実行時の判定で、同じ値を使う。
const double kBoundaryEpsilonMeters = 0.001;

/// 穴の境界上かどうかを決める、浮動小数点の丸め誤差だけを吸収する値。
/// [clampMove] が止める位置は穴の境界の 1 mm 手前（斜めに近づくと境界までの
/// 垂直距離は 1 mm 未満）なので、穴には [kBoundaryEpsilonMeters] の許容を
/// 適用しない。許容を適用すると、止めた位置が禁止領域になってしまう。
const double _kExactEpsilon = 1e-12;

/// [clampMove] の結果。
class const MoveResult({
  /// 移動後の位置。
  required final PointXZ position,

  /// 境界で止められた（要求した移動を最後まで行えなかった）か。
  required final bool blocked,
});

bool _isFinitePoint(PointXZ p) => p.x.isFinite && p.z.isFinite;

/// [p] が歩行できる位置か。
///
/// - 外周の境界は許可する。数値誤差として [kBoundaryEpsilonMeters] だけ外側も許可する。
/// - 穴の内側と境界は禁止する。
bool isInsideWalkable(WalkableArea area, PointXZ p) {
  if (!_isFinitePoint(p)) return false;
  if (area.outer.length < 3) return false;
  final inOuter =
      pointInPolygon(area.outer, p.x, p.z) ||
      distanceToRing(area.outer, p.x, p.z) <= kBoundaryEpsilonMeters;
  if (!inOuter) return false;
  for (final hole in area.holes) {
    if (hole.length < 3) continue;
    if (pointInPolygon(hole, p.x, p.z) ||
        distanceToRing(hole, p.x, p.z) <= _kExactEpsilon) {
      return false;
    }
  }
  return true;
}

/// 1 フレームの移動 [from]→[to] を歩行領域で制限する。
///
/// 線分と境界の交点で区間を分け、許可領域から禁止領域へ変わる最初の交差の
/// [kBoundaryEpsilonMeters] 手前で止める。残りの移動は捨てる。
///
/// - 終点が許可領域内でも、途中で穴や凹部を横切る移動は止める。
/// - 外周の境界上から内側へ動く場合と、許可領域の中で境界に接するだけの場合は止めない。
/// - 結果が許可領域外になるときは [from] を返す。押し出しの補正はしない。
MoveResult clampMove(WalkableArea area, PointXZ from, PointXZ to) {
  MoveResult stay() => MoveResult(position: from, blocked: true);

  if (!_isFinitePoint(from) || !_isFinitePoint(to)) return stay();
  final dx = to.x - from.x;
  final dz = to.z - from.z;
  final length = math.sqrt(dx * dx + dz * dz);
  if (length == 0) return MoveResult(position: from, blocked: false);

  final ts = <double>[0, 1];
  for (final ring in [area.outer, ...area.holes]) {
    for (var i = 0; i < ring.length; i++) {
      _addCrossings(ts, from, dx, dz, ring[i], ring[(i + 1) % ring.length]);
    }
  }
  ts.sort();

  // 許可領域から禁止領域へ変わる最初の位置（線分上の割合）。
  double? stopT;
  for (var i = 0; i + 1 < ts.length; i++) {
    final t0 = ts[i];
    final t1 = ts[i + 1];
    if (t1 - t0 < 1e-12) continue;
    PointXZ at(double t) => PointXZ(x: from.x + dx * t, z: from.z + dz * t);
    // 交点で区切った区間の中では、内外の判定は変わらない。区間の判定には
    // 許容誤差を含めない厳密な判定を使い、区間の途中に禁止領域を挟んでも
    // 中点だけが外周の近くにあるために通してしまうことを防ぐ。
    final state = _exactState(area, at((t0 + t1) / 2));
    if (state == _RegionState.allowed) continue;
    // 許容誤差で許可されるのは、始点・終点が外周の外側 1 mm 以内にあり、
    // その端の区間全体が外周から 1 mm 以内に収まる場合だけ。
    final touchesEnd = t0 == 0 || t1 == 1;
    if (state == _RegionState.outsideOuter &&
        touchesEnd &&
        _staysNearOuter(area, at, t0, t1)) {
      continue;
    }
    stopT = t0;
    break;
  }
  // 区間がすべて許可でも、終点そのものが禁止（穴の境界上など）なら終点の手前で止める。
  if (stopT == null && !isInsideWalkable(area, to)) stopT = 1;

  if (stopT == null) return MoveResult(position: to, blocked: false);

  final travel = stopT * length - kBoundaryEpsilonMeters;
  if (travel <= 0) return stay();
  final stopped = PointXZ(
    x: from.x + dx / length * travel,
    z: from.z + dz / length * travel,
  );
  if (!isInsideWalkable(area, stopped)) return stay();
  return MoveResult(position: stopped, blocked: true);
}

/// 線分 from + t*(dx, dz) と辺 e0→e1 の交点の t（0〜1）を [ts] に足す。
/// 辺と平行で重なる場合は、辺の端点を線分へ射影した t を足す。
void _addCrossings(
  List<double> ts,
  PointXZ from,
  double dx,
  double dz,
  PointXZ e0,
  PointXZ e1,
) {
  final vx = e1.x - e0.x;
  final vz = e1.z - e0.z;
  final wx = e0.x - from.x;
  final wz = e0.z - from.z;
  final denom = cross(dx, dz, vx, vz);
  final scale = math.sqrt(dx * dx + dz * dz) * math.sqrt(vx * vx + vz * vz);
  if (scale == 0) return;

  if (denom.abs() > 1e-12 * scale) {
    final t = cross(wx, wz, vx, vz) / denom;
    final u = cross(wx, wz, dx, dz) / denom;
    const slack = 1e-12;
    if (t >= -slack && t <= 1 + slack && u >= -slack && u <= 1 + slack) {
      ts.add(t.clamp(0.0, 1.0));
    }
    return;
  }

  // 平行。同一直線上のときだけ、重なりの端点を足す。
  final dLength = math.sqrt(dx * dx + dz * dz);
  if (cross(wx, wz, dx, dz).abs() / dLength > 1e-9) return;
  final lengthSquared = dx * dx + dz * dz;
  for (final e in [e0, e1]) {
    final t = ((e.x - from.x) * dx + (e.z - from.z) * dz) / lengthSquared;
    if (t > 0 && t < 1) ts.add(t);
  }
}

enum _RegionState() {
  allowed,
  outsideOuter,
  inHole,
}

/// 許容誤差を含めない判定。外周の境界上は許可、穴の内側と境界上は禁止。
_RegionState _exactState(WalkableArea area, PointXZ p) {
  if (!_isFinitePoint(p) || area.outer.length < 3) {
    return _RegionState.outsideOuter;
  }
  final inOuter =
      pointInPolygon(area.outer, p.x, p.z) ||
      distanceToRing(area.outer, p.x, p.z) <= _kExactEpsilon;
  if (!inOuter) return _RegionState.outsideOuter;
  for (final hole in area.holes) {
    if (hole.length < 3) continue;
    if (pointInPolygon(hole, p.x, p.z) ||
        distanceToRing(hole, p.x, p.z) <= _kExactEpsilon) {
      return _RegionState.inHole;
    }
  }
  return _RegionState.allowed;
}

/// 区間 [t0, t1] を等間隔に調べ、すべて外周から [kBoundaryEpsilonMeters] 以内か。
bool _staysNearOuter(
  WalkableArea area,
  PointXZ Function(double t) at,
  double t0,
  double t1,
) {
  const samples = 16;
  for (var k = 0; k <= samples; k++) {
    final q = at(t0 + (t1 - t0) * k / samples);
    if (distanceToRing(area.outer, q.x, q.z) > kBoundaryEpsilonMeters) {
      return false;
    }
  }
  return true;
}
