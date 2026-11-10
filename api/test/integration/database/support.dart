import 'dart:convert';
import 'dart:io';

import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/generated/protocol.dart';
// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

/// 一時ファイルの SQLite に migration を適用して、DB のテストを実行する。
///
/// 各 test は rollback される。SQLite のファイルは `data/` に作られるので、
/// clone 直後でも動くようにディレクトリを先に作る。
void withDatabase(
  String name,
  void Function(TestSessionBuilder sessionBuilder) body,
) {
  Directory('data').createSync(recursive: true);
  withServerpod(name, (sessionBuilder, _) => body(sessionBuilder));
}

final t0 = DateTime.utc(2026, 11, 8, 1, 2, 3, 456);

int _seq = 0;
String sha(int n) => n.toRadixString(16).padLeft(64, '0');

Future<AssetRow> insertAsset(Session s, {String? sha256}) {
  final n = ++_seq;
  return AssetRow.db.insertRow(
    s,
    AssetRow(
      sha256: sha256 ?? sha(n),
      objectPath: 'media/asset-$n',
      contentType: 'image/webp',
      byteLength: 1024,
      createdAt: t0,
    ),
  );
}

Future<ChallengeRow> insertChallenge(Session s, {String? slug}) {
  final n = ++_seq;
  return ChallengeRow.db.insertRow(
    s,
    ChallengeRow(slug: slug ?? 'challenge-$n', title: 'title', createdAt: t0),
  );
}

final walkableWithHole = WalkableArea(
  outer: [
    PointXZ(x: 0, z: 0),
    PointXZ(x: 10, z: 0),
    PointXZ(x: 10, z: 10),
    PointXZ(x: 0, z: 10),
  ],
  holes: [
    [PointXZ(x: 4, z: 4), PointXZ(x: 6, z: 4), PointXZ(x: 6, z: 6)],
  ],
);

final walkableSolid = WalkableArea(
  outer: [PointXZ(x: 0, z: 0), PointXZ(x: 5.5, z: 0), PointXZ(x: 0, z: 5.5)],
  holes: [],
);

final mapBounds = MapBounds(minX: -50, minZ: -60, maxX: 50.5, maxZ: 60.5);

String mapBoundsJson() => jsonEncode(mapBounds.toJson());
String walkableJson(WalkableArea a) => jsonEncode(a.toJson());

/// 版の行を作る。`challenge.current_revision_id` は null のまま。
Future<ChallengeRevisionRow> insertRevision(
  Session s, {
  required ChallengeRow challenge,
  int revisionNo = 1,
  AssetRow? photo,
  AssetRow? map,
  DateTime? publishedAt,
}) async {
  final p = photo ?? await insertAsset(s);
  final mp = map ?? await insertAsset(s);
  return ChallengeRevisionRow.db.insertRow(
    s,
    ChallengeRevisionRow(
      challengeId: challenge.id!,
      revisionNo: revisionNo,
      sceneProfile: 'profile-a',
      scoringVersion: 'v1',
      photoAssetId: p.id!,
      mapAssetId: mp.id!,
      photoAlt: 'alt',
      mapBoundsXz: mapBoundsJson(),
      eyeHeightM: 1.6,
      shotFovDeg: 60,
      goalX: 1.5,
      goalY: 1.6,
      goalZ: 2.5,
      goalYawDeg: 90,
      goalPitchDeg: -5,
      story: 'story text',
      highlight: 'highlight text',
      publishedAt: publishedAt,
      createdAt: t0,
    ),
  );
}

Future<ModeConfigRow> insertModeConfig(
  Session s, {
  required ChallengeRevisionRow revision,
  PlayMode mode = PlayMode.free,
  String? walkable,
}) {
  return ModeConfigRow.db.insertRow(
    s,
    ModeConfigRow(
      revisionId: revision.id!,
      mode: mode,
      walkable: walkable ?? walkableJson(walkableWithHole),
    ),
  );
}

Future<SpawnPointRow> insertSpawn(
  Session s, {
  required ModeConfigRow modeConfig,
  int sortOrder = 0,
}) {
  return SpawnPointRow.db.insertRow(
    s,
    SpawnPointRow(
      modeConfigId: modeConfig.id!,
      x: 1,
      y: 0,
      z: 2,
      yawDeg: 45,
      sortOrder: sortOrder,
    ),
  );
}

Future<PavilionRow> insertPavilion(Session s, {String? sourceKey}) {
  final n = ++_seq;
  return PavilionRow.db.insertRow(
    s,
    PavilionRow(sourceKey: sourceKey ?? 'pavilion-$n', name: 'pavilion'),
  );
}

Future<UserProfileRow> insertProfile(Session s, {UuidValue? authUserId}) {
  return UserProfileRow.db.insertRow(
    s,
    UserProfileRow(
      authUserId: authUserId ?? const Uuid().v4obj(),
      nickname: 'nick',
      createdAt: t0,
    ),
  );
}

/// 版・モード・開始点・プロフィールを揃えた、プレイ開始前の一式。
class Fixture(
  final ChallengeRow challenge,
  final ChallengeRevisionRow revision,
  final ModeConfigRow modeConfig,
  final SpawnPointRow spawn,
  final UserProfileRow profile,
);

Future<Fixture> insertFixture(Session s) async {
  final challenge = await insertChallenge(s);
  final revision = await insertRevision(s, challenge: challenge);
  final modeConfig = await insertModeConfig(s, revision: revision);
  final spawn = await insertSpawn(s, modeConfig: modeConfig);
  final profile = await insertProfile(s);
  return Fixture(challenge, revision, modeConfig, spawn, profile);
}

Future<PlaySessionRow> insertPlaySession(
  Session s,
  Fixture f, {
  UuidValue? requestId,
}) {
  return PlaySessionRow.db.insertRow(
    s,
    PlaySessionRow(
      id: const Uuid().v7obj(),
      requestId: requestId ?? const Uuid().v4obj(),
      revisionId: f.revision.id!,
      mode: PlayMode.free,
      spawnPointId: f.spawn.id!,
      userProfileId: f.profile.id!,
      startedAt: t0,
      expiresAt: t0.add(const Duration(minutes: 30)),
    ),
  );
}

Future<ShotRow> insertShotRow(
  Session s,
  PlaySessionRow play, {
  int score = 500,
}) {
  return ShotRow.db.insertRow(
    s,
    ShotRow(
      requestId: const Uuid().v4obj(),
      playSessionId: play.id!,
      x: 1,
      y: 1.6,
      z: 2,
      yawDeg: 10,
      pitchDeg: 0,
      fovDeg: 60,
      distanceM: 3.5,
      yawDiffDeg: 4,
      pitchDiffDeg: 1,
      score: score,
      rankAtSubmission: 1,
      bestScoreAtSubmission: score,
      nicknameAtSubmission: 'nick',
      bestAchieveTimeAtSubmission: t0,
      createdAt: t0,
    ),
  );
}

/// SQL を直接実行する（制約の確認と、壊れたデータの用意に使う）。
Future<DatabaseResult> sql(Session s, String query) => s.db.unsafeQuery(query);

Matcher throwsDuplicate(String entity, String constraint) => throwsA(
  isA<DuplicateEntityException>()
      .having((e) => e.entity, 'entity', entity)
      .having((e) => e.constraint, 'constraint', constraint),
);
