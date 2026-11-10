import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/storage/gcs_media_store.dart';
import 'package:test/test.dart';

import '../../support/access_tokens.dart';

/// fake-gcs-server に対して、素材の配置（上書きしない・内容の照合）を確かめる。
/// `mise //infrastructure/local:up` で gcs を起動し、
/// `STORAGE_EMULATOR_HOST=http://localhost:4443` を付けて実行する。
void main() {
  final host = Platform.environment['STORAGE_EMULATOR_HOST'];
  if (host == null || host.isEmpty) {
    test('STORAGE_EMULATOR_HOST が未設定のためスキップ', () {}, skip: true);
    return;
  }

  const bucket = 'photohunt-media-local';
  late HttpGcsObjectClient gcs;
  late GcsMediaStore store;
  late String object;

  setUp(() {
    gcs = HttpGcsObjectClient(emulatorHost: host, tokens: NoAccessTokens());
    store = GcsMediaStore(gcs: gcs, bucket: bucket);
    object = 'media/test-${DateTime.now().microsecondsSinceEpoch}/photo.png';
  });
  tearDown(() => gcs.close());

  final bytes = Uint8List.fromList(List.generate(1000, (i) => i % 251));

  test('無ければ置き、同じ内容ならメタデータの照合だけで置かない', () async {
    expect(await store.putIfAbsent(object, bytes, 'image/png'), isTrue);
    final meta = await gcs.readMetadata(bucket, object);
    expect(meta!.size, bytes.length);
    expect(meta.md5Base64, isNotNull, reason: 'MD5 で照合できる');
    expect(await store.putIfAbsent(object, bytes, 'image/png'), isFalse);
  });

  test('置いた素材のメタデータに長期キャッシュの Cache-Control と Content-Type が付き、内容は同じ', () async {
    expect(await store.putIfAbsent(object, bytes, 'image/png'), isTrue);
    final json = await _objectJson(host, bucket, object);
    expect(json['cacheControl'], kMediaCacheControl);
    expect(json['contentType'], 'image/png');
    expect(json['name'], object);
    // multipart の区切りや改行が内容に混ざっていない。
    expect(await gcs.readBytes(bucket, object), bytes);
  });

  test('内容は同じでも Content-Type が違えば衝突にする', () async {
    await gcs.createBytesIfAbsent(
      bucket,
      object,
      bytes,
      'application/octet-stream',
      cacheControl: kMediaCacheControl,
    );
    await expectLater(
      store.putIfAbsent(object, bytes, 'image/png'),
      throwsA(isA<SeedConflictException>()),
    );
  });

  test('同じパスに別の内容（同じサイズ）があれば上書きせず衝突にする', () async {
    await store.putIfAbsent(object, bytes, 'image/png');
    final other = Uint8List.fromList([...bytes]..[0] = 255);
    await expectLater(
      store.putIfAbsent(object, other, 'image/png'),
      throwsA(isA<SeedConflictException>()),
    );
    expect(await gcs.readBytes(bucket, object), bytes);
  });
}

/// オブジェクトのメタデータ（JSON API の応答）を、client を通さずに読む。
Future<Map<String, Object?>> _objectJson(
  String host,
  String bucket,
  String object,
) async {
  final base = host.contains('://') ? host : 'http://$host';
  final http = HttpClient();
  try {
    final request = await http.getUrl(
      Uri.parse(
        '$base/storage/v1/b/${Uri.encodeComponent(bucket)}/o/'
        '${Uri.encodeComponent(object)}',
      ),
    );
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    expect(response.statusCode, 200);
    return switch (jsonDecode(text)) {
      final Map<String, Object?> json => json,
      _ => throw StateError('JSON オブジェクトではない'),
    };
  } finally {
    http.close(force: true);
  }
}
