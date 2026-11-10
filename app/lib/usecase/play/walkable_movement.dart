import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';

/// 出題の歩行領域（`ModeConfig.walkable`）で、1フレームの移動を制限する
/// （docs/specs.md「歩行可能領域」、#221）。
///
/// 衝突グリッドで決めた移動先を、さらに [clampMove] で歩行領域の中に収める。
/// 境界で止められたら、衝突グリッドと同じく X だけ・Z だけの移動も試し、
/// いちばん長く進めるものを使う（境界に沿って滑る）。どの移動も [clampMove] を
/// 通すので、歩行領域の外には出ない。
PointXZ moveWithinWalkable(WalkableArea area, PointXZ from, PointXZ to) {
  final full = clampMove(area, from, to);
  if (!full.blocked) return full.position;
  var best = full.position;
  var bestDistance = _distance(from, best);
  for (final axis in [
    PointXZ(x: to.x, z: from.z),
    PointXZ(x: from.x, z: to.z),
  ]) {
    final moved = clampMove(area, from, axis).position;
    final distance = _distance(from, moved);
    if (distance > bestDistance) {
      best = moved;
      bestDistance = distance;
    }
  }
  return best;
}

double _distance(PointXZ a, PointXZ b) =>
    math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.z - b.z, 2));
