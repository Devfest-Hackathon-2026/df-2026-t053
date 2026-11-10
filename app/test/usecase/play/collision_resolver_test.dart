import 'dart:io';
import 'dart:typed_data';

import 'package:app/model/collision_grid.dart';
import 'package:app/usecase/play/collision_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

CollisionGrid _emptyGrid({
  double minX = -100,
  double minZ = -100,
  int width = 200,
  int height = 200,
}) {
  final header = ByteData(24);
  header.setFloat64(0, minX, Endian.little);
  header.setFloat64(8, minZ, Endian.little);
  header.setUint32(16, width, Endian.little);
  header.setUint32(20, height, Endian.little);
  final cells = Uint8List((width * height + 7) ~/ 8);
  final bytes = Uint8List(24 + cells.length);
  bytes.setRange(0, 24, Uint8List.view(header.buffer, 0, 24));
  bytes.setRange(24, bytes.length, cells);
  return CollisionGrid.fromBytes(bytes);
}

CollisionGrid _gridWithBlock({required double x, required double z}) {
  final grid = _emptyGrid();
  final gx = ((x - grid.minX) / grid.cellSize).floor();
  final gz = ((z - grid.minZ) / grid.cellSize).floor();
  final index = gz * grid.width + gx;
  final cells = Uint8List.fromList(grid.cells);
  cells[index ~/ 8] |= 1 << (index % 8);
  final header = ByteData(24);
  header.setFloat64(0, grid.minX, Endian.little);
  header.setFloat64(8, grid.minZ, Endian.little);
  header.setUint32(16, grid.width, Endian.little);
  header.setUint32(20, grid.height, Endian.little);
  final bytes = Uint8List(24 + cells.length);
  bytes.setRange(0, 24, Uint8List.view(header.buffer, 0, 24));
  bytes.setRange(24, bytes.length, cells);
  return CollisionGrid.fromBytes(bytes);
}

