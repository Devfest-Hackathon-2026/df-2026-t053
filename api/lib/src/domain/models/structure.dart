import 'structure_source.dart';

/// 版に固定したガイド用の構造物資料。[sources] は sortOrder の昇順。
/// [sources] は変更できないコピーで持つ（渡した元のリストを変えても影響しない）。
class Structure({
  required final int id,
  required final int revisionId,
  required final int? pavilionId,
  required final String name,
  required final double posX,
  required final double posZ,
  required final String facts,
  required final String fallbackText,
  required List<StructureSource> sources,
}) {
  final List<StructureSource> sources = List.unmodifiable(sources);
}
