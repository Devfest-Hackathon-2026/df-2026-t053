import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/storage/gcs_media_store.dart';
import 'package:test/test.dart';

import '../../support/access_tokens.dart';

/// 素材のアップロード（#101）が送る multipart の要求を、ローカルの HTTP サーバーで受けて確かめる。
void main() {
  late HttpServer server;
  late HttpGcsObjectClient gcs;
  late List<({Uri uri, String? contentType, Uint8List body})> received;
  var status = 200;

  setUp(() async {
    received = [];
    status = 200;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = BytesBuilder(copy: false);
      await request.forEach(body.add);
      received.add((
        uri: request.uri,
        contentType: request.headers.value(HttpHeaders.contentTypeHeader),
        body: body.takeBytes(),
      ));
      request.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'generation': '1'}));
      await request.response.close();
    });
    gcs = HttpGcsObjectClient(
      emulatorHost: 'http://127.0.0.1:${server.port}',
      tokens: NoAccessTokens(),
    );
  });
  tearDown(() async {
    gcs.close();
    await server.close(force: true);
  });

  // 区切り・改行に似たバイトも、そのまま送ることを確かめる。
  final bytes = Uint8List.fromList([
    ...utf8.encode('\r\n--photohunt-\r\n'),
    for (var i = 0; i < 256; i++) i,
  ]);

  test('multipart で、名前・Content-Type・Cache-Control のメタデータと内容を送る', () async {
    await gcs.createBytesIfAbsent(
      'media-bucket',
      'media/abc/photo.png',
      bytes,
      'image/png',
      cacheControl: kMediaCacheControl,
    );

    final request = received.single;
    expect(request.uri.path, '/upload/storage/v1/b/media-bucket/o');
    expect(request.uri.queryParameters, {
      'uploadType': 'multipart',
      'ifGenerationMatch': '0',
    });

    final type = ContentType.parse(request.contentType ?? '');
    expect(type.mimeType, 'multipart/related');
    final boundary = type.parameters['boundary'];
    expect(boundary, isNotNull);

    // 区切りで 2 つの部分に分ける（前置き・メタデータ・内容・終端）。
    final text = latin1.decode(request.body);
    final parts = text.split('--$boundary');
    expect(parts, hasLength(4));
    expect(parts.first, isEmpty);
    expect(parts.last, '--\r\n');

    final (metadataHeaders, metadataBody) = _split(parts[1]);
    expect(metadataHeaders, 'Content-Type: application/json; charset=UTF-8');
    expect(jsonDecode(utf8.decode(latin1.encode(metadataBody))), {
      'name': 'media/abc/photo.png',
      'contentType': 'image/png',
      'cacheControl': 'public, max-age=31536000, immutable',
    });

    final (mediaHeaders, mediaBody) = _split(parts[2]);
    expect(mediaHeaders, 'Content-Type: image/png');
    expect(latin1.encode(mediaBody), bytes);
  });

  test('区切りは要求ごとに変わる', () async {
    for (var i = 0; i < 2; i++) {
      await gcs.createBytesIfAbsent(
        'b',
        'media/$i/photo.png',
        bytes,
        'image/png',
        cacheControl: kMediaCacheControl,
      );
    }
    final boundaries = [
      for (final r in received)
        ContentType.parse(r.contentType ?? '').parameters['boundary'],
    ];
    expect(boundaries.toSet(), hasLength(2));
  });

  test('改行を含む Content-Type は送らずに拒否する', () async {
    await expectLater(
      gcs.createBytesIfAbsent(
        'b',
        'media/abc/photo.png',
        bytes,
        'image/png\r\nX-Injected: 1',
        cacheControl: kMediaCacheControl,
      ),
      throwsArgumentError,
    );
    expect(received, isEmpty);
  });

  test('既にあれば（412）GcsPreconditionFailed', () async {
    status = 412;
    await expectLater(
      gcs.createBytesIfAbsent(
        'b',
        'media/abc/photo.png',
        bytes,
        'image/png',
        cacheControl: kMediaCacheControl,
      ),
      throwsA(isA<GcsPreconditionFailed>()),
    );
  });
}

/// multipart の 1 部分を、ヘッダーと本文に分ける。部分は `\r\n` で始まり `\r\n` で終わる。
(String, String) _split(String part) {
  expect(part.startsWith('\r\n'), isTrue);
  expect(part.endsWith('\r\n'), isTrue);
  final inner = part.substring(2, part.length - 2);
  final end = inner.indexOf('\r\n\r\n');
  expect(end, greaterThan(0));
  return (inner.substring(0, end), inner.substring(end + 4));
}
