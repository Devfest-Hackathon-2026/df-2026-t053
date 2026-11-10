import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'seed_fixture.dart';

/// 最新の migration の definition.sql で作った DB（新規 DB と同じスキーマ）。
Database _freshDb() {
  final registry = File('migrations/migration_registry.txt')
      .readAsLinesSync()
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .last;
  final db = sqlite3.openInMemory();
  db.execute(File('migrations/$registry/definition.sql').readAsStringSync());
  db.execute('PRAGMA foreign_keys = ON;');
  return db;
}

/// 素材置き場の代わり。置いたものを覚え、同じパスの別内容は拒否する。
class _MemoryMedia() implements SeedMediaStore {
  final Map<String, Uint8List> objects = {};

  @override
  Future<bool> putIfAbsent(
    String objectPath,
    Uint8List bytes,
    String contentType,
  ) async {
    final existing = objects[objectPath];
    if (existing == null) {
      objects[objectPath] = bytes;
      return true;
    }
    if (existing.length != bytes.length) {
      throw SeedConflictException('$objectPath に別の内容がある');
    }
    return false;
  }
}

/// 業務テーブルの全行。再実行で DB が変わらないことを比べる。
Map<String, List<List<Object?>>> _dump(Database db) => {
  for (final table in const [
    'pavilion',
    'asset',
    'challenge',
    'challenge_revision',
    'mode_config',
    'spawn_point',
    'landmark',
    'credit',
    'structure',
    'structure_source',
  ])
    table: db
        .select('SELECT * FROM "$table" ORDER BY id')
        .map((r) => r.values.toList())
        .toList(),
};

