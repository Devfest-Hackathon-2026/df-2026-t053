import 'dart:math' as math;

import '../generated/point_xz.dart';
import '../generated/walkable_area.dart';
import 'segment_geometry.dart';
import 'walkable_area.dart';

/// 歩行領域の頂点数の上限（外周・各穴）。
const int kWalkableMaxVertices = 512;

/// 歩行領域の穴の数の上限。
const int kWalkableMaxHoles = 64;

/// 頂点数の下限。閉じるための終点重複は持たせない。
const int kWalkableMinVertices = 3;

/// [WalkableViolation.ringIndex] で外周を表す値。穴は 0 始まりの添字。
const int kOuterRingIndex = -1;

enum WalkableViolationCode() {
  /// 外周の頂点数が 3〜512 の範囲外。
  outerVertexCount,

  /// 穴の数が 0〜64 の範囲外。
  holeCount,

  /// 穴の頂点数が 3〜512 の範囲外。
  holeVertexCount,

  /// 座標が有限でない（NaN・無限大）。
  nonFiniteCoordinate,

  /// 閉じるために始点を終点にも置いている。
  duplicateClosingVertex,

  /// 隣り合う頂点が同じ位置。
  duplicateVertex,

  /// 同じ多角形の辺が交差・接触する（折り返しや面積 0 を含む）。
  selfIntersection,

  /// 穴同士の辺が交差・接触する。
  holeIntersection,

  /// 穴が別の穴の内側にある。
  holeContainment,

  /// 穴の辺が外周に交差・接触する。
  holeTouchesOuter,

  /// 穴が外周の外側にある。
  holeOutsideOuter,
}

/// 検出した問題 1 件。
class const WalkableViolation({
  required final WalkableViolationCode code,

  /// 開発者向けの説明。
  required final String message,

  /// 問題のある多角形。[kOuterRingIndex] なら外周、0 以上なら穴の添字。
  final int? ringIndex,

  /// 2 つの多角形の関係の問題で、相手側の多角形（同じ表記）。
  final int? otherRingIndex,
}) {
  @override
  String toString() => 'WalkableViolation(${code.name}: $message)';
}

/// [validateWalkable] の結果。
class const WalkableValidation(final List<WalkableViolation> violations) {
  bool get isValid => violations.isEmpty;
}

String _ringName(int index) => index == kOuterRingIndex ? '外周' : '穴 $index';

/// 登録する歩行領域が仕様を満たすか検証する。
///
/// 頂点は 3〜512、穴は 0〜64。閉じるための終点重複を持たず、自己交差、
/// 穴同士の交差・接触・包含、穴と外周の接触、外周の外にある穴を禁止する。
/// 接触は [kBoundaryEpsilonMeters] 以内の近さも含める。
WalkableValidation validateWalkable(WalkableArea area) {
  final violations = <WalkableViolation>[];

  if (area.holes.length > kWalkableMaxHoles) {
    violations.add(
      WalkableViolation(
        code: WalkableViolationCode.holeCount,
        message: '穴は $kWalkableMaxHoles 個以下にする（${area.holes.length} 個）。',
      ),
    );
  }

  // 形に問題がない多角形だけを、幾何の検査に進める。
  final rings = <int, List<PointXZ>>{};
  if (_checkRing(area.outer, kOuterRingIndex, violations)) {
    rings[kOuterRingIndex] = area.outer;
  }
  for (var i = 0; i < area.holes.length; i++) {
    if (_checkRing(area.holes[i], i, violations)) rings[i] = area.holes[i];
  }

  for (final entry in rings.entries) {
    if (_hasSelfContact(entry.value)) {
      violations.add(
        WalkableViolation(
          code: WalkableViolationCode.selfIntersection,
          ringIndex: entry.key,
          message: '${_ringName(entry.key)}の辺が交差・接触している。',
        ),
      );
    }
  }

  final outer = rings[kOuterRingIndex];
  final holeIndexes = rings.keys.where((k) => k != kOuterRingIndex).toList();
  for (final i in holeIndexes) {
    final hole = rings[i]!;
    if (outer != null) {
      if (_ringsTouch(outer, hole)) {
        violations.add(
          WalkableViolation(
            code: WalkableViolationCode.holeTouchesOuter,
            ringIndex: i,
            otherRingIndex: kOuterRingIndex,
            message: '穴 $i が外周に交差・接触している。',
          ),
        );
      } else if (!pointInPolygon(outer, hole.first.x, hole.first.z)) {
        violations.add(
          WalkableViolation(
            code: WalkableViolationCode.holeOutsideOuter,
            ringIndex: i,
            otherRingIndex: kOuterRingIndex,
            message: '穴 $i が外周の外側にある。',
          ),
        );
      }
    }
    for (final j in holeIndexes.where((j) => j > i)) {
      final other = rings[j]!;
      if (_ringsTouch(hole, other)) {
        violations.add(
          WalkableViolation(
            code: WalkableViolationCode.holeIntersection,
            ringIndex: i,
            otherRingIndex: j,
            message: '穴 $i と穴 $j が交差・接触している。',
          ),
        );
      } else if (pointInPolygon(other, hole.first.x, hole.first.z) ||
          pointInPolygon(hole, other.first.x, other.first.z)) {
        violations.add(
          WalkableViolation(
            code: WalkableViolationCode.holeContainment,
            ringIndex: i,
            otherRingIndex: j,
            message: '穴 $i と穴 $j の一方がもう一方の内側にある。',
          ),
        );
      }
    }
  }

  return WalkableValidation(List.unmodifiable(violations));
}

