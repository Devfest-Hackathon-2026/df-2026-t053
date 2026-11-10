import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// 「成功応答した記録は、コンテナを捨てても復元される」ことを、実際の compose で確かめる。
///
/// Docker が要るので、通常の `mise //api:test:integration` では動かさない。
/// `mise //api:test:persistence`（`mise //infrastructure/local:verify` からも呼ぶ）が
/// `PERSISTENCE_E2E=1` を付けて実行する。
void main() {
  if (Platform.environment['PERSISTENCE_E2E'] != '1') {
    test('PERSISTENCE_E2E が未設定のためスキップ', () {}, skip: true);
    return;
  }

  final localDir = Directory('../infrastructure/local').absolute.path;
  final base =
      Platform.environment['PERSISTENCE_API_BASE_URL'] ??
      'http://localhost:8080';
  final gcsBase =
      Platform.environment['PERSISTENCE_GCS_BASE_URL'] ??
      'http://localhost:4443';
  final ownerUrl =
      '$gcsBase/storage/v1/b/photohunt-db-local/o/owner%2Flocal%2Fwriter.json';

  Future<ProcessResult> compose(List<String> args) =>
      Process.run('docker', ['compose', ...args], workingDirectory: localDir);

  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body, {
    String? bearerToken,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$base/$path'));
      request.headers.contentType = ContentType.json;
      if (bearerToken != null) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $bearerToken',
        );
      }
      request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final text = await utf8.decodeStream(response);
      return {'status': response.statusCode, 'body': jsonDecode(text)};
    } finally {
      client.close(force: true);
    }
  }

  Future<int> ownerStatus() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(ownerUrl));
      return (await request.close()).statusCode;
    } finally {
      client.close(force: true);
    }
  }

  setUpAll(() async {
    await compose(['--profile', 'tools', 'down', '-v']);
    final up = await compose(['up', '-d', '--wait', 'gcs']);
    expect(up.exitCode, 0, reason: '${up.stderr}');
    final migrate = await compose([
      '--profile',
      'tools',
      'run',
      '--rm',
      'migrate',
    ]);
    expect(migrate.exitCode, 0, reason: '${migrate.stdout}${migrate.stderr}');
    final api = await compose(['up', '-d', '--wait', 'api']);
    expect(api.exitCode, 0, reason: '${api.stderr}');
  });

  tearDownAll(() async {
    await compose(['rm', '-sf', 'api']);
  });

  test('成功応答した記録は、api コンテナを捨てても復元される', () async {
    final login = await post('anonymousIdp/login', {});
    expect(login['status'], 200);
    final body = login['body'];
    if (body case {
      'refreshToken': final String refreshToken,
      'token': final String token,
    }) {
      final renamed = await post('profile/updateNickname', {
        'request': {'nickname': '復元する旅人'},
      }, bearerToken: token);
      expect(renamed['status'], 200);

      await compose(['rm', '-sf', 'api']);
      // 正常に止まれば、所有権は解放される。
      expect(await ownerStatus(), 404);

      final up = await compose(['up', '-d', '--wait', 'api']);
      expect(up.exitCode, 0, reason: '${up.stderr}');

      final profile = await post('profile/getMyProfile', {
        'request': {},
      }, bearerToken: token);
      expect(profile['status'], 200);
      expect(profile['body'], containsPair('nickname', '復元する旅人'));

      // 復元した DB に、ログインで作った認証情報が残っている。
      final refreshed = await post('jwtRefresh/refreshAccessToken', {
        'refreshToken': refreshToken,
      });
      expect(refreshed['status'], 200);
    } else {
      fail('匿名認証の応答にトークンがありません');
    }
  });

  test('所有権が残っていると2つ目の api は DB を開かずに終了する', () async {
    final second = await compose(['run', '--rm', '--no-deps', '-T', 'api']);
    expect(second.exitCode, 20);
    final out = '${second.stdout}${second.stderr}';
    expect(out, contains('writer 所有権を取得できない'));
    expect(out, isNot(contains('GCS から復元する')));
  });

  Future<ProcessResult> migrate([List<String> args = const []]) =>
      compose(['--profile', 'tools', 'run', '--rm', '-T', 'migrate', ...args]);

  test('migrate は api の稼働中に所有権を取れず、DB を変えずに終了する', () async {
    final busy = await migrate();
    final out = '${busy.stdout}${busy.stderr}';
    expect(busy.exitCode, 2, reason: out);
    expect(out, contains('writer 所有権を取得できない'));
    expect(out, isNot(contains('migration を適用する')));
    // api の所有権はそのまま残る。
    expect(await ownerStatus(), 200);
  });

  test('migrate は適用済みなら何も変えずに所有権を解放し、init はレプリカを作り直さない', () async {
    final stop = await compose(['stop', 'api']);
    expect(stop.exitCode, 0, reason: '${stop.stderr}');
    expect(await ownerStatus(), 404);

    final again = await migrate();
    final againOut = '${again.stdout}${again.stderr}';
    expect(again.exitCode, 0, reason: againOut);
    expect(againOut, contains('適用済みのため変更しない'));
    expect(await ownerStatus(), 404);

    final status = await migrate(['status']);
    expect(status.exitCode, 0, reason: '${status.stdout}${status.stderr}');
    expect('${status.stdout}', contains('DB は image と一致している'));

    final init = await migrate(['init']);
    expect(init.exitCode, 6, reason: '${init.stdout}${init.stderr}');
    expect(await ownerStatus(), 404);

    final up = await compose(['up', '-d', '--wait', 'api']);
    expect(up.exitCode, 0, reason: '${up.stderr}');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('壊れた既存のレプリカを「レプリカなし」と取り違えず、空の DB で作り直さない', () async {
    // 他のテストと混ざらないよう、別の prefix と所有権オブジェクトを使う。
    const prefix = 'replica/corrupt-e2e';
    const dir = '/replica/$prefix';
    final isolated = [
      '-e',
      'DB_REPLICA_PREFIX=$prefix',
      '-e',
      'DB_WRITER_OWNER_OBJECT=owner/local/corrupt-e2e.json',
    ];
    Future<ProcessResult> isolatedMigrate(List<String> args) => compose([
      '--profile',
      'tools',
      'run',
      '--rm',
      '-T',
      ...isolated,
      'migrate',
      ...args,
    ]);
    Future<ProcessResult> shell(String script) => compose([
      '--profile',
      'tools',
      'run',
      '--rm',
      '-T',
      '--entrypoint',
      'sh',
      'migrate',
      '-c',
      script,
    ]);

    final cleared = await shell('rm -rf $dir');
    expect(cleared.exitCode, 0, reason: '${cleared.stderr}');
    final created = await isolatedMigrate(['apply', '--init-if-missing']);
    expect(created.exitCode, 0, reason: '${created.stdout}${created.stderr}');

    // LTX ファイルを 1 つだけ残し、TXID 1 から始まらない名前にする。ファイルはあるが、
    // 復元の鎖を組めない（Litestream は「バックアップがない」と同じ文言を返す）。
    final damaged = await shell('''
set -eu
files=\$(find $dir -name '*.ltx' | sort)
keep=\$(echo "\$files" | tail -n 1)
for f in \$files; do [ "\$f" = "\$keep" ] || rm "\$f"; done
mv "\$keep" "\$(dirname "\$keep")/00000000000000f0-00000000000000f0.ltx"
find $dir -name '*.ltx' | wc -l
''');
    expect(damaged.exitCode, 0, reason: '${damaged.stdout}${damaged.stderr}');
    expect('${damaged.stdout}'.trim(), '1');

    for (final args in [
      ['init'],
      ['apply', '--init-if-missing'],
    ]) {
      final refused = await isolatedMigrate(args);
      final out = '${refused.stdout}${refused.stderr}';
      expect(refused.exitCode, 3, reason: '$args $out');
      expect(out, contains('LTX ファイルが 1 件残っている'));
      expect(out, isNot(contains('初回の DB を作る')));
    }

    // 何も書いていない（壊れたファイル 1 つのまま）。
    final after = await shell("find $dir -name '*.ltx' | wc -l");
    expect('${after.stdout}'.trim(), '1');
    await shell('rm -rf $dir');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('Litestream が止まると TEMPORARILY_UNAVAILABLE になり、後続に未複製の状態を返さない', () async {
    const findPid =
        r'for p in /proc/[0-9]*; do [ "$(cat $p/comm 2>/dev/null)" = litestream ] && echo ${p#/proc/}; done';
    final stop = await compose([
      'exec',
      '-T',
      'api',
      'bash',
      '-c',
      'kill -STOP \$($findPid)',
    ]);
    expect(stop.exitCode, 0, reason: '${stop.stderr}');

    final failed = await post('anonymousIdp/login', {});
    expect(failed['status'], 400);
    final data = (failed['body']! as Map)['data'] as Map;
    expect(data['reason'], 'TEMPORARILY_UNAVAILABLE');

    // ゲートは閉じたまま。再確認できなければプロセスが落ち、未複製の状態は返らない。
    Object? follow;
    try {
      follow = await post('anonymousIdp/login', {});
    } on Object catch (e) {
      follow = e;
    }
    if (follow is Map) {
      expect(follow['status'], isNot(200));
    }

    // 止まった Litestream は猶予内に終了せず、所有権は自動では解放されない。
    await Future<void>.delayed(const Duration(seconds: 12));
    expect(await ownerStatus(), 200);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
