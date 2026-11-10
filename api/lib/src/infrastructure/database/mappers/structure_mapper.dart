import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';

StructureSource structureSourceFromRow(StructureSourceRow row) =>
    StructureSource(
      id: row.id!,
      structureId: row.structureId,
      title: row.title,
      url: row.url,
      sortOrder: row.sortOrder,
    );

Structure structureFromRow(
  StructureRow row,
  List<StructureSourceRow> sourceRows,
) => Structure(
  id: row.id!,
  revisionId: row.revisionId,
  pavilionId: row.pavilionId,
  name: row.name,
  posX: row.posX,
  posZ: row.posZ,
  facts: row.facts,
  fallbackText: row.fallbackText,
  sources:
      (sourceRows.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          .map(structureSourceFromRow)
          .toList(),
);
