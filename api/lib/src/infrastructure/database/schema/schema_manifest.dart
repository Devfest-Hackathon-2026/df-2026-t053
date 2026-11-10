import 'dart:io';

/// DB の適用版と、image が期待する版の照合結果。
enum SchemaCheck() {
  /// 一致している。
  ok,

  /// 必要な版が未適用（migration Job が先に要る）。
  needsMigration,

  /// DB の版が新しい、または未知のモジュールがある。
  tooNew,
}

/// image に含めた migration から、モジュールごとの期待版を読む。
class const SchemaManifest(
  /// モジュール名 → 期待する版。
  final Map<String, String> expected,
) {
  /// `migrations/migration_registry.txt` の最後の版の `migration.sql` を読む。
  factory fromMigrationsDirectory(String directory) {
    final registry = File('$directory/migration_registry.txt');
    final versions = registry
        .readAsLinesSync()
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();
    if (versions.isEmpty) {
      throw StateError('migration_registry.txt に版がない');
    }
    final sql = File('$directory/${versions.last}/migration.sql');
    return SchemaManifest.parse(sql.readAsStringSync());
  }

  /// `INSERT INTO "serverpod_migrations" ... VALUES ('module', 'version', ...)` を読む。
  factory parse(String migrationSql) {
    final pattern = RegExp(
      r'INSERT INTO "serverpod_migrations"[^;]*?VALUES\s*\(\s*'
      r"'([^']+)'\s*,\s*'([^']+)'",
      dotAll: true,
    );
    final expected = {
      for (final m in pattern.allMatches(migrationSql)) m[1]!: m[2]!,
    };
    if (expected.isEmpty) {
      throw StateError('migration.sql に適用版の記録がない');
    }
    return SchemaManifest(expected);
  }

  /// [applied]（DB の `serverpod_migrations`）と照合する。
  /// 版は時刻由来の数字列なので、同じ桁数なら文字列の大小がそのまま新旧になる。
  SchemaCheck check(Map<String, String> applied) {
    var needsMigration = false;
    for (final entry in expected.entries) {
      final have = applied[entry.key];
      if (have == null) {
        needsMigration = true;
      } else if (have.compareTo(entry.value) > 0) {
        return SchemaCheck.tooNew;
      } else if (have != entry.value) {
        needsMigration = true;
      }
    }
    // 期待にないモジュールが適用済み → この image より新しい。
    if (applied.keys.any((m) => !expected.containsKey(m))) {
      return SchemaCheck.tooNew;
    }
    return needsMigration ? SchemaCheck.needsMigration : SchemaCheck.ok;
  }
}
