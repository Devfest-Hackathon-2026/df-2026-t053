import 'structure_source.dart';

enum StructureDirection() {
  front,
  left,
  right,

  /// 背後（相対角度の絶対値が 135° を超える）。近くの候補がなく最寄りを選んだときだけ使う。
  behind,
  none,
}

/// ガイド生成に渡す選定済み資料。公開DTOや正解姿勢を含まない。
class SelectedStructure({
  required final int id,
  required final String name,
  required final String facts,
  required final String fallbackText,
  required List<StructureSource> sources,
  required final double distanceMeters,
  required final StructureDirection direction,
}) {
  final List<StructureSource> sources = List.unmodifiable(sources);
}
