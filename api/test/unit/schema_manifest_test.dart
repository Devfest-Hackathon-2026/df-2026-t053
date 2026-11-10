import 'package:photohunt_server/src/infrastructure/database/schema/schema_manifest.dart';
import 'package:test/test.dart';

String sql(Map<String, String> versions) => versions.entries
    .map(
      (e) =>
          '''INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('${e.key}', '${e.value}', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '${e.value}';''',
    )
    .join('\n');

void main() {
  final manifest = SchemaManifest.parse(
    sql({'photohunt': '200', 'serverpod': '100'}),
  );

  test('migration.sql から期待版を読む', () {
    expect(manifest.expected, {'photohunt': '200', 'serverpod': '100'});
  });

  test('一致なら ok', () {
    expect(
      manifest.check({'photohunt': '200', 'serverpod': '100'}),
      SchemaCheck.ok,
    );
  });

  test('未適用や古い版は needsMigration', () {
    expect(manifest.check({'serverpod': '100'}), SchemaCheck.needsMigration);
    expect(
      manifest.check({'photohunt': '150', 'serverpod': '100'}),
      SchemaCheck.needsMigration,
    );
  });

  test('新しい版や未知のモジュールは tooNew', () {
    expect(
      manifest.check({'photohunt': '300', 'serverpod': '100'}),
      SchemaCheck.tooNew,
    );
    expect(
      manifest.check({'photohunt': '200', 'serverpod': '100', 'other': '1'}),
      SchemaCheck.tooNew,
    );
  });

  test('適用版の記録がなければ StateError', () {
    expect(() => SchemaManifest.parse('SELECT 1;'), throwsStateError);
  });
}
