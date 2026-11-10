import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const _previous = 'migrations/20261108173011520';
const _current = 'migrations/20261108174814867';

const _tables = [
  'asset',
  'challenge',
  'challenge_revision',
  'mode_config',
  'spawn_point',
  'credit',
  'structure',
  'structure_source',
];

Map<String, List<List<Object?>>> _dump(Database db) => {
  for (final table in _tables)
    table: db
        .select('SELECT * FROM "$table" ORDER BY id')
        .map(
          (row) => [
            for (final MapEntry(:key, :value) in row.entries)
              if (key != 'seed_digest') value,
          ],
        )
        .toList(),
};

/// 手書きのトリガー名と SQL。新規 DB と更新した DB で同じであること。
Map<String, String> _triggers(Database db) => {
  for (final row in db.select(
    "SELECT name, sql FROM sqlite_master WHERE type = 'trigger' ORDER BY name",
  ))
    row['name'] as String: row['sql'] as String,
};

/// 手書きのトリガーを入れた migration（#26）。以降の migration がこれを落とさないことを検査する。
const _triggerBaseline = 'migrations/20261108174814867';

List<String> _registry() =>
    File('migrations/migration_registry.txt')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();

void main() {
  // Serverpod の migration は手書きの制約を知らない。SQLite でテーブルを作り直す
  // migration（CREATE new_ / DROP / RENAME）が足されると、その表のトリガーが黙って消える。
  // check:migration はスキーマ定義しか比べないので、ここで最新の migration を検査する。
  group('手書きのトリガーが最新の migration でも残っている', () {
    final baseline = sqlite3.openInMemory()
      ..execute(File('$_triggerBaseline/definition.sql').readAsStringSync());
    final required = _triggers(baseline);
    baseline.close();

    test('基準の migration のトリガー数', () {
      expect(required.length, greaterThanOrEqualTo(23));
    });

    test('最新 definition.sql の photohunt 版はディレクトリ名', () {
      final latest = _registry().last;
      final definition = File('migrations/$latest/definition.sql')
          .readAsStringSync();
      final migration = File('migrations/$latest/migration.sql')
          .readAsStringSync();
      expect(definition, contains("VALUES ('photohunt', '$latest'"));
      expect(definition, contains("\"version\" = '$latest'"));
      expect(migration, contains("VALUES ('photohunt', '$latest'"));
    });

    test('最新の definition.sql（新規 DB）', () {
      final latest = _registry().last;
      final db = sqlite3.openInMemory()
        ..execute(File('migrations/$latest/definition.sql').readAsStringSync());
      try {
        expect(
          _triggers(db),
          containsPair('shot_no_update', isA<String>()),
          reason: latest,
        );
        for (final entry in required.entries) {
          expect(
            _triggers(db)[entry.key],
            entry.value,
            reason:
                '$latest の definition.sql でトリガー ${entry.key} が消えた・変わった。'
                'テーブルを作り直す migration は、手書きのトリガーを引き継ぐ',
          );
        }
      } finally {
        db.close();
      }
    });

    test('最新の migration.sql（更新した DB）', () {
      final registry = _registry();
      if (registry.last == _triggerBaseline.split('/').last) return;
      // 基準の migration までを新規 DB として作り、後続の migration を順に適用する。
      final baselineIndex = registry.indexOf(_triggerBaseline.split('/').last);
      final db = sqlite3.openInMemory()
        ..execute(File('$_triggerBaseline/definition.sql').readAsStringSync());
      try {
        for (final version in registry.skip(baselineIndex + 1)) {
          db.execute('PRAGMA foreign_keys=OFF');
          db.execute(
            File('migrations/$version/migration.sql').readAsStringSync(),
          );
          db.execute('PRAGMA foreign_keys=ON');
        }
        for (final entry in required.entries) {
          expect(
            _triggers(db)[entry.key],
            entry.value,
            reason: '後続の migration を適用するとトリガー ${entry.key} が消える・変わる',
          );
        }
      } finally {
        db.close();
      }
    });
  });

  test('既存 DB を更新しても版・子データ・公開状態を失わない', () {
    final db = sqlite3.openInMemory();
    try {
      db.execute(File('$_previous/definition.sql').readAsStringSync());
      db.execute('PRAGMA foreign_keys=ON');
      _insertPublished(db);
      final before = _dump(db);

      // Serverpod 4.1.1 の SqliteDatabaseMigrationRunner と同じ境界で適用する。
      db.execute('PRAGMA foreign_keys=OFF');
      db.execute(File('$_current/migration.sql').readAsStringSync());
      db.execute('PRAGMA foreign_keys=ON');

      expect(_dump(db), before);
      expect(
        db.select('SELECT seed_digest FROM challenge_revision').single.values,
        [null],
      );
      expect(db.select('PRAGMA foreign_key_check'), isEmpty);
      expect(db.select('PRAGMA integrity_check').single.values.single, 'ok');

      // 既存の公開済みの版も、更新後は変更できない。
      expect(
        () => db.execute("UPDATE challenge_revision SET story = 'x'"),
        throwsA(isA<SqliteException>()),
      );
      expect(
        () => db.execute('DELETE FROM spawn_point'),
        throwsA(isA<SqliteException>()),
      );
      // 引き継いだ shot の更新禁止も残る。
      expect(_triggers(db), contains('shot_no_update'));
    } finally {
      db.close();
    }
  });

  test('新規 DB（definition.sql）と更新した DB のトリガーが同じ', () {
    final fresh = sqlite3.openInMemory();
    final upgraded = sqlite3.openInMemory();
    try {
      fresh.execute(File('$_current/definition.sql').readAsStringSync());
      upgraded.execute(File('$_previous/definition.sql').readAsStringSync());
      upgraded.execute(File('$_current/migration.sql').readAsStringSync());
      final triggers = _triggers(fresh);
      expect(triggers.length, greaterThanOrEqualTo(23));
      expect(_triggers(upgraded), triggers);
      // 新規 DB でも #22 の手書き制約を引き継いでいる。
      final schema =
          fresh
                  .select(
                    "SELECT group_concat(sql, ';') AS s FROM sqlite_master",
                  )
                  .single['s']
              as String;
      for (final expected in const [
        'asset_sha256_format_ck',
        'asset_byte_length_ck',
        'challenge_revision_map_bounds_json_ck',
        'mode_config_walkable_json_ck',
        'shot_score_range_ck',
        '"score" DESC',
      ]) {
        expect(schema, contains(expected));
      }
    } finally {
      fresh.close();
      upgraded.close();
    }
  });
}

