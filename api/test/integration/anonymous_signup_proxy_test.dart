import 'dart:convert';
import 'dart:io';

import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/generated/protocol.dart'
    show UserProfileRow;
import 'package:photohunt_server/src/infrastructure/config/anonymous_signup_settings.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:test/test.dart';

/// Cloud Runが右端にIPを付ける契約をHTTP境界から模擬する。
/// 実際のingressによる付加・偽装耐性の確認は配布先で別途必要。
void main() {
  late Serverpod pod;
  late HttpClient http;

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('data/test.sqlite$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(
      ['--mode', 'test', '--apply-migrations'],
      anonymousSignupSettings: const AnonymousSignupSettings(
        limitPerHour: 2,
        cloudRun: true,
      ),
    );
    await pod.start();
    http = HttpClient();
  });

  tearDownAll(() async {
    http.close(force: true);
    await pod.shutdown(exitProcess: false);
  });

  Future<(int, String)> login(String? forwardedFor) async {
    final request = await http.postUrl(
      Uri.parse('http://localhost:8180/anonymousIdp/login'),
    );
    request.headers.contentType = ContentType.json;
    if (forwardedFor != null) {
      request.headers.set('X-Forwarded-For', forwardedFor);
    }
    request.write('{}');
    final response = await request.close();
    return (response.statusCode, await utf8.decoder.bind(response).join());
  }

  test('同じproxy経由でも右端IP別に制限し、左側偽装では回避できない', () async {
    expect((await login('192.0.2.1, 203.0.113.1')).$1, 200);
    expect((await login('192.0.2.2, 203.0.113.1')).$1, 200);
    final denied = await login('192.0.2.3, 203.0.113.1');
    expect(denied.$1, isNot(200));
    expect(denied.$2, contains('tooManyAttempts'));
    expect((await login('192.0.2.3, 203.0.113.2')).$1, 200);
    await pod.withSession(
      (s) async => expect(await UserProfileRow.db.count(s), 3),
    );
  });

  test('IPv6を/64にまとめ、prefixを変えた場合は別の枠になる', () async {
    expect((await login('2001:db8:1:2::1')).$1, 200);
    expect((await login('2001:0db8:0001:0002::2')).$1, 200);
    final denied = await login('2001:db8:1:2::3');
    expect(denied.$1, isNot(200));
    expect(denied.$2, contains('tooManyAttempts'));
    expect((await login('2001:db8:1:3::1')).$1, 200);
    await pod.withSession(
      (s) async => expect(await UserProfileRow.db.count(s), 6),
    );
  });

  test('Cloud Runで接続元が欠落・不正なら作成せず安全なエラーを返す', () async {
    for (final header in [null, '203.0.113.1, invalid']) {
      final denied = await login(header);
      expect(denied.$1, isNot(200));
      expect(denied.$2, contains('TEMPORARILY_UNAVAILABLE'));
    }
    await pod.withSession(
      (s) async => expect(await UserProfileRow.db.count(s), 6),
    );
  });
}
