import 'dart:convert';

import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/writer_ownership.dart';
import 'package:test/test.dart';

/// GCS の generation 条件の挙動だけを真似るメモリ上の fake。
class _FakeGcs() implements GcsObjectClient {
  final objects = <String, ({String generation, String content})>{};
  var _next = 1;
  GcsException? failWith;

  @override
  Future<String> createIfAbsent(
    String bucket,
    String object,
    String content,
  ) async {
    if (failWith != null) throw failWith!;
    final key = '$bucket/$object';
    if (objects.containsKey(key)) throw GcsPreconditionFailed(object);
    final generation = '${_next++}';
    objects[key] = (generation: generation, content: content);
    return generation;
  }

  @override
  Future<void> deleteIfGeneration(
    String bucket,
    String object,
    String generation,
  ) async {
    final key = '$bucket/$object';
    final current = objects[key];
    if (current == null) throw GcsPreconditionFailed(object);
    if (current.generation != generation) throw GcsPreconditionFailed(object);
    objects.remove(key);
  }

  @override
  Future<({String generation, String content})?> read(
    String bucket,
    String object,
  ) async => objects['$bucket/$object'];
}

WriterOwnershipManager manager(GcsObjectClient gcs, {String id = 'owner-a'}) =>
    WriterOwnershipManager(
      gcs: gcs,
      bucket: 'photohunt-db-local',
      object: 'owner/local/writer.json',
      releaseId: 'rel-1',
      newOwnerId: () => id,
      now: () => DateTime.utc(2026, 11, 8, 12),
    );

void main() {
  test('取得すると ownerId・RELEASE_ID・起動時刻を JSON で書く', () async {
    final gcs = _FakeGcs();
    final ownership = await manager(gcs).acquire();

    expect(ownership.ownerId, 'owner-a');
    final stored = gcs.objects['photohunt-db-local/owner/local/writer.json']!;
    expect(jsonDecode(stored.content), {
      'ownerId': 'owner-a',
      'releaseId': 'rel-1',
      'startedAt': '2026-11-08T12:00:00.000Z',
    });
  });

  test('所有権が残っていると2つ目は取得できない（412 相当で起動中止）', () async {
    final gcs = _FakeGcs();
    await manager(gcs).acquire();

    await expectLater(
      manager(gcs, id: 'owner-b').acquire(),
      throwsA(
        isA<WriterOwnershipUnavailable>().having(
          (e) => e.message,
          'message',
          contains('owner-a'),
        ),
      ),
    );
  });

  test('解放すると、次の writer が取得できる', () async {
    final gcs = _FakeGcs();
    final first = await manager(gcs).acquire();
    await manager(gcs).release(first);

    final second = await manager(gcs, id: 'owner-b').acquire();
    expect(second.ownerId, 'owner-b');
  });

  test('generation が違う解放は失敗し、他人の所有権を消さない', () async {
    final gcs = _FakeGcs();
    final mine = await manager(gcs).acquire();
    // 運用者が解除し、別の writer が取り直した状態を作る。
    gcs.objects.clear();
    await manager(gcs, id: 'owner-b').acquire();

    await expectLater(
      manager(gcs).release(mine),
      throwsA(isA<WriterOwnershipUnavailable>()),
    );
    expect(gcs.objects, isNotEmpty);
  });

  test('GCS の失敗では取得できず、空の所有権で進まない', () async {
    final gcs = _FakeGcs()..failWith = const GcsException('権限がない');
    await expectLater(
      manager(gcs).acquire(),
      throwsA(isA<WriterOwnershipUnavailable>()),
    );
  });
}