void _insertPublished(Database db) {
  for (final id in [1, 2]) {
    db.execute(
      'INSERT INTO asset (id,sha256,object_path,content_type,byte_length,created_at) VALUES (?,?,?,?,?,?)',
      [id, '$id' * 64, 'media/$id/photo.png', 'image/png', 10, 0],
    );
  }
  db.execute(
    "INSERT INTO challenge (id,slug,title,created_at) VALUES (1,'sample','title',0)",
  );
  db.execute(
    '''INSERT INTO challenge_revision
    (id,challenge_id,revision_no,scene_profile,scoring_version,photo_asset_id,map_asset_id,photo_alt,map_bounds_xz,eye_height_m,shot_fov_deg,goal_x,goal_y,goal_z,goal_yaw_deg,goal_pitch_deg,story,highlight,published_at,created_at)
    VALUES (1,1,1,'bundled-v1','v1',1,2,'photo','{}',1.6,50,0,1.6,0,0,0,'story','highlight',1,0)''',
  );
  db.execute('UPDATE challenge SET current_revision_id=1 WHERE id=1');
  db.execute(
    "INSERT INTO mode_config (id,revision_id,mode,walkable) VALUES (1,1,'free','{}')",
  );
  db.execute(
    'INSERT INTO spawn_point (id,mode_config_id,x,y,z,yaw_deg,sort_order) VALUES (1,1,10,0,0,0,0)',
  );
  db.execute(
    "INSERT INTO credit (id,revision_id,name,sort_order) VALUES (1,1,'credit',0)",
  );
  db.execute(
    "INSERT INTO structure (id,revision_id,name,pos_x,pos_z,facts,fallback_text) VALUES (1,1,'structure',1,2,'facts','fallback')",
  );
  db.execute(
    "INSERT INTO structure_source (id,structure_id,title,url,sort_order) VALUES (1,1,'source','https://example.com',0)",
  );
}
