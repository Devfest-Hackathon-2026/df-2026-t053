import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';
import 'play_mode_mapper.dart';

PlaySession playSessionFromRow(PlaySessionRow row) => PlaySession(
  id: row.id!,
  requestId: row.requestId,
  revisionId: row.revisionId,
  mode: playModeFromRow(row.mode, entity: 'play_session'),
  spawnPointId: row.spawnPointId,
  userProfileId: row.userProfileId,
  startedAt: row.startedAt.toUtc(),
  expiresAt: row.expiresAt.toUtc(),
);

PlaySessionRow playSessionToRow(PlaySession session) => PlaySessionRow(
  id: session.id,
  requestId: session.requestId,
  revisionId: session.revisionId,
  mode: playModeToRow(session.mode),
  spawnPointId: session.spawnPointId,
  userProfileId: session.userProfileId,
  startedAt: session.startedAt.toUtc(),
  expiresAt: session.expiresAt.toUtc(),
);
