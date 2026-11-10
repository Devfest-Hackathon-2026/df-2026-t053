import 'dart:io';

import 'package:photohunt_server/src/application/migration/migration_ports.dart';
import 'package:photohunt_server/src/infrastructure/database/migration/litestream_workspace.dart';
import 'package:photohunt_server/src/infrastructure/database/migration/sqlite_schema_inspector.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late String migrations;
  late String dbPath;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('migration_inspector_');
    migrations = '${temp.path}/migrations';
    dbPath = '${temp.path}/db.sqlite';
    // image に入れる migrations/ と同じ形（最後の版の migration.sql が期待版を記録する）。
    Directory('$migrations/200').createSync(recursive: true);
    File('$migrations/migration_registry.txt').writeAsStringSync('100\n200\n');
    File('$migrations/200/migration.sql').writeAsStringSync('''
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('photohunt', '200', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '200';
''');
  });

  tearDown(() => temp.deleteSync(recursive: true));

  void createDb({String? version, bool foreignKeyViolation = false}) {
    final db = sqlite3.open(dbPath);
    try {
      if (version != null) {
        db.execute(
          'CREATE TABLE serverpod_migrations (module TEXT PRIMARY KEY, version TEXT);',
        );
        db.execute(
          "INSERT INTO serverpod_migrations VALUES ('photohunt', '$version');",
        );
      }
      if (foreignKeyViolation) {
        db.execute('CREATE TABLE parent (id INTEGER PRIMARY KEY);');
        db.execute(
          'CREATE TABLE child (id INTEGER PRIMARY KEY, '
          'parent_id INTEGER REFERENCES parent(id));',
        );
        db.execute('INSERT INTO child VALUES (1, 99);');
      }
    } finally {
      db.close();
    }
  }

  SchemaState inspect() =>
      inspectSqliteSchema(dbPath: dbPath, migrationsDirectory: migrations);

  test('期待版と一致すれば SchemaReady', () {
    createDb(version: '200');
    expect(
      inspect(),
      isA<SchemaReady>().having((s) => s.applied, 'applied', {
        'photohunt': '200',
      }),
    );
  });

  test('古い版なら SchemaNeedsMigration', () {
    createDb(version: '100');
    expect(
      inspect(),
      isA<SchemaNeedsMigration>().having((s) => s.expected, 'expected', {
        'photohunt': '200',
      }),
    );
  });

  test('新しい版なら SchemaTooNew', () {
    createDb(version: '300');
    expect(inspect(), isA<SchemaTooNew>());
  });

  test('版の表がない・ファイルがない・外部キー違反は SchemaCorrupt', () {
    expect(inspect(), isA<SchemaCorrupt>());
    createDb();
    expect(inspect(), isA<SchemaCorrupt>());
    File(dbPath).deleteSync();
    createDb(version: '200', foreignKeyViolation: true);
    expect(
      inspect(),
      isA<SchemaCorrupt>().having(
        (s) => s.reason,
        'reason',
        contains('foreign_key_check'),
      ),
    );
  });

  group('ltxFileCount', () {
    test('空の一覧なら 0（レプリカは本当に空）', () {
      expect(ltxFileCount('[]'), 0);
    });

    test('ファイルが残っていれば、その数', () {
      expect(
        ltxFileCount(
          '[{"level": 0, "min_txid": "0000000000000002", "max_txid": "0000000000000002", "size": 10, "timestamp": "2026-11-09T00:00:00Z"}]',
        ),
        1,
      );
    });

    test('一覧の形でなければ、初回と取り違えず FormatException', () {
      expect(() => ltxFileCount('{}'), throwsFormatException);
      expect(() => ltxFileCount('not json'), throwsFormatException);
    });
  });

  group('isNoReplicaMessage', () {
    test('バックアップがないときの出力だけを初回とみなす', () {
      expect(
        isNoReplicaMessage(
          'time=... level=ERROR msg="failed to run" error="no matching backup files available"',
        ),
        isTrue,
      );
    });

    test('認証・権限・通信の失敗を初回と取り違えない', () {
      for (final output in [
        'storage: object doesn\'t exist',
        'googleapi: Error 403: Forbidden',
        'dial tcp: lookup storage.googleapis.com: no such host',
      ]) {
        expect(isNoReplicaMessage(output), isFalse, reason: output);
      }
    });
  });
}
