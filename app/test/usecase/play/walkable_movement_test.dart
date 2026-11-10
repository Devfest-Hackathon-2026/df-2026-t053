import 'dart:math' as math;

import 'package:app/usecase/play/walkable_movement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

PointXZ p(double x, double z) => PointXZ(x: x, z: z);

// uk-pavilion の周辺探索と同じ形：38 m × 30 m の箱と、電話ボックスの穴。
final _near = WalkableArea(
  outer: [p(-190, -155), p(-152, -155), p(-152, -125), p(-190, -125)],
  holes: [
    [p(-161.1, -128.7), p(-160, -128.7), p(-160, -127.6), p(-161.1, -127.6)],
  ],
);

void main() {
  test('歩行領域の中の移動はそのまま進む', () {
    final moved = moveWithinWalkable(_near, p(-176, -145), p(-175.7, -144.8));
    expect(moved.x, closeTo(-175.7, 1e-9));
    expect(moved.z, closeTo(-144.8, 1e-9));
  });

  test('外周を越える移動は境界の手前で止め、外へ出さない（#221）', () {
    // 南の境界（z = -155）へまっすぐ進む。
    final moved = moveWithinWalkable(_near, p(-176, -154.9), p(-176, -155.2));
    expect(moved.z, greaterThan(-155));
    expect(moved.z, closeTo(-155 + 0.001, 1e-6));
    expect(isInsideWalkable(_near, moved), isTrue);
  });

  test('境界へ斜めに進むと、境界に沿って滑る', () {
    final moved = moveWithinWalkable(
      _near,
      p(-176, -154.95),
      p(-175.7, -155.25),
    );
    expect(moved.x, closeTo(-175.7, 1e-9));
    expect(moved.z, closeTo(-154.95, 1e-9));
    expect(isInsideWalkable(_near, moved), isTrue);
  });

  test('穴（障害物）には入らない', () {
    final moved = moveWithinWalkable(_near, p(-162, -128), p(-160.5, -128));
    expect(moved.x, lessThan(-161.1));
    expect(isInsideWalkable(_near, moved), isTrue);
  });

  test('どの向きに大きく動いても、結果は常に歩行領域の中', () {
    final random = math.Random(221);
    var position = p(-176, -145);
    for (var i = 0; i < 2000; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final step = random.nextDouble() * 3;
      position = moveWithinWalkable(
        _near,
        position,
        p(
          position.x + step * math.sin(angle),
          position.z + step * math.cos(angle),
        ),
      );
      expect(isInsideWalkable(_near, position), isTrue, reason: '$i');
    }
  });
}
