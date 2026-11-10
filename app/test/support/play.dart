import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_client/serverpod_client.dart';

/// テスト用の固定アカウント。
final testAuthUserId = UuidValue.fromString(
  '00000000-0000-4000-8000-000000000001',
);

/// テスト用の固定セッションID。
final testPlaySessionId = UuidValue.fromString(
  '00000000-0000-4000-8000-000000000002',
);

AssetRef _assetRef() => AssetRef(
  url: 'https://example.invalid/asset',
  sha256: '0' * 64,
  byteLength: 1,
  contentType: 'image/png',
);

ChallengeRevision fakeRevision({
  int id = 1,
  AssetRef? photo,
  List<SpawnEntrance> entrances = const [],
}) => ChallengeRevision(
  id: id,
  challengeId: 1,
  sceneProfile: 'expo2025',
  photo: photo ?? _assetRef(),
  photoAlt: 'お手本写真',
  map: VenueMap(
    image: _assetRef(),
    bounds: MapBounds(minX: -800, minZ: -800, maxX: 800, maxZ: 800),
    landmarks: const [],
  ),
  modes: [
    ModeConfig(
      mode: .free,
      walkable: WalkableArea(
        outer: [
          PointXZ(x: -10, z: -10),
          PointXZ(x: 10, z: -10),
          PointXZ(x: 10, z: 10),
        ],
        holes: const [],
      ),
      entrances: entrances,
    ),
  ],
  eyeHeightMeters: 2.6,
  shotVerticalFovDegrees: 60,
  credits: const [],
);

PlaySession fakePlaySession({
  PlaySessionState state = .active,
  PlayMode mode = .free,
  DateTime? expireTime,
  Shot? shot,
  Reveal? reveal,
  RankingEntry? myRankingEntry,
}) => PlaySession(
  id: testPlaySessionId,
  revisionId: 1,
  mode: mode,
  spawnPointId: 1,
  spawn: Spawn(positionX: 100, positionY: 8.4, positionZ: 50, yawDegrees: 90),
  state: state,
  createTime: DateTime.utc(2026, 11, 9, 10),
  expireTime:
      expireTime ?? DateTime.now().toUtc().add(const Duration(hours: 2)),
  shot: shot,
  reveal: reveal,
  myRankingEntry: myRankingEntry,
);

Shot fakeShot({int score = 500}) => Shot(
  id: 1,
  camera: CameraPose(
    positionX: 100,
    positionY: 11,
    positionZ: 50,
    yawDegrees: 90,
    pitchDegrees: 0,
    verticalFovDegrees: 60,
  ),
  score: score,
  distanceMeters: 1.5,
  yawDiffDegrees: 3,
  pitchDiffDegrees: 1,
  createTime: DateTime.utc(2026, 11, 9, 11),
);

Reveal fakeReveal() => Reveal(
  goalCamera: CameraPose(
    positionX: 101,
    positionY: 11,
    positionZ: 51,
    yawDegrees: 93,
    pitchDegrees: 1,
    verticalFovDegrees: 60,
  ),
  story: '解説文',
  highlight: '見どころ',
);

RankingEntry fakeRankingEntry({int score = 500}) => RankingEntry(
  rank: 2,
  nickname: '旅人0001',
  score: score,
  achieveTime: DateTime.utc(2026, 11, 9, 11),
  mine: true,
);

SubmitShotResponse fakeSubmitShotResponse({int score = 500}) =>
    SubmitShotResponse(
      shot: fakeShot(score: score),
      reveal: fakeReveal(),
      myRankingEntry: fakeRankingEntry(score: score),
    );

/// 撮影済みセッション（getPlaySession の completed 応答）。
PlaySession fakeCompletedSession({int score = 500}) => fakePlaySession(
  state: .completed,
  shot: fakeShot(score: score),
  reveal: fakeReveal(),
  myRankingEntry: fakeRankingEntry(score: score),
);
