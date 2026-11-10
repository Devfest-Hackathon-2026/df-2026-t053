import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';

Shot shotFromRow(ShotRow row) => Shot(
  id: row.id!,
  requestId: row.requestId,
  playSessionId: row.playSessionId,
  x: row.x,
  y: row.y,
  z: row.z,
  yawDeg: row.yawDeg,
  pitchDeg: row.pitchDeg,
  fovDeg: row.fovDeg,
  distanceM: row.distanceM,
  yawDiffDeg: row.yawDiffDeg,
  pitchDiffDeg: row.pitchDiffDeg,
  score: row.score,
  rankAtSubmission: row.rankAtSubmission,
  bestScoreAtSubmission: row.bestScoreAtSubmission,
  nicknameAtSubmission: row.nicknameAtSubmission,
  bestAchieveTimeAtSubmission: row.bestAchieveTimeAtSubmission.toUtc(),
  createdAt: row.createdAt.toUtc(),
);

ShotRow shotToRow(Shot shot) => ShotRow(
  id: shot.id,
  requestId: shot.requestId,
  playSessionId: shot.playSessionId,
  x: shot.x,
  y: shot.y,
  z: shot.z,
  yawDeg: shot.yawDeg,
  pitchDeg: shot.pitchDeg,
  fovDeg: shot.fovDeg,
  distanceM: shot.distanceM,
  yawDiffDeg: shot.yawDiffDeg,
  pitchDiffDeg: shot.pitchDiffDeg,
  score: shot.score,
  rankAtSubmission: shot.rankAtSubmission,
  bestScoreAtSubmission: shot.bestScoreAtSubmission,
  nicknameAtSubmission: shot.nicknameAtSubmission,
  bestAchieveTimeAtSubmission: shot.bestAchieveTimeAtSubmission.toUtc(),
  createdAt: shot.createdAt.toUtc(),
);
