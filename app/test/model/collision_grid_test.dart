import 'dart:typed_data';

import 'package:app/model/collision_grid.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CollisionGrid', () {
    late CollisionGrid grid;

    setUp(() {
      final header = ByteData(24);
      header.setFloat64(0, -10, Endian.little);
      header.setFloat64(8, -10, Endian.little);
      header.setUint32(16, 20, Endian.little);
      header.setUint32(20, 20, Endian.little);
      final cells = Uint8List((20 * 20 + 7) ~/ 8);
      // Block cell (5, 5): index = 5 * 20 + 5 = 105
      cells[105 ~/ 8] = 1 << (105 % 8);
      final bytes = Uint8List(24 + cells.length);
      bytes.setRange(0, 24, Uint8List.view(header.buffer, 0, 24));
      bytes.setRange(24, bytes.length, cells);
      grid = CollisionGrid.fromBytes(bytes);
    });

    test('reports blocked for a marked cell', () {
      expect(grid.isBlocked(-4.5, -4.5), isTrue);
    });

    test('reports free for an unmarked cell', () {
      expect(grid.isBlocked(0, 0), isFalse);
    });

    test('reports blocked outside bounds', () {
      expect(grid.isBlocked(-20, 0), isTrue);
      expect(grid.isBlocked(20, 0), isTrue);
      expect(grid.isBlocked(0, -20), isTrue);
      expect(grid.isBlocked(0, 20), isTrue);
    });
  });

  group('CollisionGrid from generated collision.bin', () {
    test('registered spots are walkable', () async {
      final data = await rootBundle.load('assets/collision.bin');
      final grid = CollisionGrid.fromBytes(data.buffer.asUint8List());

      expect(grid.isBlocked(578.5, 163.2), isFalse); // 東ゲート
      expect(grid.isBlocked(-572.3, 342.9), isFalse); // 西ゲート
      expect(grid.isBlocked(-82.4, 300.0), isFalse); // コネクティングゾーン
      expect(grid.isBlocked(253.9, 22.4), isFalse); // エンパワーリングゾーン
      expect(grid.isBlocked(-296.3, 73.8), isFalse); // セービングゾーン
      expect(grid.isBlocked(-0.2, -97.9), isFalse); // シグネチャーゾーン
      expect(grid.isBlocked(6.6, 105.2), isFalse); // 静けさの森ゾーン
      expect(grid.isBlocked(326.2, -71.8), isFalse); // 東ゲートゾーン
      expect(grid.isBlocked(-312.8, 224.8), isFalse); // 西ゲートゾーン
      expect(grid.isBlocked(-690.8, 544.5), isFalse); // フューチャーライフゾーン
    });

    test('building footprints are blocked', () async {
      final data = await rootBundle.load('assets/collision.bin');
      final grid = CollisionGrid.fromBytes(data.buffer.asUint8List());

      // 日本館中心は建物内部なので blocked。
      expect(grid.isBlocked(391.2, -83.3), isTrue);
    });

    test('grid is not a north-south mirror', () async {
      final data = await rootBundle.load('assets/collision.bin');
      final grid = CollisionGrid.fromBytes(data.buffer.asUint8List());

      // 日本館中心 (391.2, -83.3) とその南北鏡像点 (391.2, 83.3) で
      // 状態が異なることを確認する。鏡像になっていれば両方同じ値になる。
      final centerBlocked = grid.isBlocked(391.2, -83.3);
      final mirrorBlocked = grid.isBlocked(391.2, 83.3);
      expect(centerBlocked, isTrue);
      expect(centerBlocked, isNot(mirrorBlocked));
    });
  });
}