void main() {
  group('CollisionResolver', () {
    test('moves freely when nothing blocks', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      final result = resolver.resolve(
        currentX: 0,
        currentZ: 0,
        currentY: 9.8,
        nextX: 1,
        nextZ: 2,
        onRing: false,
      );
      expect(result.x, 1);
      expect(result.z, 2);
      expect(result.y, 9.8);
    });

    test('slides along a wall when moving into a blocked cell', () {
      final resolver = CollisionResolver(
        grid: _gridWithBlock(x: 1, z: 2),
      );
      final result = resolver.resolve(
        currentX: 0,
        currentZ: 0,
        currentY: 9.8,
        nextX: 1,
        nextZ: 2,
        onRing: false,
      );
      // Either X or Z axis is preserved.
      expect(result.x == 1 || result.z == 2, isTrue);
      // Not both blocked.
      expect(result.x != 1 || result.z != 2, isTrue);
    });

    test('clamps movement to ring band when onRing', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      final result = resolver.resolve(
        currentX: 0,
        currentZ: 315,
        currentY: 28.5,
        nextX: 0,
        nextZ: 340,
        onRing: true,
      );
      final r = (result.x + 4.2) * (result.x + 4.2) +
          (result.z - 0.2) * (result.z - 0.2);
      expect(r, lessThanOrEqualTo(kRingOuterRadius * kRingOuterRadius + 1));
      expect(r, greaterThanOrEqualTo(kRingInnerRadius * kRingInnerRadius - 1));
      expect(result.y, greaterThan(27.0));
      expect(result.y, lessThan(31.0));
    });

    test('allows walking across full skywalk deck width from inner to outer handrails', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      // Test walking at R ≈ 310 (previously blocked incorrectly by R=314.5)
      // At X = 0, center = (-4.2, 0.2), R ≈ 310 means Z ≈ 310.2
      final walkInnerDeck = resolver.resolve(
        currentX: -4.2,
        currentZ: 310.0,
        currentY: 26.7,
        nextX: -4.2,
        nextZ: 312.0,
        onRing: true,
      );
      expect(walkInnerDeck.x, closeTo(-4.2, 0.001));
      expect(walkInnerDeck.z, closeTo(312.0, 0.001));

      // Test walking toward inner handrail (R < 307.5) stops at handrail
      final blockInnerHole = resolver.resolve(
        currentX: -4.2,
        currentZ: 309.0,
        currentY: 26.7,
        nextX: -4.2,
        nextZ: 300.0,
        onRing: true,
      );
      expect(blockInnerHole.z, greaterThanOrEqualTo(kRingInnerRadius));
    });

    test('does not tunnel through a thin wall with a large step', () {
      // A wall at x = 5, z = 5. The player tries to jump from x = 4 to x = 7
      // in one frame. Sub-stepping should stop them before the wall.
      final resolver = CollisionResolver(grid: _gridWithBlock(x: 5, z: 5));
      final result = resolver.resolve(
        currentX: 4,
        currentZ: 5,
        currentY: 9.8,
        nextX: 7,
        nextZ: 5,
        onRing: false,
      );
      expect(result.x, lessThan(6));
    });

    test('ignores ground grid when onRing', () {
      // Ground at the start cell is blocked, but onRing should not consult the
      // ground grid at all and clamp to the ring band instead.
      final resolver = CollisionResolver(grid: _gridWithBlock(x: 0, z: 0));
      final result = resolver.resolve(
        currentX: 0,
        currentZ: 0,
        currentY: 24.4,
        nextX: 0,
        nextZ: 5,
        onRing: true,
      );
      final r = (result.x + 4.2) * (result.x + 4.2) +
          (result.z - 0.2) * (result.z - 0.2);
      expect(r, greaterThanOrEqualTo(kRingInnerRadius * kRingInnerRadius - 1));
    });

    test('stops before moving into water plaza center', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -350, width: 400, height: 400),
      );
      final result = resolver.resolve(
        currentX: -85,
        currentZ: -160,
        currentY: 9.8,
        nextX: -85,
        nextZ: -230,
        onRing: false,
      );
      expect(result.x, -85);
      expect(result.z, greaterThan(-195));
    });

    test('blocks entry to gate monument inside water plaza', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -350, width: 400, height: 400),
      );
      final result = resolver.resolve(
        currentX: -82,
        currentZ: -160,
        currentY: 9.8,
        nextX: -82,
        nextZ: -229,
        onRing: false,
      );
      expect(result.z, greaterThan(-196));
    });

    test('stops before moving into water plaza from south (sea side)', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -360, width: 400, height: 400),
      );
      final result = resolver.resolve(
        currentX: -40,
        currentZ: -305,
        currentY: 9.8,
        nextX: -40,
        nextZ: -245,
        onRing: false,
      );
      expect(result.x, -40);
      expect(result.z, lessThan(-298));
    });

    test('allows moving freely north of water plaza', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -350, width: 400, height: 400),
      );
      final result = resolver.resolve(
        currentX: -20,
        currentZ: -120,
        currentY: 9.8,
        nextX: -20,
        nextZ: -160,
        onRing: false,
      );
      expect(result.x, -20);
      expect(result.z, -160);
    });

    test('treats water plaza boundary as water and blocks it', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -360, width: 400, height: 400),
      );
      // 輪郭表の地点 x = -40 では北端が z = -210、南端が z = -298。
      final northResult = resolver.resolve(
        currentX: -40,
        currentZ: -205,
        currentY: 9.8,
        nextX: -40,
        nextZ: -210,
        onRing: false,
      );
      expect(northResult.z, greaterThan(-210));

      final southResult = resolver.resolve(
        currentX: -40,
        currentZ: -303,
        currentY: 9.8,
        nextX: -40,
        nextZ: -298,
        onRing: false,
      );
      expect(southResult.z, lessThan(-298));
    });

    test('does not treat the satellite studio east of the plaza as water', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -360, width: 500, height: 400),
      );
      // 水盤の東端は x ≒ 108 で終わる。その東の建物付近は水域ではない。
      final result = resolver.resolve(
        currentX: 105,
        currentZ: -215,
        currentY: 9.8,
        nextX: 105,
        nextZ: -230,
        onRing: false,
      );
      expect(result.x, 105);
      expect(result.z, -230);
    });

    test('blocks entry to the narrow west channel of water plaza', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -350, width: 400, height: 400),
      );
      // 西端の水路は x = -185 で北端 z ≒ -164.9。
      final result = resolver.resolve(
        currentX: -185,
        currentZ: -160,
        currentY: 9.8,
        nextX: -185,
        nextZ: -175,
        onRing: false,
      );
      expect(result.x, -185);
      expect(result.z, greaterThan(-166));
    });

    test('stops before moving into the west channel from the ring side', () {
      final resolver = CollisionResolver(
        grid: _emptyGrid(minX: -300, minZ: -360, width: 400, height: 400),
      );
      // 水路の南端はリング内周の弧で、x = -185 では z ≒ -239.1。
      final result = resolver.resolve(
        currentX: -185,
        currentZ: -250,
        currentY: 9.8,
        nextX: -185,
        nextZ: -200,
        onRing: false,
      );
      expect(result.x, -185);
      expect(result.z, lessThan(-239));
    });

    test('allows walking through East Gate and West Gate in assets/collision.bin', () {
      final file = File('assets/collision.bin');
      if (!file.existsSync()) return;
      final grid = CollisionGrid.fromBytes(file.readAsBytesSync());
      final resolver = CollisionResolver(grid: grid);

      // Walk through East Gate (580.0 -> 530.0, z = 123.4) into the venue
      final eastResult = resolver.resolve(
        currentX: 580.0,
        currentZ: 123.4,
        currentY: 9.8,
        nextX: 530.0,
        nextZ: 123.4,
        onRing: false,
      );
      expect(eastResult.x, closeTo(530.0, 0.001));
      expect(eastResult.z, closeTo(123.4, 0.001));

      // Walk through West Gate (-572.3 -> -530.0, z = 342.9) into the venue
      final westResult = resolver.resolve(
        currentX: -572.3,
        currentZ: 342.9,
        currentY: 9.8,
        nextX: -530.0,
        nextZ: 342.9,
        onRing: false,
      );
      expect(westResult.x, closeTo(-530.0, 0.001));
      expect(westResult.z, closeTo(342.9, 0.001));
    });

    test('preserves East Gate escalator spot on ring with eye height on deck floor', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      // Teleport spot on ring: (285.8, 85.6)
      final result = resolver.resolve(
        currentX: 285.8,
        currentZ: 85.6,
        currentY: 28.5,
        nextX: 285.8,
        nextZ: 85.6,
        onRing: true,
      );
      expect(result.x, 285.8);
      expect(result.z, 85.6);
      // Floor level Y ≈ 21.2 + 7.3 = ~28.5 (comfortably clears handrail top at Y ≈ 24.9)
      expect(result.y, closeTo(28.5, 1.0));
    });

    test('allows walking backwards down the East Gate escalator', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      // From top of escalator (285.8, 85.6), walk backwards (westward to 275.0)
      final result = resolver.resolve(
        currentX: 285.8,
        currentZ: 85.6,
        currentY: 28.5,
        nextX: 275.0,
        nextZ: 85.6,
        onRing: true,
      );
      expect(result.x, closeTo(275.0, 0.001));
      expect(result.z, closeTo(85.6, 0.001));
      // Height decreases as descending the escalator
      expect(result.y, lessThan(28.5));
      expect(result.y, greaterThan(20.0));
    });

    test('prevents walking through East Gate escalator side handrails', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      // Walking south out of escalator bounds (z: 85.6 -> 70.0)
      final result = resolver.resolve(
        currentX: 280.0,
        currentZ: 85.6,
        currentY: 20.0,
        nextX: 280.0,
        nextZ: 70.0,
        onRing: true,
      );
      // Z movement is blocked by handrail, stays inside [76.0, 89.0]
      expect(result.z, greaterThanOrEqualTo(76.0));
    });

    test('walks smoothly from escalator top into main ring deck and back', () {
      final resolver = CollisionResolver(grid: _emptyGrid());
      // Step forward from escalator (290.0) into deck connection (298.0)
      final forward = resolver.resolve(
        currentX: 290.0,
        currentZ: 85.6,
        currentY: 23.0,
        nextX: 298.0,
        nextZ: 85.6,
        onRing: true,
      );
      expect(forward.x, 298.0);

      // Step backward from deck (298.0) back onto escalator (285.8)
      final backward = resolver.resolve(
        currentX: 298.0,
        currentZ: 85.6,
        currentY: 23.0,
        nextX: 285.8,
        nextZ: 85.6,
        onRing: true,
      );
      expect(backward.x, 285.8);
      expect(backward.z, 85.6);
    });
  });
}
