import 'package:serverpod/serverpod.dart';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/structure_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/structure_mapper.dart';

class OrmStructureRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements StructureRepository {
  @override
  Future<List<Structure>> listByRevision(int revisionId) async {
    final rows = await StructureRow.db.find(
      _session,
      where: (t) => t.revisionId.equals(revisionId),
      orderBy: (t) => t.id,
      transaction: _transaction,
    );
    if (rows.isEmpty) return const [];
    final sources = await StructureSourceRow.db.find(
      _session,
      where: (t) => t.structureId.inSet(<int>{for (final r in rows) r.id!}),
      transaction: _transaction,
    );
    return [
      for (final r in rows)
        structureFromRow(r, [
          for (final s in sources)
            if (s.structureId == r.id) s,
        ]),
    ];
  }
}