/// 多角形 1 つの形（頂点数・有限・重複）を検査し、幾何の検査に進めるかを返す。
bool _checkRing(List<PointXZ> ring, int index, List<WalkableViolation> out) {
  final countCode = index == kOuterRingIndex
      ? WalkableViolationCode.outerVertexCount
      : WalkableViolationCode.holeVertexCount;
  if (ring.length < kWalkableMinVertices ||
      ring.length > kWalkableMaxVertices) {
    out.add(
      WalkableViolation(
        code: countCode,
        ringIndex: index,
        message:
            '${_ringName(index)}の頂点は $kWalkableMinVertices〜$kWalkableMaxVertices 点にする（${ring.length} 点）。',
      ),
    );
    return false;
  }
  if (ring.any((p) => !p.x.isFinite || !p.z.isFinite)) {
    out.add(
      WalkableViolation(
        code: WalkableViolationCode.nonFiniteCoordinate,
        ringIndex: index,
        message: '${_ringName(index)}に有限でない座標がある。',
      ),
    );
    return false;
  }

  var usable = true;
  if (_distance(ring.first, ring.last) <= kBoundaryEpsilonMeters) {
    out.add(
      WalkableViolation(
        code: WalkableViolationCode.duplicateClosingVertex,
        ringIndex: index,
        message: '${_ringName(index)}は閉じるための終点重複を持たせない。',
      ),
    );
    usable = false;
  }
  for (var i = 0; i + 1 < ring.length; i++) {
    if (_distance(ring[i], ring[i + 1]) <= kBoundaryEpsilonMeters) {
      out.add(
        WalkableViolation(
          code: WalkableViolationCode.duplicateVertex,
          ringIndex: index,
          message: '${_ringName(index)}の頂点 $i と ${i + 1} が同じ位置。',
        ),
      );
      usable = false;
      break;
    }
  }
  return usable;
}

double _distance(PointXZ a, PointXZ b) =>
    distancePointToSegment(a.x, a.z, b.x, b.z, b.x, b.z);

/// 同じ多角形の辺同士が交差・接触するか。
bool _hasSelfContact(List<PointXZ> ring) {
  final n = ring.length;
  for (var i = 0; i < n; i++) {
    final a0 = ring[i];
    final a1 = ring[(i + 1) % n];
    for (var j = i + 1; j < n; j++) {
      final b0 = ring[j];
      final b1 = ring[(j + 1) % n];
      final adjacent = j == i + 1 || (i == 0 && j == n - 1);
      if (adjacent) {
        // 共有する頂点以外の端点が相手の辺に乗る＝折り返し・面積 0。
        final sharedIsA1 = j == i + 1;
        final otherA = sharedIsA1 ? a0 : a1;
        final otherB = sharedIsA1 ? b1 : b0;
        if (distancePointToSegment(
                  otherA.x,
                  otherA.z,
                  b0.x,
                  b0.z,
                  b1.x,
                  b1.z,
                ) <=
                kBoundaryEpsilonMeters ||
            distancePointToSegment(
                  otherB.x,
                  otherB.z,
                  a0.x,
                  a0.z,
                  a1.x,
                  a1.z,
                ) <=
                kBoundaryEpsilonMeters) {
          return true;
        }
      } else if (distanceSegmentToSegment(a0, a1, b0, b1) <=
          kBoundaryEpsilonMeters) {
        return true;
      }
    }
  }
  return false;
}

/// 別々の 2 つの多角形の辺が交差・接触するか。
bool _ringsTouch(List<PointXZ> a, List<PointXZ> b) {
  if (!_boundsNear(a, b)) return false;
  for (var i = 0; i < a.length; i++) {
    final a0 = a[i];
    final a1 = a[(i + 1) % a.length];
    for (var j = 0; j < b.length; j++) {
      final b0 = b[j];
      final b1 = b[(j + 1) % b.length];
      if (distanceSegmentToSegment(a0, a1, b0, b1) <= kBoundaryEpsilonMeters) {
        return true;
      }
    }
  }
  return false;
}

/// 2 つの多角形の外接矩形が [kBoundaryEpsilonMeters] 以内に近いか。
/// 離れていれば辺の総当たりを省く。
bool _boundsNear(List<PointXZ> a, List<PointXZ> b) {
  double minOf(List<PointXZ> r, double Function(PointXZ) f) =>
      r.map(f).reduce(math.min);
  double maxOf(List<PointXZ> r, double Function(PointXZ) f) =>
      r.map(f).reduce(math.max);
  double x(PointXZ p) => p.x;
  double z(PointXZ p) => p.z;
  const e = kBoundaryEpsilonMeters;
  return minOf(a, x) <= maxOf(b, x) + e &&
      minOf(b, x) <= maxOf(a, x) + e &&
      minOf(a, z) <= maxOf(b, z) + e &&
      minOf(b, z) <= maxOf(a, z) + e;
}
