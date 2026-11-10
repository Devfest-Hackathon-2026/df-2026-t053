import 'package:photohunt_server/src/domain/models/models.dart';
import 'package:photohunt_shared/photohunt_shared.dart'
    show MapBounds, PointXZ, WalkableArea;
import 'package:test/test.dart';

/// domain モデルが持つ List は、変更できないコピーで持つ（#140）。
void main() {
  final t0 = DateTime.utc(2026, 11, 10);
  final asset = Asset(
    id: 1,
    sha256: 'a' * 64,
    objectPath: 'media/a/photo.png',
    contentType: 'image/png',
    byteLength: 1,
    createdAt: t0,
  );
  const source = StructureSource(
    id: 1,
    structureId: 1,
    title: '登録資料',
    url: 'https://example.com/1',
    sortOrder: 0,
  );
  const spawn = SpawnPoint(
    id: 1,
    modeConfigId: 1,
    x: 0,
    y: 0,
    z: 0,
    yawDeg: 0,
    sortOrder: 0,
    label: null,
  );
  const landmark = Landmark(
    id: 1,
    revisionId: 1,
    pavilionId: 1,
    displayName: '施設',
    posX: 0,
    posZ: 0,
    lat: null,
    lon: null,
  );
  const credit = Credit(
    id: 1,
    revisionId: 1,
    name: '出典',
    url: null,
    sortOrder: 0,
  );
  final walkable = WalkableArea(
    outer: [PointXZ(x: 0, z: 0), PointXZ(x: 1, z: 0), PointXZ(x: 0, z: 1)],
    holes: [],
  );

  ModeConfig modeConfig(List<SpawnPoint> spawnPoints) => ModeConfig(
    id: 1,
    revisionId: 1,
    mode: .free,
    walkable: walkable,
    spawnPoints: spawnPoints,
  );

  ChallengeRevision revision({
    required List<ModeConfig> modes,
    required List<Landmark> landmarks,
    required List<Credit> credits,
  }) => ChallengeRevision(
    id: 1,
    challengeId: 1,
    revisionNo: 1,
    sceneProfile: 'bundled-v1',
    scoringVersion: 'v1',
    photo: asset,
    map: asset,
    photoAlt: 'alt',
    mapBounds: MapBounds(minX: 0, minZ: 0, maxX: 1, maxZ: 1),
    eyeHeightM: 1.6,
    shotFovDeg: 50,
    publishedAt: t0,
    createdAt: t0,
    modes: modes,
    landmarks: landmarks,
    credits: credits,
    secrets: null,
  );

  test('Structure.sources は変更できず、元のリストの変更に影響されない', () {
    final sources = [source];
    final structure = Structure(
      id: 1,
      revisionId: 1,
      pavilionId: null,
      name: '施設',
      posX: 0,
      posZ: 0,
      facts: '事実',
      fallbackText: '固定解説',
      sources: sources,
    );
    expect(() => structure.sources.add(source), throwsUnsupportedError);
    expect(() => structure.sources.clear(), throwsUnsupportedError);
    sources.clear();
    expect(structure.sources, [source]);
  });

  test('ModeConfig.spawnPoints は変更できず、元のリストの変更に影響されない', () {
    final spawnPoints = [spawn];
    final config = modeConfig(spawnPoints);
    expect(() => config.spawnPoints.add(spawn), throwsUnsupportedError);
    expect(() => config.spawnPoints.clear(), throwsUnsupportedError);
    spawnPoints.clear();
    expect(config.spawnPoints, [spawn]);
  });

  test('ChallengeRevision の modes・landmarks・credits は変更できず、'
      '元のリストの変更に影響されない', () {
    final config = modeConfig([spawn]);
    final modes = [config];
    final landmarks = [landmark];
    final credits = [credit];
    final r = revision(modes: modes, landmarks: landmarks, credits: credits);

    expect(() => r.modes.add(config), throwsUnsupportedError);
    expect(() => r.modes.clear(), throwsUnsupportedError);
    expect(() => r.landmarks.add(landmark), throwsUnsupportedError);
    expect(() => r.landmarks.clear(), throwsUnsupportedError);
    expect(() => r.credits.add(credit), throwsUnsupportedError);
    expect(() => r.credits.clear(), throwsUnsupportedError);

    modes.clear();
    landmarks.clear();
    credits.clear();
    expect(r.modes, [config]);
    expect(r.landmarks, [landmark]);
    expect(r.credits, [credit]);
  });
}
