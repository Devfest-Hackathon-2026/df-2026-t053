import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

PointXZ p(double x, double z) => PointXZ(x: x, z: z);

List<PointXZ> square(double minX, double minZ, double maxX, double maxZ) => [
  p(minX, minZ),
  p(maxX, minZ),
  p(maxX, maxZ),
  p(minX, maxZ),
];

List<PointXZ> outer() => square(0, 0, 100, 100);

Set<WalkableViolationCode> codes(WalkableArea area) =>
    validateWalkable(area).violations.map((v) => v.code).toSet();

/// 頂点数 [n] の正多角形（中心 (cx, cz)、半径 r）。
List<PointXZ> ngon(int n, double cx, double cz, double r) => [
  for (var i = 0; i < n; i++)
    p(
      cx + r * math.cos(2 * math.pi * i / n),
      cz + r * math.sin(2 * math.pi * i / n),
    ),
];

void main() {
  group('validateWalkable', () {
    test('穴のない外周だけの領域は妥当', () {
      expect(
        validateWalkable(WalkableArea(outer: outer(), holes: [])).isValid,
        isTrue,
      );
    });

    test('穴が離れて外周の内側にあれば妥当', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 20, 20), square(30, 30, 40, 40)],
      );
      expect(validateWalkable(area).isValid, isTrue);
    });

    test('凹多角形の外周は妥当', () {
      final area = WalkableArea(
        outer: [
          p(0, 0),
          p(10, 0),
          p(10, 10),
          p(7, 10),
          p(7, 3),
          p(3, 3),
          p(3, 10),
          p(0, 10),
        ],
        holes: [],
      );
      expect(validateWalkable(area).isValid, isTrue);
    });

    test('頂点が 2 点', () {
      final area = WalkableArea(outer: [p(0, 0), p(1, 0)], holes: []);
      expect(codes(area), {WalkableViolationCode.outerVertexCount});
    });

    test('穴の頂点が 2 点', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [
          [p(10, 10), p(20, 20)],
        ],
      );
      expect(codes(area), {WalkableViolationCode.holeVertexCount});
    });

    test('頂点数 512 は妥当、513 は不正', () {
      final ok = WalkableArea(outer: ngon(512, 50, 50, 40), holes: []);
      expect(validateWalkable(ok).isValid, isTrue);
      final ng = WalkableArea(outer: ngon(513, 50, 50, 40), holes: []);
      expect(codes(ng), {WalkableViolationCode.outerVertexCount});
    });

    test('終点が始点と重複している', () {
      final ring = [...square(0, 0, 10, 10), p(0, 0)];
      final area = WalkableArea(outer: ring, holes: []);
      expect(
        codes(area),
        contains(WalkableViolationCode.duplicateClosingVertex),
      );
    });

    test('隣り合う頂点が同じ位置', () {
      final area = WalkableArea(
        outer: [p(0, 0), p(10, 0), p(10, 0), p(10, 10), p(0, 10)],
        holes: [],
      );
      expect(codes(area), contains(WalkableViolationCode.duplicateVertex));
    });

    test('座標が有限でない', () {
      final area = WalkableArea(
        outer: [p(0, 0), p(10, 0), p(double.nan, 10)],
        holes: [],
      );
      expect(codes(area), {WalkableViolationCode.nonFiniteCoordinate});
    });

    test('外周の自己交差（蝶ネクタイ）', () {
      final area = WalkableArea(
        outer: [p(0, 0), p(10, 10), p(10, 0), p(0, 10)],
        holes: [],
      );
      expect(codes(area), {WalkableViolationCode.selfIntersection});
    });

    test('折り返して重なる辺は自己交差', () {
      final area = WalkableArea(
        outer: [p(0, 0), p(10, 0), p(5, 0), p(5, 10)],
        holes: [],
      );
      expect(codes(area), contains(WalkableViolationCode.selfIntersection));
    });

    test('穴の自己交差', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [
          [p(10, 10), p(30, 30), p(30, 10), p(10, 30)],
        ],
      );
      expect(codes(area), {WalkableViolationCode.selfIntersection});
    });

    test('穴同士の交差', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 30, 30), square(20, 20, 40, 40)],
      );
      expect(codes(area), {WalkableViolationCode.holeIntersection});
    });

    test('穴同士の接触（辺が触れる）', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 20, 20), square(20, 10, 30, 20)],
      );
      expect(codes(area), {WalkableViolationCode.holeIntersection});
    });

    test('穴同士が 1 mm 以内に近い', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 20, 20), square(20.0005, 10, 30, 20)],
      );
      expect(codes(area), {WalkableViolationCode.holeIntersection});
    });

    test('穴が別の穴の内側にある', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 50, 50), square(20, 20, 30, 30)],
      );
      expect(codes(area), {WalkableViolationCode.holeContainment});
    });

    test('穴と外周の接触', () {
      final area = WalkableArea(outer: outer(), holes: [square(0, 10, 10, 20)]);
      expect(codes(area), {WalkableViolationCode.holeTouchesOuter});
    });

    test('穴が外周をまたぐ', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(90, 90, 110, 110)],
      );
      expect(codes(area), {WalkableViolationCode.holeTouchesOuter});
    });

    test('穴が外周の外側にある', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(200, 200, 210, 210)],
      );
      expect(codes(area), {WalkableViolationCode.holeOutsideOuter});
    });

    test('穴の数 64 は妥当、65 は不正', () {
      List<List<PointXZ>> holes(int n) => [
        for (var i = 0; i < n; i++)
          square(
            2.0 + (i % 9) * 10,
            2.0 + (i ~/ 9) * 10,
            2.0 + (i % 9) * 10 + 5,
            2.0 + (i ~/ 9) * 10 + 5,
          ),
      ];
      final ok = WalkableArea(outer: outer(), holes: holes(64));
      expect(validateWalkable(ok).isValid, isTrue);
      final ng = WalkableArea(outer: outer(), holes: holes(65));
      expect(codes(ng), {WalkableViolationCode.holeCount});
    });

    test('違反は外周と穴の位置を示す', () {
      final area = WalkableArea(
        outer: outer(),
        holes: [square(10, 10, 20, 20), square(15, 15, 25, 25)],
      );
      final v = validateWalkable(area).violations.single;
      expect(v.ringIndex, 0);
      expect(v.otherRingIndex, 1);
    });
  });
}
