import 'dart:typed_data';

class CollisionGrid {
  CollisionGrid._({
    required this.minX,
    required this.minZ,
    required this.width,
    required this.height,
    required this.cellSize,
    required this.cells,
  });

  factory CollisionGrid.fromBytes(Uint8List bytes) {
    final header = ByteData.sublistView(bytes, 0, 24);
    final minX = header.getFloat64(0, Endian.little);
    final minZ = header.getFloat64(8, Endian.little);
    final width = header.getUint32(16, Endian.little);
    final height = header.getUint32(20, Endian.little);
    final expectedBytes = 24 + (width * height + 7) ~/ 8;
    if (bytes.length < expectedBytes) {
      throw FormatException(
        'Collision grid too short: expected $expectedBytes bytes, '
        'got ${bytes.length}',
      );
    }
    return CollisionGrid._(
      minX: minX,
      minZ: minZ,
      width: width,
      height: height,
      cellSize: 1.0,
      cells: bytes.sublist(24),
    );
  }

  final double minX;
  final double minZ;
  final int width;
  final int height;
  final double cellSize;
  final Uint8List cells;

  bool isBlocked(double x, double z) {
    final gx = _worldToGridX(x);
    final gz = _worldToGridZ(z);
    if (gx < 0 || gx >= width || gz < 0 || gz >= height) {
      return true;
    }
    final index = gz * width + gx;
    final byteIndex = index ~/ 8;
    final bitIndex = index % 8;
    return (cells[byteIndex] & (1 << bitIndex)) != 0;
  }

  int _worldToGridX(double x) => ((x - minX) / cellSize).floor();
  int _worldToGridZ(double z) => ((z - minZ) / cellSize).floor();
}
