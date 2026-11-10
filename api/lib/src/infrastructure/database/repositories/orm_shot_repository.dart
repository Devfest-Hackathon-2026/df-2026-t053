import 'package:serverpod/serverpod.dart';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/shot_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/shot_mapper.dart';
import '../unique_violation.dart';

class OrmShotRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements ShotRepository {
  @override
  Future<Shot?> findByPlaySessionId(UuidValue playSessionId) async {
    final row = await ShotRow.db.findFirstRow(
      _session,
      where: (t) => t.playSessionId.equals(playSessionId),
      transaction: _transaction,
    );
    return row == null ? null : shotFromRow(row);
  }

  @override
  Future<Shot> insert(Shot shot) {
    return translateUniqueViolation(() async {
      final row = await ShotRow.db.insertRow(
        _session,
        shotToRow(shot),
        transaction: _transaction,
      );
      return shotFromRow(row);
    });
  }
}