void main() {
  late Database db;
  late SqliteSeedStore store;
  late _MemoryMedia media;
  late LoadSeedRevision load;
  final now = DateTime.utc(2026, 11, 8, 12);

  setUp(() {
    db = _freshDb();
    store = SqliteSeedStore(db);
    media = _MemoryMedia();
    load = LoadSeedRevision(store: store, media: media, clock: () => now);
  });
  tearDown(() => db.close());

  Future<LoadSeedLoaded> loadSample([SeedBundle? bundle]) async {
    final result = await load.execute(bundle ?? sampleBundle());
    return result as LoadSeedLoaded;
  }

  SeedBundle revision2() {
    final b = sampleInput();
    return bundleOf(
      b.copyWith(revision: b.revision.copyWith(revisionNo: 2, story: '第 2 版')),
    );
  }

  test('下書きとして登録し、素材を内容ハッシュ付きのパスに置く', () async {
    final result = await loadSample();
    expect(result.outcome, SeedLoadOutcome.inserted);
    expect(result.uploaded, hasLength(2));
    for (final path in result.uploaded) {
      expect(path, matches(RegExp(r'^media/[0-9a-f]{64}/(photo|map)\.png$')));
    }

    final revision = db.select(
      'SELECT * FROM challenge_revision WHERE id = ?',
      [result.revisionId],
    ).single;
    expect(revision['published_at'], isNull);
    expect(revision['goal_y'], 1.6);
    expect(revision['seed_digest'], matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(
      db.select('SELECT current_revision_id FROM challenge').single.values,
      [null],
    );
    expect(db.select("SELECT count(*) AS n FROM spawn_point").single['n'], 4);
    expect(
      db
          .select("SELECT mode FROM mode_config ORDER BY id")
          .map((r) => r['mode']),
      ['free', 'near'],
    );
    expect(
      db.select('SELECT count(*) AS n FROM structure_source').single['n'],
      1,
    );
    final asset = db.select('SELECT * FROM asset ORDER BY id').first;
    expect(asset['object_path'], result.uploaded.first);
    expect(
      asset['byte_length'],
      File('${sampleDir.revision}/photo.png').lengthSync(),
    );
  });

  test('入口名のない旧公開r1を保持し、同梱r2へ更新して再実行できる', () async {
    final old = await loadSample();
    // label追加migration直後の旧データを再現する。公開後は変更しない。
    db.execute('UPDATE spawn_point SET label = NULL');
    await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    final oldRows = _dump(db);
    final next = readSeedBundle(
      dir: 'test/fixtures/seeds/sample-plaza/r2',
      pavilionsPath: sampleDir.pavilions,
    );
    final result = await load.execute(next, publish: true);
    if (result case LoadSeedLoaded(:final revisionId)) {
      expect(revisionId, isNot(old.revisionId));
      expect(
        db.select('SELECT current_revision_id FROM challenge').single.values,
        [revisionId],
      );
      expect(
        db
            .select(
              'SELECT s.label FROM spawn_point s '
              'JOIN mode_config m ON m.id = s.mode_config_id '
              "WHERE m.revision_id = ? AND m.mode = 'free' ORDER BY s.sort_order",
              [revisionId],
            )
            .map((r) => r['label']),
        ['西', '東', '北'],
      );
      final near = db.select(
        'SELECT s.x, s.y, s.z, s.yaw_deg FROM spawn_point s '
        'JOIN mode_config m ON m.id = s.mode_config_id '
        "WHERE m.revision_id = ? AND m.mode = 'near'",
        [revisionId],
      );
      expect(near.single.values, [10.0, 0.0, -15.0, 200.0]);
    } else {
      fail('同梱r2の検証・登録に失敗: $result');
    }
    // 旧版の子行を含めて保持。既存セッションが参照するIDも変わらない。
    final updated = _dump(db);
    for (final table in [
      'challenge_revision',
      'mode_config',
      'spawn_point',
      'landmark',
      'credit',
      'structure',
      'structure_source',
      'asset',
    ]) {
      final rows = oldRows[table];
      if (rows == null) fail('比較対象のテーブルがない: $table');
      for (final row in rows) {
        expect(updated[table], contains(equals(row)), reason: table);
      }
    }
    await load.execute(next, publish: true);
    expect(_dump(db), updated);
  });

  test('同じ入力を再実行しても DB は変わらない', () async {
    final first = await loadSample();
    final before = _dump(db);
    final again = await loadSample();
    expect(again.outcome, SeedLoadOutcome.unchanged);
    expect(again.revisionId, first.revisionId);
    expect(again.uploaded, isEmpty);
    expect(_dump(db), before);
  });

  test('同じ版番号に違う内容を入れると失敗し、何も変えない', () async {
    await loadSample();
    final before = _dump(db);
    final b = sampleInput();
    final changed = bundleOf(
      b.copyWith(revision: b.revision.copyWith(highlight: '変えた見どころ')),
    );
    await expectLater(
      load.execute(changed),
      throwsA(isA<SeedConflictException>()),
    );
    expect(_dump(db), before);
  });

  test('検証に違反する入力は、素材も DB も書かない', () async {
    final b = sampleInput();
    final invalid = bundleOf(
      b.copyWith(
        revision: b.revision.copyWith(
          goal: b.revision.goal.copyWith(pitchDegrees: 80),
        ),
      ),
    );
    final result = await load.execute(invalid);
    expect(result, isA<LoadSeedInvalid>());
    expect(media.objects, isEmpty);
    expect(db.select('SELECT count(*) AS n FROM challenge').single['n'], 0);
  });

  test('公開済みの版がある出題は、題名を変える版を登録できない', () async {
    await loadSample();
    await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    final r2 = sampleInput();
    final retitled = bundleOf(
      r2.copyWith(
        challenge: r2.challenge.copyWith(title: '別の題名'),
        revision: r2.revision.copyWith(revisionNo: 2),
      ),
    );
    final before = _dump(db);
    await expectLater(
      load.execute(retitled),
      throwsA(isA<SeedConflictException>()),
    );
    expect(_dump(db), before);
    expect(
      db.select('SELECT title FROM challenge').single['title'],
      'サンプル広場の柱',
    );
  });

  test('版がある出題は、未公開でも題名を変える版を登録できない（別の版の題名で公開されない）', () async {
    await loadSample(); // r1（サンプルの題名）
    final r2 = sampleInput();
    final retitled = bundleOf(
      r2.copyWith(
        challenge: r2.challenge.copyWith(title: '新しい題名'),
        revision: r2.revision.copyWith(revisionNo: 2),
      ),
    );
    await expectLater(
      load.execute(retitled),
      throwsA(isA<SeedConflictException>()),
    );
    // r1 は自分の入力の題名のまま公開でき、同じ入力の再投入も変更なしになる。
    await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    expect(
      db.select('SELECT title FROM challenge').single['title'],
      'サンプル広場の柱',
    );
    expect((await loadSample()).outcome, SeedLoadOutcome.unchanged);
  });

  test('未公開の版を全て消せば、題名を変えて登録し直せる', () async {
    await loadSample();
    await store.deleteDraft(slug: 'sample-plaza', revisionNo: 1);
    final raw = sampleInput();
    await loadSample(
      bundleOf(raw.copyWith(challenge: raw.challenge.copyWith(title: '新しい題名'))),
    );
    expect(db.select('SELECT title FROM challenge').single['title'], '新しい題名');
  });

  test('load と publish を同時に行い、publish が失敗したら下書きも残さない', () async {
    await loadSample();
    await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    final other = sampleInput();
    final bundle = bundleOf(
      other.copyWith(challenge: other.challenge.copyWith(slug: 'other')),
    );
    final before = _dump(db);
    // 別の出題が公開中なので publish が失敗する。
    await expectLater(
      load.execute(bundle, publish: true),
      throwsA(isA<SeedConflictException>()),
    );
    expect(_dump(db), before);
  });

  test('別の出題が公開中で公開できないなら、新しい素材を公開バケットに置かない', () async {
    await loadSample();
    await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    final uploadedBefore = Map.of(media.objects);
    final b = sampleBundle();
    final other = SeedBundle(
      input: seedRevisionFromInput(
        sampleInput().copyWith(
          challenge: sampleInput().challenge.copyWith(slug: 'other'),
        ),
      ),
      pavilions: b.pavilions,
      // まだどこにも置いていない画像。
      photo: SeedFile(
        bytes: Uint8List.fromList([...b.photo.bytes, 1]),
        byteLength: b.photo.byteLength + 1,
        sha256: 'e' * 64,
        probe: b.photo.probe,
      ),
      map: b.map,
      digest: 'other-digest',
    );
    await expectLater(
      load.execute(other, publish: true),
      throwsA(isA<SeedConflictException>()),
    );
    expect(media.objects.keys, uploadedBefore.keys);
  });

  test('load と publish を同時に行う', () async {
    final result =
        await load.execute(sampleBundle(), publish: true) as LoadSeedLoaded;
    expect(result.published, SeedPublishOutcome.published);
    expect(
      db.select('SELECT current_revision_id FROM challenge').single.values,
      [result.revisionId],
    );
    final again =
        await load.execute(sampleBundle(), publish: true) as LoadSeedLoaded;
    expect(again.outcome, SeedLoadOutcome.unchanged);
    expect(again.published, SeedPublishOutcome.unchanged);
  });

  test('写真と会場図が同じバイト列でも登録できる（同じオブジェクト名を使う）', () async {
    final b = sampleBundle();
    // 写真には比率の制約がないので、会場図と同じファイルを使える。
    final same = SeedBundle(
      input: b.input,
      pavilions: b.pavilions,
      photo: b.map,
      map: b.map,
      digest: b.digest,
    );
    final result = await load.execute(same) as LoadSeedLoaded;
    expect(result.uploaded, hasLength(1));
    expect(db.select('SELECT count(*) AS n FROM asset').single['n'], 1);
    final revision = db.select('SELECT * FROM challenge_revision').single;
    expect(revision['photo_asset_id'], revision['map_asset_id']);
  });

  test('失敗する登録では、素材を公開バケットに置かない', () async {
    await loadSample();
    expect(media.objects, hasLength(2));
    final b = sampleBundle();
    // 写真の内容だけを変え、同じ版番号で登録し直す。
    final changed = SeedBundle(
      input: b.input,
      pavilions: b.pavilions,
      photo: SeedFile(
        bytes: Uint8List.fromList([...b.photo.bytes, 0]),
        byteLength: b.photo.byteLength + 1,
        sha256: 'f' * 64,
        probe: b.photo.probe,
      ),
      map: b.map,
      digest: 'changed-digest',
    );
    await expectLater(
      load.execute(changed),
      throwsA(isA<SeedConflictException>()),
    );
    expect(media.objects, hasLength(2));
  });

  test('SQLite が自分でロールバックしても、元のエラーを返す', () async {
    await loadSample();
    // RAISE(ROLLBACK) は、トランザクションを取り消してから失敗させる。
    db.execute(
      "CREATE TRIGGER boom BEFORE UPDATE ON challenge BEGIN SELECT RAISE(ROLLBACK, 'boom'); END",
    );
    await expectLater(
      store.unpublish(slug: 'sample-plaza'),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.message,
          'message',
          contains('boom'),
        ),
      ),
    );
  });

  group('公開', () {
    test('公開すると current_revision_id が非 null の出題は 1 件だけ', () async {
      final loaded = await loadSample();
      expect(
        await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now),
        SeedPublishOutcome.published,
      );
      final current = db.select(
        'SELECT current_revision_id FROM challenge WHERE current_revision_id IS NOT NULL',
      );
      expect(current.single['current_revision_id'], loaded.revisionId);
      expect(
        db
            .select('SELECT published_at FROM challenge_revision')
            .single['published_at'],
        now.millisecondsSinceEpoch,
      );
      expect(
        await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now),
        SeedPublishOutcome.unchanged,
      );
    });

    test('新しい版の公開と、旧版への切り戻し（旧版の published_at は保つ）', () async {
      final r1 = await loadSample();
      await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
      final r2 = await loadSample(revision2());
      final later = now.add(const Duration(hours: 1));
      expect(
        await store.publish(slug: 'sample-plaza', revisionNo: 2, now: later),
        SeedPublishOutcome.published,
      );
      expect(
        await store.publish(slug: 'sample-plaza', revisionNo: 1, now: later),
        SeedPublishOutcome.switched,
      );
      expect(
        db.select('SELECT current_revision_id FROM challenge').single.values,
        [r1.revisionId],
      );
      expect(
        db
            .select(
              'SELECT id, published_at FROM challenge_revision ORDER BY id',
            )
            .map((r) => [r['id'], r['published_at']]),
        [
          [r1.revisionId, now.millisecondsSinceEpoch],
          [r2.revisionId, later.millisecondsSinceEpoch],
        ],
      );
    });

    test('別の出題が公開中なら公開しない', () async {
      await loadSample();
      await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
      final b = sampleInput();
      await loadSample(
        bundleOf(b.copyWith(challenge: b.challenge.copyWith(slug: 'other'))),
      );
      await expectLater(
        store.publish(slug: 'other', revisionNo: 1, now: now),
        throwsA(isA<SeedConflictException>()),
      );
      await store.unpublish(slug: 'sample-plaza');
      expect(
        await store.publish(slug: 'other', revisionNo: 1, now: now),
        SeedPublishOutcome.published,
      );
    });

    test('ない出題・版は SeedNotFoundException', () async {
      await expectLater(
        store.publish(slug: 'none', revisionNo: 1, now: now),
        throwsA(isA<SeedNotFoundException>()),
      );
    });
  });

  group('公開済みの版は変えられない', () {
    setUp(() async {
      await loadSample();
      await store.publish(slug: 'sample-plaza', revisionNo: 1, now: now);
    });

    test('管理用の削除は拒否する', () async {
      await expectLater(
        store.deleteDraft(slug: 'sample-plaza', revisionNo: 1),
        throwsA(isA<SeedConflictException>()),
      );
    });

    for (final sql in const [
      "UPDATE challenge_revision SET story = 'x'",
      'UPDATE challenge_revision SET published_at = NULL',
      'DELETE FROM challenge_revision',
      "UPDATE mode_config SET walkable = '{}'",
      'DELETE FROM mode_config',
      'UPDATE spawn_point SET x = 0',
      'DELETE FROM spawn_point',
      "INSERT INTO spawn_point (mode_config_id, x, y, z, yaw_deg, sort_order) SELECT id, 0, 0, 0, 0, 99 FROM mode_config LIMIT 1",
      "UPDATE landmark SET display_name = 'x'",
      'DELETE FROM landmark',
      "INSERT INTO credit (revision_id, name, sort_order) SELECT id, 'x', 9 FROM challenge_revision",
      "UPDATE credit SET name = 'x'",
      "UPDATE structure SET facts = 'x'",
      'DELETE FROM structure',
      "UPDATE structure_source SET url = 'https://x'",
      "INSERT INTO structure_source (structure_id, title, url, sort_order) SELECT id, 'x', 'https://x', 9 FROM structure",
    ]) {
      test('DB のトリガーが拒否する: $sql', () {
        expect(() => db.execute(sql), throwsA(isA<SqliteException>()));
      });
    }

    test('current_revision_id を未公開の版・別の出題の版に向けられない', () async {
      await loadSample(revision2());
      expect(
        () => db.execute(
          'UPDATE challenge SET current_revision_id = '
          '(SELECT id FROM challenge_revision WHERE revision_no = 2)',
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  test('未公開の版は子データごと削除できる', () async {
    await loadSample();
    await store.deleteDraft(slug: 'sample-plaza', revisionNo: 1);
    for (final table in const [
      'challenge_revision',
      'mode_config',
      'spawn_point',
      'landmark',
      'credit',
      'structure',
      'structure_source',
    ]) {
      expect(
        db.select('SELECT count(*) AS n FROM "$table"').single['n'],
        0,
        reason: table,
      );
    }
    // 素材と pavilion は共有なので残る。
    expect(db.select('SELECT count(*) AS n FROM asset').single['n'], 2);
  });
}
