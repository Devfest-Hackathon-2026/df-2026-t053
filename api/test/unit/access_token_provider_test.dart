import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:photohunt_server/src/infrastructure/google/access_token_provider.dart';
import 'package:test/test.dart';

/// メタデータサーバーの代わりに、ローカルの HTTP サーバーへ向けて取得する。
void main() {
  late HttpServer server;
  late Uri endpoint;
  final requests = <HttpRequest>[];
  late Future<void> Function(HttpRequest) handler;

  Future<void> respond(HttpRequest r, int status, Object? body) async {
    r.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await r.response.close();
  }

  setUp(() async {
    requests.clear();
    handler = (r) =>
        respond(r, 200, {'access_token': 'token-1', 'expires_in': 3599});
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint = Uri.parse('http://127.0.0.1:${server.port}/token');
    server.listen((r) async {
      requests.add(r);
      await handler(r);
    });
  });
  tearDown(() => server.close(force: true));

  MetadataServerAccessTokenProvider provider({
    Duration timeout = const Duration(seconds: 5),
  }) => MetadataServerAccessTokenProvider(endpoint: endpoint, timeout: timeout);

  test('Metadata-Flavor: Google を付けて取得し、期限内は使い回す', () async {
    final p = provider();
    addTearDown(p.close);
    expect(await p.accessToken(), 'token-1');
    expect(await p.accessToken(), 'token-1');
    expect(requests, hasLength(1));
    expect(requests.single.headers.value('metadata-flavor'), 'Google');
  });

  test('同時に呼ばれても、取得は 1 回にまとめる', () async {
    handler = (r) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await respond(r, 200, {'access_token': 'token-1', 'expires_in': 3599});
    };
    final p = provider();
    addTearDown(p.close);
    final tokens = await Future.wait([p.accessToken(), p.accessToken()]);
    expect(tokens, ['token-1', 'token-1']);
    expect(requests, hasLength(1));
  });

  test('期限が 60 秒を切っていれば、次の呼び出しで取り直す', () async {
    var n = 0;
    handler = (r) {
      n++;
      return respond(r, 200, {'access_token': 'token-$n', 'expires_in': 30});
    };
    final p = provider();
    addTearDown(p.close);
    expect(await p.accessToken(), 'token-1');
    expect(await p.accessToken(), 'token-2');
  });

  test('200 以外・形の違う応答・JSON でない応答は AccessTokenException', () async {
    for (final (name, status, body) in [
      ('HTTP 500', 500, {'error': 'x'}),
      ('access_token がない', 200, {'expires_in': 3599}),
      ('expires_in が数でない', 200, {'access_token': 't', 'expires_in': '3599'}),
    ]) {
      handler = (r) => respond(r, status, body);
      final p = provider();
      addTearDown(p.close);
      await expectLater(
        p.accessToken(),
        throwsA(isA<AccessTokenException>()),
        reason: name,
      );
    }
    handler = (r) async {
      r.response.write('not json');
      await r.response.close();
    };
    final p = provider();
    addTearDown(p.close);
    await expectLater(p.accessToken(), throwsA(isA<AccessTokenException>()));
  });

  test('失敗のあとは、次の呼び出しで取り直す', () async {
    handler = (r) => respond(r, 503, {});
    final p = provider();
    addTearDown(p.close);
    await expectLater(p.accessToken(), throwsA(isA<AccessTokenException>()));
    handler = (r) =>
        respond(r, 200, {'access_token': 'token-1', 'expires_in': 3599});
    expect(await p.accessToken(), 'token-1');
  });

  test('待ち上限を過ぎたら AccessTokenException', () async {
    handler = (r) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      await respond(r, 200, {'access_token': 't', 'expires_in': 3599});
    };
    final p = provider(timeout: const Duration(milliseconds: 100));
    addTearDown(p.close);
    await expectLater(p.accessToken(), throwsA(isA<AccessTokenException>()));
  });

  test('待ち上限を過ぎたら要求を中断し、接続を残さない', () async {
    // 要求を読むだけで応答を返さないサーバー。接続ごとに、クライアントが閉じたかを記録する。
    // （HttpServer は応答前の接続を数え続けるので、生のソケットで確かめる）
    final silent = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(silent.close);
    var open = 0;
    var accepted = 0;
    silent.listen((socket) {
      accepted++;
      open++;
      socket.listen((_) {}, onDone: () => open--, onError: (_) => open--);
    });
    final p = MetadataServerAccessTokenProvider(
      endpoint: Uri.parse('http://127.0.0.1:${silent.port}/token'),
      timeout: const Duration(milliseconds: 100),
    );
    addTearDown(p.close);
    for (var i = 0; i < 3; i++) {
      await expectLater(p.accessToken(), throwsA(isA<AccessTokenException>()));
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(accepted, 3);
    expect(open, 0);
  });

  test('接続できなければ AccessTokenException（例外にトークンや本文を載せない）', () async {
    await server.close(force: true);
    final p = provider();
    addTearDown(p.close);
    await expectLater(
      p.accessToken(),
      throwsA(
        isA<AccessTokenException>().having(
          (e) => e.toString(),
          'toString',
          isNot(contains('token')),
        ),
      ),
    );
  });
}
