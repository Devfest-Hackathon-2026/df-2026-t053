import 'dart:io';
import 'dart:math' as math;

import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_input.dart';
import 'package:photohunt_server/src/application/seed/seed_validator.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

import 'seed_fixture.dart';

void main() {
  late SeedBundle base;
  late SeedRevisionInput raw;
  setUp(() {
    base = sampleBundle();
    raw = sampleInput();
  });

  List<SeedViolation> validate(
    SeedRevisionInput changed, {
    SeedAssetFacts? photo,
    SeedAssetFacts? map,
    Set<String>? pavilionKeys,
  }) => validateSeed(
    input: seedRevisionFromInput(changed),
    pavilionKeys: pavilionKeys ?? {for (final p in base.pavilions) p.sourceKey},
    photo: photo ?? facts(base.input.photo, base.photo),
    map: map ?? facts(base.input.map, base.map),
  );

  /// 違反の中に [path] で始まり [message] を含むものがある。
  Matcher hasViolation(String path, [String message = '']) => contains(
    isA<SeedViolation>()
        .having((v) => v.path, 'path', startsWith(path))
        .having((v) => v.message, 'message', contains(message)),
  );

  SeedRevisionInput withMode(
    SeedRevisionInput input,
    PlayMode mode,
    SeedModeInput Function(SeedModeInput m) change,
  ) => input.copyWith(
    modes: [
      for (final m in input.modes)
        if (m.mode == mode) change(m) else m,
    ],
  );

  test('サンプルの seed は違反がない', () {
    expect(validate(raw), isEmpty);
  });

  test('pavilion マスターのサンプルも違反がない', () {
    expect(validatePavilions(base.pavilions), isEmpty);
  });

  group('歩行領域', () {
    test('自己交差するポリゴン', () {
      final input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          walkable: WalkableArea(
            outer: [
              PointXZ(x: -50, z: -70),
              PointXZ(x: 50, z: 30),
              PointXZ(x: 50, z: -70),
              PointXZ(x: -50, z: 30),
            ],
            holes: [],
          ),
        ),
      );
      expect(validate(input), hasViolation('modes[0].walkable', '交差'));
    });

    test('穴が外周に接触する', () {
      final input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          walkable: m.walkable.copyWith(
            holes: [
              [
                PointXZ(x: -50, z: 0),
                PointXZ(x: -40, z: 0),
                PointXZ(x: -40, z: 10),
              ],
            ],
          ),
        ),
      );
      expect(validate(input), hasViolation('modes[0].walkable', '外周'));
    });

    test('頂点が 513 点', () {
      final ring = [
        for (var i = 0; i < 513; i++)
          PointXZ(x: -40 + 80 * i / 512, z: -60 + (i.isEven ? 0 : 0.5)),
        PointXZ(x: 40, z: 20),
        PointXZ(x: -40, z: 20),
      ];
      final input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          walkable: WalkableArea(outer: ring, holes: []),
        ),
      );
      expect(validate(input), hasViolation('modes[0].walkable', '512'));
    });

    test('near が free の外に出る', () {
      final input = withMode(
        raw,
        PlayMode.near,
        (m) => m.copyWith(
          walkable: m.walkable.copyWith(
            outer: [
              PointXZ(x: -20, z: -60),
              PointXZ(x: 55, z: -60),
              PointXZ(x: 55, z: -10),
              PointXZ(x: -20, z: -10),
            ],
          ),
        ),
      );
      expect(validate(input), hasViolation('modes[1].walkable', 'free'));
    });

    test('free の障害物が near の領域の中に残る', () {
      final input = withMode(
        raw,
        PlayMode.near,
        (m) => m.copyWith(walkable: m.walkable.copyWith(holes: [])),
      );
      expect(validate(input), hasViolation('modes[1].walkable', 'free の穴'));
    });

    test('free の穴の辺が、U 字型の near の穴の外（歩ける場所）を横切る', () {
      List<PointXZ> ring(List<(double, double)> points) => [
        for (final (x, z) in points) PointXZ(x: x, z: z),
      ];
      var input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          walkable: m.walkable.copyWith(
            // 頂点は 4 つとも near の U 字の穴の両腕の中にある。
            holes: [
              ring([(-8, -30), (8, -30), (8, -25), (-8, -25)]),
            ],
          ),
        ),
      );
      input = withMode(
        input,
        PlayMode.near,
        (m) => m.copyWith(
          walkable: m.walkable.copyWith(
            holes: [
              ring([
                (-10, -50),
                (10, -50),
                (10, -20),
                (5, -20),
                (5, -45),
                (-5, -45),
                (-5, -20),
                (-10, -20),
              ]),
            ],
          ),
        ),
      );
      expect(validate(input), hasViolation('modes[1].walkable', 'free の穴 0'));
    });

    test('free・near のどちらかがない、重複する', () {
      final input = raw.copyWith(modes: [raw.modes.first, raw.modes.first]);
      final violations = validate(input);
      expect(violations, hasViolation('modes[1].mode', '重複'));
      expect(violations, hasViolation('modes', 'near のモードがない'));
    });
  });

  group('開始点とゴール', () {
    test('free の開始点が 33 件', () {
      final input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          spawns: [
            for (var i = 0; i < 33; i++)
              SeedSpawnInput(
                positionX: -40 + i * 2.0,
                positionY: 0,
                positionZ: 20,
                yawDegrees: 0,
              ),
          ],
        ),
      );
      expect(validate(input), hasViolation('modes[0].spawns', '2〜32'));
    });

    test('free の開始点が 1 件、near が 2 件', () {
      var input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(spawns: [m.spawns.first]),
      );
      input = withMode(
        input,
        PlayMode.near,
        (m) => m.copyWith(spawns: [m.spawns.first, m.spawns.first]),
      );
      final violations = validate(input);
      expect(violations, hasViolation('modes[0].spawns', '2〜32'));
      expect(violations, hasViolation('modes[1].spawns', '1 件'));
    });

    test('開始点が歩行領域の外（穴の中）', () {
      final input = withMode(
        raw,
        PlayMode.free,
        (m) => m.copyWith(
          spawns: [
            m.spawns.first,
            SeedSpawnInput(
              positionX: 0,
              positionY: 0,
              positionZ: -30,
              yawDegrees: 0,
            ),
          ],
        ),
      );
      expect(validate(input), hasViolation('modes[0].spawns[1]', '外'));
    });

    test('ゴールとの XZ 距離が 4.9 m', () {
      final input = withMode(
        raw,
        PlayMode.near,
        (m) => m.copyWith(
          spawns: [
            SeedSpawnInput(
              positionX: 0,
              positionY: 0,
              positionZ: -49.9,
              yawDegrees: 0,
            ),
          ],
        ),
      );
      expect(validate(input), hasViolation('modes[1].spawns[0]', '5.0 m'));
    });

    test('足元 Y が開始点で揃っていない', () {
      final input = withMode(
        raw,
        PlayMode.near,
        (m) => m.copyWith(spawns: [m.spawns.first.copyWith(positionY: 0.5)]),
      );
      expect(validate(input), hasViolation('modes[1].spawns[0].positionY'));
    });

    test('ゴールの Y が足元＋視点高さと一致しない', () {
      final input = raw.copyWith(
        revision: raw.revision.copyWith(
          goal: raw.revision.goal.copyWith(y: 1.7),
        ),
      );
      expect(validate(input), hasViolation('revision.goal.y'));
    });

    test('ゴールが near の歩行領域の外', () {
      final input = raw.copyWith(
        revision: raw.revision.copyWith(goal: raw.revision.goal.copyWith(z: 0)),
      );
      expect(validate(input), hasViolation('revision.goal', 'near'));
    });

    test('pitch が 65° を超える、yaw が 360', () {
      final input = raw.copyWith(
        revision: raw.revision.copyWith(
          goal: raw.revision.goal.copyWith(pitchDegrees: 70, yawDegrees: 360),
        ),
      );
      final violations = validate(input);
      expect(violations, hasViolation('revision.goal.pitchDegrees'));
      expect(violations, hasViolation('revision.goal.yawDegrees'));
    });

    test('有限でない値', () {
      final input = raw.copyWith(
        revision: raw.revision.copyWith(
          goal: raw.revision.goal.copyWith(x: double.nan),
        ),
      );
      expect(validate(input), hasViolation('revision.goal.x', '有限'));
    });
  });

  group('会場図と地点', () {
    test('bounds の比率が画像と違う', () {
      final input = raw.copyWith(
        map: SeedMapInput(
          bounds: MapBounds(minX: -60, minZ: -80, maxX: 61, maxZ: 40),
        ),
      );
      expect(validate(input), hasViolation('assets.map', '1 px'));
    });

    test('会場図の比率は、幅・高さのどちらから求めても 1 px 以内で一致する', () {
      // 比率 2.0（120 m × 60 m）。
      final wide = raw.copyWith(
        map: SeedMapInput(
          bounds: MapBounds(minX: -60, minZ: -80, maxX: 60, maxZ: -20),
        ),
      );
      SeedAssetFacts mapOf(int width, int height) => SeedAssetFacts(
        declaredContentType: 'image/png',
        byteLength: 1000,
        probe: SeedImageFacts(
          contentType: 'image/png',
          width: width,
          height: height,
          hasMetadata: false,
        ),
      );
      List<SeedViolation> mapViolations(int width, int height) => validate(
        wide,
        map: mapOf(width, height),
      ).where((v) => v.path == 'assets.map').toList();
      expect(mapViolations(4000, 2000), isEmpty);
      expect(mapViolations(4001, 2000), isEmpty); // 幅 1 px のずれ
      expect(mapViolations(4000, 2001), isNotEmpty); // 高さ 1 px のずれは幅 2 px 分
      expect(mapViolations(4003, 2000), isNotEmpty);
    });

    test('bounds の幅が 0', () {
      final input = raw.copyWith(
        map: SeedMapInput(
          bounds: MapBounds(minX: 0, minZ: -80, maxX: 0, maxZ: 40),
        ),
      );
      expect(validate(input), hasViolation('map.bounds', '正'));
    });

    test('地点が会場図の範囲外', () {
      final input = raw.copyWith(
        landmarks: [raw.landmarks.first.copyWith(positionX: 100)],
      );
      expect(validate(input), hasViolation('landmarks[0]', '範囲'));
    });

    test('構造物が会場図の範囲外', () {
      final input = raw.copyWith(
        structures: [raw.structures.first.copyWith(positionX: 9999)],
      );
      expect(validate(input), hasViolation('structures[0]', '範囲'));
    });

    test('緯度だけ設定した', () {
      final input = raw.copyWith(
        landmarks: [raw.landmarks.first.copyWith(latitude: 34.65)],
      );
      expect(validate(input), hasViolation('landmarks[0]', '対'));
    });

    test('緯度経度の範囲外', () {
      final input = raw.copyWith(
        landmarks: [raw.landmarks.first.copyWith(latitude: 91, longitude: 181)],
      );
      final violations = validate(input);
      expect(violations, hasViolation('landmarks[0].latitude'));
      expect(violations, hasViolation('landmarks[0].longitude'));
    });

    test('pavilion マスターにない地点', () {
      final input = raw.copyWith(
        landmarks: [raw.landmarks.first.copyWith(pavilionKey: 'unknown')],
      );
      expect(validate(input), hasViolation('landmarks[0].pavilionKey'));
    });

    test('件数の上限（地点 101、出典 31、構造物 101）', () {
      final l = raw.landmarks.first;
      final input = raw.copyWith(
        landmarks: [for (var i = 0; i < 101; i++) l],
        credits: [for (var i = 0; i < 31; i++) raw.credits.first],
        structures: [for (var i = 0; i < 101; i++) raw.structures.first],
      );
      final violations = validate(input);
      expect(violations, hasViolation('landmarks', '100'));
      expect(violations, hasViolation('credits', '30'));
      expect(violations, hasViolation('structures', '100'));
    });

    test('出典の URL が https でない', () {
      final input = raw.copyWith(
        credits: [Credit(name: 'x', url: 'http://example.com')],
      );
      expect(validate(input), hasViolation('credits[0].url', 'https'));
    });
  });

  group('素材', () {
    SeedAssetFacts photoFacts({
      String declared = 'image/png',
      int bytes = 1000,
      String type = 'image/png',
      int width = 960,
      int height = 640,
      bool metadata = false,
    }) => SeedAssetFacts(
      declaredContentType: declared,
      byteLength: bytes,
      probe: SeedImageFacts(
        contentType: type,
        width: width,
        height: height,
        hasMetadata: metadata,
      ),
    );

    test('MIME が実ファイルと違う', () {
      expect(
        validate(raw, photo: photoFacts(declared: 'image/jpeg')),
        hasViolation('assets.photo.contentType', '一致しない'),
      );
    });

    test('対応しない形式', () {
      expect(
        validate(raw, photo: photoFacts(declared: 'image/gif')),
        hasViolation('assets.photo.contentType'),
      );
    });

    test('5 MiB を超える', () {
      expect(
        validate(raw, photo: photoFacts(bytes: 5 * 1024 * 1024 + 1)),
        hasViolation('assets.photo', '5 MiB'),
      );
    });

    test('最大辺が 4096 px を超える', () {
      expect(
        validate(raw, photo: photoFacts(width: 4097)),
        hasViolation('assets.photo', '4096'),
      );
    });

    test('EXIF を含む', () {
      expect(
        validate(raw, photo: photoFacts(metadata: true)),
        hasViolation('assets.photo', 'EXIF'),
      );
    });

    test('画像として読めない', () {
      expect(
        validate(
          raw,
          photo: const SeedAssetFacts(
            declaredContentType: 'image/png',
            byteLength: 10,
            probe: null,
          ),
        ),
        hasViolation('assets.photo', '読めない'),
      );
    });
  });

  test('違反は最初の 1 件で止めずに全件を返す', () {
    final input = raw.copyWith(
      challenge: raw.challenge.copyWith(slug: 'Bad Slug'),
      revision: raw.revision.copyWith(
        scoringVersion: 'v9',
        goal: raw.revision.goal.copyWith(pitchDegrees: 90),
      ),
      landmarks: [raw.landmarks.first.copyWith(latitude: 1)],
    );
    final violations = validate(input);
    expect(violations, hasViolation('challenge.slug'));
    expect(violations, hasViolation('revision.scoringVersion'));
    expect(violations, hasViolation('revision.goal.pitchDegrees'));
    expect(violations, hasViolation('landmarks[0]', '対'));
  });

  test('pavilion マスターの重複・緯度だけ', () {
    final violations = validatePavilions([
      const SeedPavilion(
        sourceKey: 'a',
        name: 'A',
        latitude: null,
        longitude: null,
      ),
      const SeedPavilion(
        sourceKey: 'a',
        name: 'A',
        latitude: 1,
        longitude: null,
      ),
    ]);
    expect(violations, hasViolation('pavilions[1].sourceKey', '重複'));
    expect(violations, hasViolation('pavilions[1]', '対'));
  });

  test('YAML の知らない項目（書き間違い）は入力エラーにする', () {
    final tmp = Directory.systemTemp.createTempSync('seed-typo-');
    try {
      for (final f in Directory(
        sampleDir.revision,
      ).listSync().whereType<File>()) {
        f.copySync('${tmp.path}/${f.uri.pathSegments.last}');
      }
      final yaml = File('${tmp.path}/revision.yaml');
      yaml.writeAsStringSync(
        yaml.readAsStringSync().replaceFirst(
          'positionX: -30, positionZ: -60, latitude: null',
          'positionX: -30, positionZ: -60, lat: 34.65, latitude: null',
        ),
      );
      expect(
        () => readSeedBundle(dir: tmp.path, pavilionsPath: sampleDir.pavilions),
        throwsA(
          isA<SeedInputException>().having(
            (e) => e.message,
            'message',
            contains('landmarks[0].lat'),
          ),
        ),
      );
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  test('上限を超える素材は中身を読まず、サイズの違反だけを報告する', () async {
    final tmp = Directory.systemTemp.createTempSync('seed-big-');
    try {
      for (final f in Directory(
        sampleDir.revision,
      ).listSync().whereType<File>()) {
        f.copySync('${tmp.path}/${f.uri.pathSegments.last}');
      }
      // 5 MiB を超える疎なファイル（中身は書かず、大きさだけ作る）。
      final raf = File('${tmp.path}/photo.png').openSync(mode: FileMode.write);
      raf.truncateSync(5 * 1024 * 1024 + 1);
      raf.closeSync();

      final bundle = readSeedBundle(
        dir: tmp.path,
        pavilionsPath: sampleDir.pavilions,
      );
      expect(bundle.photo.bytes, isEmpty, reason: '中身は読まない');
      expect(bundle.photo.byteLength, 5 * 1024 * 1024 + 1);
      final violations = validateSeed(
        input: bundle.input,
        pavilionKeys: {for (final p in bundle.pavilions) p.sourceKey},
        photo: facts(bundle.input.photo, bundle.photo),
        map: facts(bundle.input.map, bundle.map),
      );
      expect(violations.where((v) => v.path.startsWith('assets.photo')), [
        isA<SeedViolation>().having(
          (v) => v.message,
          'message',
          contains('5 MiB'),
        ),
      ]);
    } finally {
      tmp.deleteSync(recursive: true);
    }
  });

  group('開始点の表示名', () {
    test('自由探索の欠落・空・重複と、周辺探索の表示名を拒否する', () {
      final missing = withMode(
        raw,
        .free,
        (m) => m.copyWith(
          spawns: [m.spawns.first.copyWith(label: null), ...m.spawns.skip(1)],
        ),
      );
      expect(
        validate(missing),
        hasViolation('modes[0].spawns[0].label', '表示名'),
      );

      final blank = withMode(
        raw,
        .free,
        (m) => m.copyWith(
          spawns: [
            m.spawns.first.copyWith(label: '  '),
            ...m.spawns.skip(1),
          ],
        ),
      );
      expect(validate(blank), hasViolation('modes[0].spawns[0].label', '表示名'));

      final duplicated = withMode(
        raw,
        .free,
        (m) => m.copyWith(
          spawns: [for (final spawn in m.spawns) spawn.copyWith(label: '同じ')],
        ),
      );
      expect(validate(duplicated), hasViolation('modes[0].spawns', '重複'));

      final nearLabeled = withMode(
        raw,
        .near,
        (m) => m.copyWith(spawns: [m.spawns.single.copyWith(label: '近く')]),
      );
      expect(
        validate(nearLabeled),
        hasViolation('modes[1].spawns[0].label', '自由探索'),
      );
    });

    test('uk-pavilion r2 の自由探索は東ゲートと西ゲート', () {
      final bundle = readSeedBundle(
        dir: '../content/seeds/uk-pavilion/r2',
        pavilionsPath: sampleDir.pavilions,
      );
      final violations = validateSeed(
        input: bundle.input,
        pavilionKeys: {
          for (final pavilion in bundle.pavilions) pavilion.sourceKey,
        },
        photo: facts(bundle.input.photo, bundle.photo),
        map: facts(bundle.input.map, bundle.map),
      );
      expect(violations, isEmpty);
      final free = bundle.input.modes.firstWhere((mode) => mode.mode == .free);
      expect(
        free.spawns.map(
          (spawn) =>
              (spawn.label, spawn.positionX, spawn.positionZ, spawn.yawDegrees),
        ),
        [('東ゲート', 580.0, 123.4, 270.0), ('西ゲート', -572.3, 342.9, 124.0)],
      );
    });

    test('uk-pavilion r3 は周辺探索の開始点と撮影ゴールの両方から解説対象に届く', () {
      final bundle = readSeedBundle(
        dir: '../content/seeds/uk-pavilion/r3',
        pavilionsPath: sampleDir.pavilions,
      );
      final violations = validateSeed(
        input: bundle.input,
        pavilionKeys: {
          for (final pavilion in bundle.pavilions) pavilion.sourceKey,
        },
        photo: facts(bundle.input.photo, bundle.photo),
        map: facts(bundle.input.map, bundle.map),
      );
      expect(violations, isEmpty);
      // ガイドの選定（NearbyStructureSelector）は代表位置から 30 m 以内を対象にする（#213）。
      final structure = bundle.input.structures.single;
      double distanceFrom(double x, double z) => math.sqrt(
        math.pow(structure.positionX - x, 2) +
            math.pow(structure.positionZ - z, 2),
      );
      final near = bundle.input.modes.firstWhere((mode) => mode.mode == .near);
      final spawn = near.spawns.single;
      final goal = bundle.input.goal;
      expect(distanceFrom(spawn.positionX, spawn.positionZ), lessThan(30));
      expect(distanceFrom(goal.x, goal.z), lessThan(30));
    });

    test('uk-pavilion r4 は r3 に解説対象を足しただけで、資料がそろっている（#227）', () {
      SeedBundle read(String revision) => readSeedBundle(
        dir: '../content/seeds/uk-pavilion/$revision',
        pavilionsPath: sampleDir.pavilions,
      );
      final r3 = read('r3');
      final r4 = read('r4');
      final violations = validateSeed(
        input: r4.input,
        pavilionKeys: {for (final pavilion in r4.pavilions) pavilion.sourceKey},
        photo: facts(r4.input.photo, r4.photo),
        map: facts(r4.input.map, r4.map),
      );
      expect(violations, isEmpty);
      // 版番号と足した structures 以外は r3 と同じ（写真・正解・歩行領域・開始点を変えない）。
      String body(String revision) =>
          File('../content/seeds/uk-pavilion/$revision/revision.yaml')
              .readAsLinesSync()
              .skipWhile((line) => line.startsWith('#'))
              .join('\n');
      final r4Body = body('r4').replaceFirst('revisionNo: 4', 'revisionNo: 3');
      expect(r4Body, startsWith(body('r3')));
      // 英国パビリオンの資料は r3 のまま、先頭に残す。
      final structures = r4.input.structures;
      final uk = r3.input.structures.single;
      expect(
        (
          structures.first.name,
          structures.first.positionX,
          structures.first.facts,
        ),
        (uk.name, uk.positionX, uk.facts),
      );
      expect(structures, hasLength(20));
      expect(structures.map((s) => s.pavilionKey).toSet(), hasLength(20));
      for (final structure in structures) {
        expect(structure.facts.trim(), isNotEmpty, reason: structure.name);
        expect(
          structure.fallbackText,
          startsWith('${structure.name}です。'),
          reason: structure.name,
        );
        expect(structure.sources, isNotEmpty, reason: structure.name);
      }
    });

    test('uk-pavilion r5 は r4 に、会場図のパビリオンの解説対象を足しただけ（#239）', () {
      SeedBundle read(String revision) => readSeedBundle(
        dir: '../content/seeds/uk-pavilion/$revision',
        pavilionsPath: sampleDir.pavilions,
      );
      final r4 = read('r4');
      final r5 = read('r5');
      final violations = validateSeed(
        input: r5.input,
        pavilionKeys: {for (final pavilion in r5.pavilions) pavilion.sourceKey},
        photo: facts(r5.input.photo, r5.photo),
        map: facts(r5.input.map, r5.map),
      );
      expect(violations, isEmpty);
      String body(String revision) =>
          File('../content/seeds/uk-pavilion/$revision/revision.yaml')
              .readAsLinesSync()
              .skipWhile((line) => line.startsWith('#'))
              .join('\n');
      // 版番号と足した structures 以外は r4 と同じ（既存 20 件の資料も変えない）。
      expect(
        body('r5').replaceFirst('revisionNo: 5', 'revisionNo: 4'),
        startsWith(body('r4')),
      );
      final keys = [for (final s in r5.input.structures) s.pavilionKey];
      expect(keys.toSet(), hasLength(keys.length));
      expect(keys.take(r4.input.structures.length), [
        for (final s in r4.input.structures) s.pavilionKey,
      ]);
      // 緯度経度のある実在のパビリオンは、出典を確認できなかったコモンズE館（sv20）を除いてすべて入る。
      final located = {
        for (final p in r5.pavilions)
          if (p.latitude != null) p.sourceKey,
      };
      expect(located.difference(keys.toSet()), {'sv20'});
      for (final structure in r5.input.structures) {
        expect(structure.facts.trim(), isNotEmpty, reason: structure.name);
        expect(
          structure.fallbackText,
          startsWith('${structure.name}です。'),
          reason: structure.name,
        );
        expect(structure.sources, isNotEmpty, reason: structure.name);
      }
    });
  });

  test('YAML の項目が足りないと入力エラーにする', () {
    expect(
      () => readSeedBundle(
        dir: 'test/unit/seed/missing',
        pavilionsPath: sampleDir.pavilions,
      ),
      throwsA(isA<SeedInputException>()),
    );
  });
}
