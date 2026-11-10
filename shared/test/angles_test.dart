import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

PointXZ p(double x, double z) => PointXZ(x: x, z: z);

void main() {
  group('yawDiff', () {
    test('0 度をまたぐ差は短い側', () {
      expect(yawDiff(350, 10), 20);
      expect(yawDiff(10, 350), 20);
    });

    test('真後ろは 180 度', () {
      expect(yawDiff(0, 180), 180);
      expect(yawDiff(180, 0), 180);
    });

    test('同じ向きは 0 で、-0 にならない', () {
      expect(yawDiff(90, 90), 0);
      expect(yawDiff(0, 360).isNegative, isFalse);
    });

    test('360 度を超える値や負の値も扱える', () {
      expect(yawDiff(-10, 370), 20);
      expect(yawDiff(720, 0), 0);
    });
  });

  group('normalizeYaw', () {
    test('[0, 360) に収める', () {
      expect(normalizeYaw(360), 0);
      expect(normalizeYaw(450), 90);
      expect(normalizeYaw(-90), 270);
      expect(normalizeYaw(359.5), 359.5);
    });

    test('-0 は 0', () {
      expect(normalizeYaw(-0.0).isNegative, isFalse);
      expect(normalizeYaw(-360).isNegative, isFalse);
      expect(normalizeYaw(-360), 0);
    });

    test('負のごく小さい値が 360 に丸まらない', () {
      expect(normalizeYaw(-1e-20), lessThan(360));
    });
  });

  group('normalizeSigned', () {
    test('[-180, 180) に収める', () {
      expect(normalizeSigned(180), -180);
      expect(normalizeSigned(-180), -180);
      expect(normalizeSigned(190), -170);
      expect(normalizeSigned(-190), 170);
      expect(normalizeSigned(0), 0);
      expect(normalizeSigned(359), -1);
    });
  });

  group('bearingDegrees', () {
    final o = p(0, 0);
    test('北（−Z）は 0 度', () => expect(bearingDegrees(o, p(0, -5)), 0));
    test('東（＋X）は 90 度', () => expect(bearingDegrees(o, p(5, 0)), 90));
    test('南（＋Z）は 180 度', () => expect(bearingDegrees(o, p(0, 5)), 180));
    test('西（−X）は 270 度', () => expect(bearingDegrees(o, p(-5, 0)), 270));

    test('北東は 45 度、起点がずれても同じ', () {
      expect(bearingDegrees(p(10, 10), p(13, 7)), closeTo(45, 1e-9));
    });

    test('負のゼロの差でも向きが崩れない', () {
      expect(bearingDegrees(p(0, 0), p(-0.0, 5)), 180);
      expect(bearingDegrees(p(0, 0), p(-0.0, -5)), 0);
    });
  });
}
