import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

PointXZ p(double x, double z) => PointXZ(x: x, z: z);

/// 穴が 2 つと凹部のある領域で、ランダムな移動を繰り返して不変条件を確かめる。
void main() {
  final area = WalkableArea(
    outer: [
      p(0, 0),
      p(40, 0),
      p(40, 30),
      p(25, 30),
      p(25, 12),
      p(15, 12),
      p(15, 30),
      p(0, 30),
    ],
    holes: [
      [p(5, 4), p(10, 4), p(10, 9), p(5, 9)],
      [p(28, 3), p(36, 5), p(32, 10)],
    ],
  );

  test('設計した領域は妥当', () {
    expect(validateWalkable(area).isValid, isTrue);
  });

  test('ランダムな移動で、結果は常に許可領域の中で、通過した経路も許可領域の中', () {
    final random = math.Random(21);
    var position = p(2, 2);
    var blockedCount = 0;
    for (var i = 0; i < 5000; i++) {
      final step = 4 * random.nextDouble();
      final angle = 2 * math.pi * random.nextDouble();
      final to = p(
        position.x + step * math.cos(angle),
        position.z + step * math.sin(angle),
      );
      final result = clampMove(area, position, to);

      expect(
        isInsideWalkable(area, result.position),
        isTrue,
        reason: '$i: $position → $to が ${result.position} で禁止領域',
      );
      // 結果までの経路を細かく調べ、禁止領域を横切っていないことを確かめる。
      for (var k = 1; k <= 50; k++) {
        final t = k / 50;
        final q = p(
          position.x + (result.position.x - position.x) * t,
          position.z + (result.position.z - position.z) * t,
        );
        expect(isInsideWalkable(area, q), isTrue, reason: '$i: 経路 $t');
      }
      if (!result.blocked) {
        expect(result.position.x, to.x);
        expect(result.position.z, to.z);
      } else {
        blockedCount++;
      }
      position = result.position;
    }
    expect(blockedCount, greaterThan(0));
  });
}
