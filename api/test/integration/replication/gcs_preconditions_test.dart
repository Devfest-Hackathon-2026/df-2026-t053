import 'dart:io';

import 'package:photohunt_server/src/infrastructure/database/replication/gcs_object_client.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/writer_ownership.dart';
import 'package:test/test.dart';

import '../../support/access_tokens.dart';

/// fake-gcs-server に対して、所有権が頼る GCS の条件付き操作を確かめる。
/// `mise //infrastructure/local:up` で gcs を起動し、
/// `STORAGE_EMULATOR_HOST=http://localhost:4443` を付けて実行する。
void main() {
  final host = Platform.environment['STORAGE_EMULATOR_HOST'];
  if (host == null || host.isEmpty) {
    test('STORAGE_EMULATOR_HOST が未設定のためスキップ', () {}, skip: true);
    return;
  }

  const bucket = 'photohunt-db-local';
  late HttpGcsObjectClient gcs;
  late String object;

  setUp(() {
    gcs = HttpGcsObjectClient(emulatorHost: host, tokens: NoAccessTokens());
    object = 'owner/test-${DateTime.now().microsecondsSinceEpoch}/writer.json';
  });
  tearDown(() => gcs.close());

  test('同じオブジェクトの2回目の作成は 412 で失敗する', () async {
    final generation = await gcs.createIfAbsent(bucket, object, '{"a":1}');
    expect(generation, isNotEmpty);
    await expectLater(
      gcs.createIfAbsent(bucket, object, '{"a":2}'),
      throwsA(isA<GcsPreconditionFailed>()),
    );
    final current = await gcs.read(bucket, object);
    expect(current!.content, '{"a":1}');
    expect(current.generation, generation);
  });

  test('古い generation を指定した削除は失敗し、一致する削除は成功する', () async {
    final first = await gcs.createIfAbsent(bucket, object, 'x');
    await expectLater(
      gcs.deleteIfGeneration(bucket, object, '${int.parse(first) + 1}'),
      throwsA(isA<GcsPreconditionFailed>()),
    );
    expect(await gcs.read(bucket, object), isNotNull);

    await gcs.deleteIfGeneration(bucket, object, first);
    expect(await gcs.read(bucket, object), isNull);
  });

  test('所有権: 取得 → 2つ目は拒否 → 解放 → 再取得', () async {
    WriterOwnershipManager manager(String id) => WriterOwnershipManager(
      gcs: gcs,
      bucket: bucket,
      object: object,
      releaseId: 'test',
      newOwnerId: () => id,
    );
    final first = await manager('a').acquire();
    await expectLater(
      manager('b').acquire(),
      throwsA(isA<WriterOwnershipUnavailable>()),
    );
    await manager('a').release(first);
    final second = await manager('b').acquire();
    expect(second.ownerId, 'b');
    await manager('b').release(second);
  });
}
