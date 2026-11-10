import 'dart:io';

import 'package:photohunt_server/seed.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'seed_fixture.dart';

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('seed-cli-'));
  tearDown(() => tmp.deleteSync(recursive: true));

  final dir = sampleDir.revision;

  group('オプションの解釈（黙って無視しない）', () {
    for (final args in <List<String>>[
      ['verify', '--dir', 'test/fixtures/seeds/sample-plaza/r1', '--publish'],
      ['load', '--dir', 'x', '--publish=true'],
      ['load', '--dir', 'x', '--puplish', 'true'],
      ['load', '--dir', 'x', '--publish', 'yes'],
      ['load', '--dir', 'x', '--dir', 'y'],
      ['load', 'dir', 'x'],
      ['verify', '--dir'],
      // コマンドに意味のないオプション。
      ['unpublish', '--slug', 'x', '--revision', '2', '--db', 'd'],
      ['verify', '--dir', 'x', '--publish', 'true'],
      ['load', '--dir', 'x', '--slug', 'other', '--db', 'd'],
      ['publish', '--slug', 'x', '--revision', '1', '--dir', 'x', '--db', 'd'],
      ['unknown-command', '--slug', 'x'],
    ]) {
      test('使い方の誤りとして exit 1: ${args.join(' ')}', () async {
        expect(await runSeed(args, const {}), 1);
      });
    }

    test('verify は DB を使わないので --db を拒否する（DB を開かない）', () async {
      final db = File('${tmp.path}/live.sqlite')..writeAsStringSync('keep');
      expect(
        await runSeed([
          'verify',
          '--dir',
          dir,
          '--pavilions',
          sampleDir.pavilions,
          '--db',
          db.path,
        ], const {}),
        1,
      );
      expect(db.readAsStringSync(), 'keep');
    });

    test('正しい指定の verify は通る', () async {
      expect(
        await runSeed([
          'verify',
          '--dir',
          dir,
          '--pavilions',
          sampleDir.pavilions,
        ], const {}),
        0,
      );
    });
  });

  test('DB が SQLite として開けないと、スタックトレースではなく exit 4', () async {
    final notDb = File('${tmp.path}/db.sqlite')
      ..writeAsStringSync('not a database');
    expect(
      await runSeed([
        'publish',
        '--slug',
        'x',
        '--revision',
        '1',
        '--db',
        notDb.path,
      ], const {}),
      4,
    );
  });

  test('素材の置き場（GCS）に届かないと exit 4で、DB は変えない', () async {
    final registry = File('migrations/migration_registry.txt')
        .readAsLinesSync()
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .last;
    final path = '${tmp.path}/db.sqlite';
    final db = sqlite3.open(path)
      ..execute(File('migrations/$registry/definition.sql').readAsStringSync());
    db.close();
    final code = await runSeed(
      ['load', '--dir', dir, '--pavilions', sampleDir.pavilions, '--db', path],
      // 使われていないポート。接続できずに GcsException になる。
      const {
        'ASSET_BUCKET': 'photohunt-media-local',
        'STORAGE_EMULATOR_HOST': 'http://127.0.0.1:1',
      },
    );
    expect(code, 4);
    final check = sqlite3.open(path, mode: OpenMode.readOnly);
    expect(check.select('SELECT count(*) AS n FROM challenge').single['n'], 0);
    expect(check.select('SELECT count(*) AS n FROM asset').single['n'], 0);
    check.close();
  });

  test('DB ファイルがないと exit 4（外部の失敗）', () async {
    expect(
      await runSeed([
        'unpublish',
        '--slug',
        'x',
        '--db',
        '${tmp.path}/none.sqlite',
      ], const {}),
      4,
    );
  });
}
