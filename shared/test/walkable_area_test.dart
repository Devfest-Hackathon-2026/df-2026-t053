import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

PointXZ p(double x, double z) => PointXZ(x: x, z: z);

List<PointXZ> square(double min, double max) => [
  p(min, min),
  p(max, min),
  p(max, max),
  p(min, max),
];

/// 0〜10 の正方形の中央に 4〜6 の穴がある領域。
WalkableArea withHole() =>
    WalkableArea(outer: square(0, 10), holes: [square(4, 6)]);

/// 0〜10 の正方形。
WalkableArea solid() => WalkableArea(outer: square(0, 10), holes: []);

/// 上側に切れ込み（x:3〜7, z:3〜10）がある U 字の領域。
WalkableArea uShape() => WalkableArea(
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

void main() {
  const eps = kBoundaryEpsilonMeters;

  group('isInsideWalkable', () {
    test('内側は許可、外側は禁止', () {
      expect(isInsideWalkable(withHole(), p(1, 1)), isTrue);
      expect(isInsideWalkable(withHole(), p(11, 5)), isFalse);
      expect(isInsideWalkable(withHole(), p(-1, 5)), isFalse);
    });

    test('外周の境界上は許可', () {
      expect(isInsideWalkable(solid(), p(0, 5)), isTrue);
      expect(isInsideWalkable(solid(), p(10, 10)), isTrue);
      expect(isInsideWalkable(solid(), p(5, 0)), isTrue);
    });

    test('穴の内側と境界上は禁止', () {
      expect(isInsideWalkable(withHole(), p(5, 5)), isFalse);
      expect(isInsideWalkable(withHole(), p(4, 5)), isFalse);
      expect(isInsideWalkable(withHole(), p(6, 6)), isFalse);
      expect(isInsideWalkable(withHole(), p(3.999, 5)), isTrue);
    });

    test('外周の外側 1 mm 以内は数値誤差として許可し、それより外は禁止', () {
      expect(isInsideWalkable(solid(), p(10 + eps * 0.5, 5)), isTrue);
      expect(isInsideWalkable(solid(), p(10 + eps, 5)), isTrue);
      expect(isInsideWalkable(solid(), p(10 + eps * 2, 5)), isFalse);
    });

    test('有限でない座標は禁止', () {
      expect(isInsideWalkable(solid(), p(double.nan, 5)), isFalse);
      expect(isInsideWalkable(solid(), p(5, double.infinity)), isFalse);
    });
  });

  group('clampMove', () {
    test('境界に触れない移動はそのまま通る', () {
      final r = clampMove(solid(), p(1, 1), p(3, 4));
      expect(r.blocked, isFalse);
      expect(r.position.x, 3);
      expect(r.position.z, 4);
    });

    test('外周を出る移動は境界の 1 mm 手前で止まる', () {
      final r = clampMove(solid(), p(5, 5), p(15, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, closeTo(10 - eps, 1e-9));
      expect(r.position.z, closeTo(5, 1e-9));
      expect(isInsideWalkable(solid(), r.position), isTrue);
    });

    test('穴の手前で止まり、残りの移動は捨てる', () {
      final r = clampMove(withHole(), p(1, 5), p(9, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, closeTo(4 - eps, 1e-9));
      expect(r.position.z, closeTo(5, 1e-9));
    });

    test('終点が穴の反対側の内側でも、穴を横切る移動は止める', () {
      expect(isInsideWalkable(withHole(), p(9, 5)), isTrue);
      final r = clampMove(withHole(), p(1, 5), p(9, 5));
      expect(r.position.x, lessThan(4));
    });

    test('斜めに近づいても止めた位置は許可領域の中', () {
      final r = clampMove(withHole(), p(1, 3.9), p(7, 4.1));
      expect(r.blocked, isTrue);
      expect(isInsideWalkable(withHole(), r.position), isTrue);
      expect(r.position.x, lessThan(6));
    });

    test('凹部を横切る移動は、終点が内側でも止める', () {
      expect(isInsideWalkable(uShape(), p(1, 8)), isTrue);
      expect(isInsideWalkable(uShape(), p(9, 8)), isTrue);
      final r = clampMove(uShape(), p(1, 8), p(9, 8));
      expect(r.blocked, isTrue);
      expect(r.position.x, closeTo(3 - eps, 1e-9));
    });

    test('凹部の下側（許可領域）を通る移動は止めない', () {
      final r = clampMove(uShape(), p(1, 1), p(9, 1));
      expect(r.blocked, isFalse);
      expect(r.position.x, 9);
    });

    test('外周の境界上から内側へ動く場合は止めない（時刻 0 の交点）', () {
      final r = clampMove(solid(), p(0, 5), p(3, 5));
      expect(r.blocked, isFalse);
      expect(r.position.x, 3);

      final corner = clampMove(solid(), p(0, 0), p(4, 4));
      expect(corner.blocked, isFalse);
      expect(corner.position.x, 4);
    });

    test('外周の境界に沿った移動は止めない', () {
      final r = clampMove(solid(), p(0, 2), p(0, 8));
      expect(r.blocked, isFalse);
      expect(r.position.z, 8);
    });

    test('許可領域の中で境界に接するだけの移動は止めない', () {
      // 穴の角 (4, 4) を点でかすめて対角線上の外側へ抜ける。
      final graze = clampMove(withHole(), p(2, 6), p(6, 2));
      expect(graze.blocked, isFalse);
      expect(graze.position.x, 6);
      expect(graze.position.z, 2);

      // U 字の凹角 (3, 3) をかすめる。
      final touch = clampMove(uShape(), p(1, 5), p(5, 1));
      expect(touch.blocked, isFalse);
    });

    test('外周の境界から外へ出る移動は動かない', () {
      final r = clampMove(solid(), p(0, 5), p(-3, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, 0);
    });

    test('穴の境界上からの外向きの移動は止めない（押し出しはしない）', () {
      final r = clampMove(withHole(), p(4, 5), p(2, 5));
      expect(r.blocked, isFalse);
      expect(r.position.x, 2);
    });

    test('禁止領域の内側からは動かず、位置を飛ばさない', () {
      final r = clampMove(withHole(), p(5, 5), p(5.5, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, 5);
      expect(r.position.z, 5);
    });

    test('移動が 0 なら止められない', () {
      final r = clampMove(solid(), p(2, 2), p(2, 2));
      expect(r.blocked, isFalse);
      expect(r.position.x, 2);
    });

    test('終点が穴の境界上なら、その手前で止まる', () {
      final r = clampMove(withHole(), p(1, 5), p(4, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, closeTo(4 - eps, 1e-9));
    });

    test('1 mm 未満の移動で境界に近づいても、結果は許可領域の中', () {
      final from = p(4 - eps * 1.5, 5);
      final r = clampMove(withHole(), from, p(4 - eps * 0.5, 5));
      expect(isInsideWalkable(withHole(), r.position), isTrue);
    });
    test('中点だけが外周の 1 mm 以内にあっても、途中の禁止領域は通さない', () {
      // x:0.02〜0.08 の切れ込みの中に、z=4.9995 まで届く細い突起（x:0.04〜0.06）がある。
      // z=5 の線では、切れ込みの中点 (0.05, 5) だけが突起の先から 0.5 mm 以内に入る。
      final area = WalkableArea(
        outer: [
          p(0, 0),
          p(0.10, 0),
          p(0.10, 10),
          p(0.08, 10),
          p(0.08, 2),
          p(0.06, 2),
          p(0.06, 4.9995),
          p(0.04, 4.9995),
          p(0.04, 2),
          p(0.02, 2),
          p(0.02, 10),
          p(0, 10),
        ],
        holes: [],
      );
      expect(validateWalkable(area).isValid, isTrue);
      expect(isInsideWalkable(area, p(0.01, 5)), isTrue);
      expect(isInsideWalkable(area, p(0.09, 5)), isTrue);
      expect(isInsideWalkable(area, p(0.03, 5)), isFalse);

      final r = clampMove(area, p(0.01, 5), p(0.09, 5));
      expect(r.blocked, isTrue);
      expect(r.position.x, closeTo(0.02 - eps, 1e-9));
    });

    test('外周の外側 1 mm 以内から内側へ入る移動は止めない', () {
      final r = clampMove(solid(), p(-eps * 0.5, 5), p(3, 5));
      expect(r.blocked, isFalse);
      expect(r.position.x, 3);
    });

    test('外周の外側 1 mm 以内で終わる移動は許可し、それ以上外へは出さない', () {
      final near = clampMove(solid(), p(9, 5), p(10 + eps * 0.5, 5));
      expect(near.blocked, isFalse);
      final far = clampMove(solid(), p(9, 5), p(10 + eps * 5, 5));
      expect(far.blocked, isTrue);
      expect(far.position.x, closeTo(10 - eps, 1e-9));
    });
  });
}
