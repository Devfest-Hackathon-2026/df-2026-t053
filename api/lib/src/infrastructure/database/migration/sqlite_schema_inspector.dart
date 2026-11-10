import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../application/migration/migration_ports.dart';
import '../schema/schema_manifest.dart';

/// 作業用の DB を、整合性・外部キー・適用版で照合する（`ops verify-db` と同じ基準）。
///
/// [migrationsDirectory] は image に入れた `migrations/`。期待版は最後の版の `migration.sql` から読む。
SchemaState inspectSqliteSchema({
  required String dbPath,
  required String migrationsDirectory,
}) {
  if (!File(dbPath).existsSync()) {
    return SchemaCorrupt('DB ファイルがない: $dbPath');
  }
  final manifest = SchemaManifest.fromMigrationsDirectory(migrationsDirectory);
  final db = sqlite3.open(dbPath, mode: .readOnly);
  try {
    final integrity = db.select('PRAGMA integrity_check;');
    if (integrity.length != 1 || integrity.first.values.first != 'ok') {
      return SchemaCorrupt('integrity_check に失敗した: ${integrity.toList()}');
    }
    final violations = db.select('PRAGMA foreign_key_check;');
    if (violations.isNotEmpty) {
      return SchemaCorrupt('foreign_key_check に失敗した: ${violations.length} 件');
    }
    final Map<String, String> applied;
    try {
      applied = {
        for (final row in db.select(
          'SELECT module, version FROM serverpod_migrations;',
        ))
          if ((row['module'], row['version']) case (
            final String module,
            final String version,
          ))
            module: version,
      };
    } on SqliteException {
      return const SchemaCorrupt('serverpod_migrations がない（初期化されていない DB）');
    }
    return switch (manifest.check(applied)) {
      .ok => SchemaReady(applied),
      .needsMigration => SchemaNeedsMigration(
        applied: applied,
        expected: manifest.expected,
      ),
      .tooNew => SchemaTooNew(applied: applied, expected: manifest.expected),
    };
  } finally {
    db.close();
  }
}
