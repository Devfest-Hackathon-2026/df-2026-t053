import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/domain/ports/guide_cancellation.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_transport.dart';
import 'package:photohunt_server/src/infrastructure/google/access_token_provider.dart';
import 'package:test/test.dart';

/// `access-token` を返す（[delay] だけ待つ）。[error] があれば投げる。呼ばれた回数を数える。
class _Tokens({
  final Duration delay = Duration.zero,
  final AccessTokenException? error,
}) implements AccessTokenProvider {
  int calls = 0;

  @override
  Future<String> accessToken() async {
    calls++;
    await Future<void>.delayed(delay);
    if (error case final AccessTokenException e) throw e;
    return 'access-token';
  }
}

/// ローカルの HTTP サーバーに向けて、実際に送受信する。
void main() {
  late HttpServer server;
  late Uri endpoint;
  final requests = <HttpRequest>[];
  final bodies = <String>[];
  var handler = (HttpRequest r) async {
    r.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'status': 'completed', 'steps': []}));
    await r.response.close();
  };

  setUp(() async {
    requests.clear();
    bodies.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint = Uri.parse(
      'http://127.0.0.1:${server.port}/v1/projects/p/locations/global/interactions',
    );
    server.listen((r) async {
      requests.add(r);
      bodies.add(await utf8.decodeStream(r));
      await handler(r);
    });
  });
  tearDown(() => server.close(force: true));

  HttpGeminiTransport transport({AccessTokenProvider? tokens}) =>
      HttpGeminiTransport(tokens: tokens ?? _Tokens());

  test('音声応答はHTTP分割受信中に復号し、ヘッダー余白付きのbytesを返す', () async {
    handler = (r) async {
      r.response.headers.contentType = ContentType.json;
      final payload = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': 'audio/pcm',
                    'data': base64.encode([0, 1, 2, 3]),
                  },
                },
              ],
            },
          },
        ],
      });
      for (final byte in utf8.encode(payload)) {
        r.response.add([byte]);
        await r.response.flush();
      }
      await r.response.close();
    };
    final t = transport();
    addTearDown(t.close);
    final result = await t.post(endpoint, {
      'generationConfig': {
        'responseModalities': ['AUDIO'],
      },
    }, timeout: const Duration(seconds: 5));
    expect(result, {
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'inlineData': {
                  'mimeType': 'audio/pcm',
                  'data': Uint8List.fromList([0, 1, 2, 3]),
                },
              },
            ],
          },
        },
      ],
    });
    // 次の既存テストで用いる正常本文を復元する。
    handler = (r) async {
      r.response.write(jsonEncode({'status': 'completed', 'steps': []}));
      await r.response.close();
    };
  });

  test('トークンは Authorization: Bearer で送り、URL に載せない。キーは送らない。本文は JSON', () async {
    final t = transport();
    addTearDown(t.close);
    final response = await t.post(endpoint, {
      'model': 'm',
    }, timeout: const Duration(seconds: 5));
    expect(response['status'], 'completed');
    final r = requests.single;
    expect(r.method, 'POST');
    expect(r.uri.path, endpoint.path);
    expect(r.headers.value('authorization'), 'Bearer access-token');
    expect(r.headers.value('x-goog-api-key'), isNull);
    expect(r.uri.toString(), isNot(contains('access-token')));
    expect(jsonDecode(bodies.single), {'model': 'm'});
  });

  test(
    'トークンを取れなければ送らず、AccessTokenException を返す（callGemini は credentials）',
    () async {
      final t = transport(
        tokens: _Tokens(error: const AccessTokenException('down')),
      );
      addTearDown(t.close);
      await expectLater(
        t.post(endpoint, {}, timeout: const Duration(seconds: 5)),
        throwsA(isA<AccessTokenException>()),
      );
      await expectLater(
        callGemini(t, endpoint, {}, timeout: const Duration(seconds: 5)),
        throwsA(
          isA<GeminiCallException>().having(
            (e) => e.kind,
            'kind',
            GeminiCallFailure.credentials,
          ),
        ),
      );
      expect(requests, isEmpty);
    },
  );

  test('トークンの取得中に取り消すと、取れても接続しない', () async {
    final t = transport(
      tokens: _Tokens(delay: const Duration(milliseconds: 300)),
    );
    addTearDown(t.close);
    final cancellation = GuideCancellation();
    final pending = t.post(
      endpoint,
      {},
      timeout: const Duration(seconds: 30),
      cancellation: cancellation,
    );
    Timer(const Duration(milliseconds: 20), cancellation.cancel);
    await expectLater(pending, throwsA(isA<GuideCancelledException>()));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(requests, isEmpty);
  });

  test('トークンの取得中にタイムアウトしたら、取れても接続しない', () async {
    final t = transport(
      tokens: _Tokens(delay: const Duration(milliseconds: 300)),
    );
    addTearDown(t.close);
    await expectLater(
      t.post(endpoint, {}, timeout: const Duration(milliseconds: 20)),
      throwsA(isA<GeminiTimeoutException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(requests, isEmpty);
  });

  test('200 以外は GeminiHttpException（本文は持たない）', () async {
    handler = (r) async {
      r.response
        ..statusCode = 429
        ..write('{"error": "quota"}');
      await r.response.close();
    };
    final t = transport();
    addTearDown(t.close);
    await expectLater(
      t.post(endpoint, {}, timeout: const Duration(seconds: 5)),
      throwsA(
        isA<GeminiHttpException>().having((e) => e.status, 'status', 429),
      ),
    );
  });

  test('待ち上限を過ぎたら GeminiTimeoutException', () async {
    handler = (r) async {
      await Future<void>.delayed(const Duration(seconds: 3));
      await r.response.close();
    };
    final t = transport();
    addTearDown(t.close);
    final watch = Stopwatch()..start();
    await expectLater(
      t.post(endpoint, {}, timeout: const Duration(milliseconds: 200)),
      throwsA(isA<GeminiTimeoutException>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('取り消すと、応答を待たずに GuideCancelledException', () async {
    handler = (r) async {
      await Future<void>.delayed(const Duration(seconds: 3));
      await r.response.close();
    };
    final t = transport();
    addTearDown(t.close);
    final cancellation = GuideCancellation();
    final watch = Stopwatch()..start();
    final pending = t.post(
      endpoint,
      {},
      timeout: const Duration(seconds: 30),
      cancellation: cancellation,
    );
    Timer(const Duration(milliseconds: 200), cancellation.cancel);
    await expectLater(pending, throwsA(isA<GuideCancelledException>()));
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  /// 接続に [delay] かかる HttpClient（DNS・TLS が遅い状態の代わり）。
  HttpClient slowConnect(Duration delay) =>
      HttpClient()
        ..connectionFactory = (uri, proxyHost, proxyPort) async {
          await Future<void>.delayed(delay);
          return Socket.startConnect(InternetAddress.loopbackIPv4, server.port);
        };

  test('接続中に取り消すと、接続できても要求を送らない', () async {
    final t = HttpGeminiTransport(
      tokens: _Tokens(),
      httpClient: slowConnect(const Duration(milliseconds: 500)),
    );
    addTearDown(t.close);
    final cancellation = GuideCancellation();
    final watch = Stopwatch()..start();
    final pending = t.post(
      endpoint,
      {},
      timeout: const Duration(seconds: 30),
      cancellation: cancellation,
    );
    Timer(const Duration(milliseconds: 50), cancellation.cancel);
    await expectLater(pending, throwsA(isA<GuideCancelledException>()));
    expect(watch.elapsed, lessThan(const Duration(milliseconds: 400)));
    // 接続が終わるまで待っても、サーバーには要求が届かない。
    await Future<void>.delayed(const Duration(milliseconds: 900));
    expect(requests, isEmpty);
  });

  test('接続中にタイムアウトしたら、接続できても要求を送らない', () async {
    final t = HttpGeminiTransport(
      tokens: _Tokens(),
      httpClient: slowConnect(const Duration(milliseconds: 500)),
    );
    addTearDown(t.close);
    await expectLater(
      t.post(endpoint, {}, timeout: const Duration(milliseconds: 50)),
      throwsA(isA<GeminiTimeoutException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    expect(requests, isEmpty);
  });

  test('応答が上限を超えたら、読み込みを止めて GeminiResponseTooLargeException', () async {
    for (final chunked in [false, true]) {
      handler = (r) async {
        final body = List.filled(64 * 1024, 0x61);
        if (!chunked) r.response.contentLength = body.length;
        r.response.add(body);
        await r.response.close();
      };
      final t = HttpGeminiTransport(
        tokens: _Tokens(),
        maxResponseBytes: 16 * 1024,
      );
      addTearDown(t.close);
      await expectLater(
        t.post(endpoint, {}, timeout: const Duration(seconds: 5)),
        throwsA(isA<GeminiResponseTooLargeException>()),
        reason: chunked ? '長さを名乗らない応答' : 'Content-Length のある応答',
      );
    }
  });

  test('取消済みなら、トークンも取らずに送らない', () async {
    final tokens = _Tokens();
    final t = transport(tokens: tokens);
    addTearDown(t.close);
    final cancellation = GuideCancellation()..cancel();
    await expectLater(
      t.post(
        endpoint,
        {},
        timeout: const Duration(seconds: 5),
        cancellation: cancellation,
      ),
      throwsA(isA<GuideCancelledException>()),
    );
    expect(tokens.calls, 0);
    expect(requests, isEmpty);
  });
}
