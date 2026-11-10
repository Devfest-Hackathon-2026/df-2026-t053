import 'package:serverpod/serverpod.dart';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/play_session_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/play_session_mapper.dart';
import '../unique_violation.dart';

class OrmPlaySessionRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements PlaySessionRepository {
  @override
  Future<PlaySession?> findById(UuidValue id) async {
    final row = await PlaySessionRow.db.findById(
      _session,
      id,
      transaction: _transaction,
    );
    return row == null ? null : playSessionFromRow(row);
  }

  @override
  Future<PlaySession?> findByRequestId(
    int userProfileId,
    UuidValue requestId,
  ) async {
    final row = await PlaySessionRow.db.findFirstRow(
      _session,
      where: (t) =>
          t.userProfileId.equals(userProfileId) & t.requestId.equals(requestId),
      transaction: _transaction,
    );
    return row == null ? null : playSessionFromRow(row);
  }

  @override
  Future<PlaySession> insert(PlaySession session) {
    return translateUniqueViolation(() async {
      final row = await PlaySessionRow.db.insertRow(
        _session,
        playSessionToRow(session),
        transaction: _transaction,
      );
      return playSessionFromRow(row);
    });
  }
}
