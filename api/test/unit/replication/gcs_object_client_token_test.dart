import 'dart:convert';
import 'dart:io';

import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/writer_ownership.dart';
import 'package:test/test.dart';

import '../../support/access_tokens.dart';

/// `HttpGcsObjectClient` のアクセストークンの扱い（#139）。
void main() {
  group('エミュレーターなし（本番）', () {
    test('トークンの取得に失敗したら、接続する前に GcsException になる', () async {
      final tokens = FailingAccessTokens();
      // 送り先は storage.googleapis.com。トークンを接続より先に取るので、
      // 取得の失敗で止まり、外部へ接続しない。
      final client = HttpGcsObjectClient(tokens: tokens);
      addTearDown(client.close);
      await expectLater(
        client.readMetadata('bucket', 'object'),
        throwsA(
          isA<GcsException>().having(
            (e) => e.message,
            'message',
            contains('アクセストークンを取得できない'),
          ),
        ),
      );
      expect(tokens.calls, 1);
    });

    test('所有権の取得では、トークンの失敗が WriterOwnershipUnavailable になる', () async {
      // 呼び出し側（ops・migrate・start.sh）は WriterOwnershipUnavailable を終了コードに
      // 変換する。GcsException に変換していないと、この経路を通らず未処理の例外で落ちる。
      final client = HttpGcsObjectClient(tokens: FailingAccessTokens());
      addTearDown(client.close);
      final manager = WriterOwnershipManager(
        gcs: client,
        bucket: 'bucket',
        object: 'owner/writer.json',
        releaseId: 'r1',
      );
      await expectLater(
        manager.acquire(),
        throwsA(
          isA<WriterOwnershipUnavailable>().having(
            (e) => e.message,
            'message',
            contains('アクセストークンを取得できない'),
          ),
        ),
      );
    });
  });

  group('エミュレーターあり（ローカル）', () {
    late HttpServer server;
    late HttpGcsObjectClient client;
    late List<HttpRequest> requests;

    setUp(() async {
      requests = [];
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        requests.add(request);
        request.response
          ..statusCode = 404
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({}));
        await request.response.close();
      });
      client = HttpGcsObjectClient(
        emulatorHost: 'http://127.0.0.1:${server.port}',
        tokens: NoAccessTokens(),
      );
    });
    tearDown(() async {
      client.close();
      await server.close(force: true);
    });

    test('トークンを取得せず、Authorization も付けずに送る', () async {
      // NoAccessTokens は呼ばれたら失敗する。
      expect(await client.readMetadata('bucket', 'object'), isNull);
      expect(requests, hasLength(1));
      expect(requests.single.headers.value('authorization'), isNull);
    });
  });
}
