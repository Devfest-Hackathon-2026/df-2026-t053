import 'package:photohunt_server/src/domain/ports/persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/sync_response.dart';
import 'package:test/test.dart';

String body(String status, {int txid = 42, int replicated = 42}) =>
    '{"status":"$status","path":"/data/db.sqlite","txid":$txid,'
    '"replicated_txid":$replicated}';

bool confirms(String json) =>
    SyncResponse.parse(json)
        .confirmsReplication(expectedPath: '/data/db.sqlite');

void main() {
  group('複製確認の判定', () {
    test('synced で位置が届いていれば成功', () {
      expect(confirms(body('synced')), isTrue);
    });

    test('no_change で位置が一致していれば成功', () {
      expect(confirms(body('no_change')), isTrue);
    });

    test('no_change でも複製済み位置が遅れていれば成功にしない', () {
      expect(confirms(body('no_change', txid: 43, replicated: 42)), isFalse);
    });

    test('synced でも複製済み位置が遅れていれば成功にしない', () {
      expect(confirms(body('synced', txid: 43, replicated: 42)), isFalse);
    });

    test('synced_local は根拠にしない', () {
      expect(confirms(body('synced_local')), isFalse);
    });

    test('未知の status は根拠にしない', () {
      expect(confirms(body('queued')), isFalse);
    });

    test('別の DB への応答は根拠にしない', () {
      final json = body('synced').replaceFirst('/data/db.sqlite', '/other.db');
      expect(confirms(json), isFalse);
    });
  });

  group('応答の読み取り', () {
    test('JSON でなければ ReplicationUnavailableException', () {
      expect(
        () => SyncResponse.parse('not json'),
        throwsA(isA<ReplicationUnavailableException>()),
      );
    });

    test('オブジェクトでなければ ReplicationUnavailableException', () {
      expect(
        () => SyncResponse.parse('[1]'),
        throwsA(isA<ReplicationUnavailableException>()),
      );
    });

    test('項目が足りなければ ReplicationUnavailableException', () {
      expect(
        () => SyncResponse.parse('{"status":"synced"}'),
        throwsA(isA<ReplicationUnavailableException>()),
      );
    });

    test('項目の型が違えば ReplicationUnavailableException', () {
      expect(
        () => SyncResponse.parse(body('synced').replaceFirst('42', '"42"')),
        throwsA(isA<ReplicationUnavailableException>()),
      );
    });
  });
}
