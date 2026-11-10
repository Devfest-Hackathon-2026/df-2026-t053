import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';
import 'json_columns.dart';
import 'play_mode_mapper.dart';

Asset assetFromRow(AssetRow row) => Asset(
  id: row.id!,
  sha256: row.sha256,
  objectPath: row.objectPath,
  contentType: row.contentType,
  byteLength: row.byteLength,
  createdAt: row.createdAt.toUtc(),
);

Challenge challengeFromRow(ChallengeRow row) => Challenge(
  id: row.id!,
  slug: row.slug,
  title: row.title,
  currentRevisionId: row.currentRevisionId,
  createdAt: row.createdAt.toUtc(),
);

SpawnPoint spawnPointFromRow(SpawnPointRow row) => SpawnPoint(
  id: row.id!,
  modeConfigId: row.modeConfigId,
  x: row.x,
  y: row.y,
  z: row.z,
  yawDeg: row.yawDeg,
  sortOrder: row.sortOrder,
  label: row.label,
);

ModeConfig modeConfigFromRow(
  ModeConfigRow row,
  List<SpawnPointRow> spawnRows,
) => ModeConfig(
  id: row.id!,
  revisionId: row.revisionId,
  mode: playModeFromRow(row.mode, entity: 'mode_config'),
  walkable: walkableFromJson(row.walkable, entity: 'mode_config'),
  spawnPoints:
      (spawnRows.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          .map(spawnPointFromRow)
          .toList(),
);

Landmark landmarkFromRow(LandmarkRow row) => Landmark(
  id: row.id!,
  revisionId: row.revisionId,
  pavilionId: row.pavilionId,
  displayName: row.displayName,
  posX: row.posX,
  posZ: row.posZ,
  lat: row.lat,
  lon: row.lon,
);

Credit creditFromRow(CreditRow row) => Credit(
  id: row.id!,
  revisionId: row.revisionId,
  name: row.name,
  url: row.url,
  sortOrder: row.sortOrder,
);

/// 版の行と子の行から内部モデルを作る。
///
/// [includeSecrets] が false のとき、正解姿勢・story・highlight は読み取らず
/// [ChallengeRevision.secrets] を null にする。
ChallengeRevision challengeRevisionFromRows({
  required ChallengeRevisionRow row,
  required Asset photo,
  required Asset map,
  required List<ModeConfig> modes,
  required List<LandmarkRow> landmarks,
  required List<CreditRow> credits,
  required bool includeSecrets,
}) => ChallengeRevision(
  id: row.id!,
  challengeId: row.challengeId,
  revisionNo: row.revisionNo,
  sceneProfile: row.sceneProfile,
  scoringVersion: row.scoringVersion,
  photo: photo,
  map: map,
  photoAlt: row.photoAlt,
  mapBounds: mapBoundsFromJson(row.mapBoundsXz, entity: 'challenge_revision'),
  eyeHeightM: row.eyeHeightM,
  shotFovDeg: row.shotFovDeg,
  publishedAt: row.publishedAt?.toUtc(),
  createdAt: row.createdAt.toUtc(),
  modes: modes,
  landmarks: (landmarks.toList()..sort((a, b) => a.id!.compareTo(b.id!)))
      .map(landmarkFromRow)
      .toList(),
  credits:
      (credits.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          .map(creditFromRow)
          .toList(),
  secrets: includeSecrets
      ? RevisionSecrets(
          goal: GoalPose(
            x: row.goalX,
            y: row.goalY,
            z: row.goalZ,
            yawDeg: row.goalYawDeg,
            pitchDeg: row.goalPitchDeg,
          ),
          story: row.story,
          highlight: row.highlight,
        )
      : null,
);
