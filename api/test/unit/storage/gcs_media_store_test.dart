import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/storage/gcs_media_store.dart';
import 'package:test/test.dart';

typedef _Object = ({List<int> bytes, String contentType, bool withMd5});

/// メモリ上のバケット。[raceObject] があれば、作成の直前に別の書き込みが割り込んだことにする。
class _FakeMediaClient() implements GcsMediaObjectClient {
  final objects = <String, _Object>{};
  _Object? raceObject;
  int creates = 0;
  final cacheControls = <String>[];
  int byteReads = 0;

  @override
  Future<void> createBytesIfAbsent(
    String bucket,
    String object,
    List<int> bytes,
    String contentType, {
    required String cacheControl,
  }) async {
    creates++;
    cacheControls.add(cacheControl);
    if (raceObject case final raced?) {
      objects[object] = raced;
    }
    if (objects.containsKey(object)) throw GcsPreconditionFailed(object);
    objects[object] = (bytes: bytes, contentType: contentType, withMd5: true);
  }

  @override
  Future<({int size, String? md5Base64, String? contentType})?> readMetadata(
    String bucket,
    String object,
  ) async {
    final found = objects[object];
    if (found == null) return null;
    return (
      size: found.bytes.length,
      md5Base64: found.withMd5
          ? base64.encode(md5.convert(found.bytes).bytes)
          : null,
      contentType: found.contentType,
    );
  }

  @override
  Future<List<int>?> readBytes(String bucket, String object) async {
    byteReads++;
    return objects[object]?.bytes;
  }
}

void main() {
  const object = 'media/abc/photo.png';
  final bytes = Uint8List.fromList(List.generate(100, (i) => i));
  final other = Uint8List.fromList(List.generate(100, (i) => 99 - i));
  late _FakeMediaClient gcs;
  late GcsMediaStore store;

  setUp(() {
    gcs = _FakeMediaClient();
    store = GcsMediaStore(gcs: gcs, bucket: 'photohunt-media-test');
  });

  group('GcsMediaStore', () {
    test('無ければ長期キャッシュの Cache-Control を付けて置き、true', () async {
      expect(await store.putIfAbsent(object, bytes, 'image/png'), isTrue);
      expect(gcs.creates, 1);
      expect(gcs.cacheControls, ['public, max-age=31536000, immutable']);
      expect(gcs.objects[object]?.bytes, bytes);
    });

    test('同じ内容が既にあれば、メタデータの照合だけで置かずに false', () async {
      gcs.objects[object] = (
        bytes: bytes,
        contentType: 'image/png',
        withMd5: true,
      );
      expect(await store.putIfAbsent(object, bytes, 'image/png'), isFalse);
      expect(gcs.creates, 0);
      expect(gcs.byteReads, 0);
    });

    test('MD5 が得られないときは内容を読んで比べる', () async {
      gcs.objects[object] = (
        bytes: bytes,
        contentType: 'image/png',
        withMd5: false,
      );
      expect(await store.putIfAbsent(object, bytes, 'image/png'), isFalse);
      expect(gcs.byteReads, 1);
      gcs.objects[object] = (
        bytes: other,
        contentType: 'image/png',
        withMd5: false,
      );
      await expectLater(
        store.putIfAbsent(object, bytes, 'image/png'),
        throwsA(isA<SeedConflictException>()),
      );
    });

    test('同じパスに別の内容・別の Content-Type があれば衝突（上書きしない）', () async {
      gcs.objects[object] = (
        bytes: other,
        contentType: 'image/png',
        withMd5: true,
      );
      await expectLater(
        store.putIfAbsent(object, bytes, 'image/png'),
        throwsA(isA<SeedConflictException>()),
      );
      gcs.objects[object] = (
        bytes: bytes,
        contentType: 'image/jpeg',
        withMd5: true,
      );
      await expectLater(
        store.putIfAbsent(object, bytes, 'image/png'),
        throwsA(isA<SeedConflictException>()),
      );
      expect(gcs.creates, 0);
    });

    test('確かめた後に別の書き込みが作ったら、同じ内容なら false・違えば衝突', () async {
      gcs.raceObject = (bytes: bytes, contentType: 'image/png', withMd5: true);
      expect(await store.putIfAbsent(object, bytes, 'image/png'), isFalse);

      gcs
        ..objects.clear()
        ..raceObject = (bytes: other, contentType: 'image/png', withMd5: true);
      await expectLater(
        store.putIfAbsent(object, bytes, 'image/png'),
        throwsA(isA<SeedConflictException>()),
      );
    });
  });
}
