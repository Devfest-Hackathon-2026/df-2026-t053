import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const _previous = 'migrations/20261108021530702';

List<String> get _versions =>
    File('migrations/migration_registry.txt')
        .readAsLinesSync()
        .where((line) => RegExp(r'^\d{17}$').hasMatch(line))
        .map((version) => 'migrations/$version')
        .toList();

String get _current => _versions.last;

const _tables = [
  'asset',
  'challenge',
  'challenge_revision',
  'mode_config',
  'spawn_point',
  'credit',
  'pavilion',
  'landmark',
  'structure',
  'structure_source',
  'user_profile',
  'play_session',
  'shot',
  'best_score',
];

Map<String, Object?> _snapshot(
  Database db,
  Map<String, List<String>> columns,
) => {
  for (final projection in columns.entries)
    projection.key: db
        .select(
          'SELECT ${projection.value.map((name) => '"$name"').join(',')} FROM "${projection.key}" ORDER BY id',
        )
        .map(
          (row) => {
            for (final entry in row.entries)
              if (entry.key != 'model_asset_id') entry.key: entry.value,
          },
        )
        .toList(),
};

void main() {
  for (final upgrade in [false, true]) {
    test(
      upgrade ? 'モデル参照列を削除し、他の列・子データ・asset行を保持する' : '新規DBはモデル参照列なしで版を登録できる',
      () {
        expect(_current, isNot(_previous), reason: '列削除migrationを生成してから検証する');
        final db = sqlite3.openInMemory();
        try {
          db.execute(
            File('${upgrade ? _previous : _current}/definition.sql')
                .readAsStringSync(),
          );
          db.execute('PRAGMA foreign_keys=ON');
          _insertSample(db, legacyModel: upgrade);
          if (upgrade) {
            final columns = {
              for (final table in _tables)
                table: db
                    .select('PRAGMA table_info("$table")')
                    .map((row) => row['name'].toString())
                    .where((name) => name != 'model_asset_id')
                    .toList(),
            };
            final before = _snapshot(db, columns);
            // Serverpod 4.1.1のSqliteDatabaseMigrationRunnerと同じ境界で適用する。
            db.execute('PRAGMA foreign_keys=OFF');
            for (final migration in _versions.skip(
              _versions.indexOf(_previous) + 1,
            )) {
              db.execute(File('$migration/migration.sql').readAsStringSync());
            }
            db.execute('PRAGMA foreign_keys=ON');
            expect(_snapshot(db, columns), before);
            expect(
              db.select('SELECT id FROM asset ORDER BY id').map((r) => r['id']),
              [1, 2, 3],
            );
            // 旧モデルassetは残るが、どのasset外部キーにも参照されない。
            for (final table in _tables) {
              for (final foreignKey in db.select(
                'PRAGMA foreign_key_list("$table")',
              )) {
                if (foreignKey['table'] != 'asset') continue;
                final column = foreignKey['from'];
                expect(
                  db.select('SELECT 1 FROM "$table" WHERE "$column" = 2'),
                  isEmpty,
                );
              }
            }
          }
          expect(db.select('PRAGMA foreign_key_check'), isEmpty);
          expect(
            db.select('PRAGMA integrity_check').single.values.single,
            'ok',
          );
          expect(db.select('PRAGMA foreign_keys').single.values.single, 1);
          expect(
            db
                .select('PRAGMA table_info(challenge_revision)')
                .map((row) => row['name']),
            isNot(contains('model_asset_id')),
          );
          _expectConstraints(db);
        } finally {
          db.close();
        }
      },
    );
  }
}

void _insertSample(Database db, {required bool legacyModel}) {
  for (final id in [1, if (legacyModel) 2, 3]) {
    db.execute(
      'INSERT INTO asset (id,sha256,object_path,content_type,byte_length,created_at) VALUES (?,?,?,?,?,?)',
      [id, '$id' * 64, 'image-$id.png', 'image/png', 10, 0],
    );
  }
  db.execute(
    "INSERT INTO challenge (id,slug,title,created_at) VALUES (1,'sample','title',0)",
  );
  db.execute(
    '''INSERT INTO challenge_revision
    (id,challenge_id,revision_no,scene_profile,scoring_version,photo_asset_id,${legacyModel ? 'model_asset_id,' : ''}map_asset_id,photo_alt,map_bounds_xz,eye_height_m,shot_fov_deg,goal_x,goal_y,goal_z,goal_yaw_deg,goal_pitch_deg,story,highlight,published_at,created_at)
    VALUES (1,1,1,'bundled-v1','v1',1,${legacyModel ? '2,' : ''}3,'photo','{}',1.6,50,0,1.6,0,0,0,'story','highlight',NULL,0)''',
  );
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
  db.execute(
    "INSERT INTO pavilion (id,source_key,name,lat,lon) VALUES (1,'sample','pavilion',34.0,135.0)",
  );
  db.execute(
    "INSERT INTO landmark (id,revision_id,pavilion_id,display_name,pos_x,pos_z) VALUES (1,1,1,'landmark',1,2)",
  );
  // 子データは下書きのうちに入れ、最後に公開する（公開後の追加は #26 のトリガーが拒否する）。
  db.execute('UPDATE challenge_revision SET published_at=1 WHERE id=1');
  db.execute('UPDATE challenge SET current_revision_id=1 WHERE id=1');
  db.execute(
    "INSERT INTO user_profile (id,auth_user_id,nickname,created_at) VALUES (1,zeroblob(16),'nickname',0)",
  );
  db.execute(
    "INSERT INTO play_session (id,request_id,revision_id,mode,spawn_point_id,user_profile_id,started_at,expires_at) VALUES (zeroblob(16),zeroblob(16),1,'free',1,1,0,7200000)",
  );
  db.execute(
    "INSERT INTO shot (id,request_id,play_session_id,x,y,z,yaw_deg,pitch_deg,fov_deg,distance_m,yaw_diff_deg,pitch_diff_deg,score,rank_at_submission,best_score_at_submission,nickname_at_submission,best_achieve_time_at_submission,created_at) VALUES (1,zeroblob(16),zeroblob(16),0,1.6,0,0,0,50,0,0,0,1000,1,1000,'nickname',0,0)",
  );
  db.execute(
    "INSERT INTO best_score (id,user_profile_id,revision_id,mode,shot_id,score,achieved_at) VALUES (1,1,1,'free',1,1000,0)",
  );
}

void _expectConstraints(Database db) {
  // テーブル再作成で失われやすいCHECKと、触れていないテーブルの手書き定義も検証する。
  final schema = {
    for (final row in db.select(
      'SELECT name,sql FROM sqlite_master WHERE sql IS NOT NULL',
    ))
      row['name']: row['sql'].toString(),
  };
  for (final entry in {
    'asset': ['asset_sha256_format_ck', 'asset_byte_length_ck'],
    'challenge_revision': ['challenge_revision_map_bounds_json_ck'],
    'mode_config': ['mode_config_walkable_json_ck'],
    'shot': ['shot_score_range_ck'],
    'shot_no_update': ["RAISE(ABORT, 'shot is immutable')"],
    'best_score_ranking_idx': [
      '"score" DESC',
      '"achieved_at" ASC',
      '"user_profile_id" ASC',
    ],
  }.entries) {
    for (final expected in entry.value) {
      expect(schema[entry.key], contains(expected), reason: entry.key);
    }
  }
  expect(
    () => db.execute(
      "UPDATE challenge_revision SET map_bounds_xz='invalid' WHERE id=1",
    ),
    throwsA(isA<SqliteException>()),
  );
  expect(
    () => db.execute(
      'UPDATE challenge_revision SET photo_asset_id=999 WHERE id=1',
    ),
    throwsA(isA<SqliteException>()),
  );
  expect(
    () => db.execute('DELETE FROM challenge_revision WHERE id=1'),
    throwsA(isA<SqliteException>()),
  );
}
