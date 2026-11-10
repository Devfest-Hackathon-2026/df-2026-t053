import 'package:photohunt_server/src/domain/ports/persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/passthrough_executor.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/replication_confirmer.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/serial_persistence_gate.dart';
import 'package:photohunt_server/src/presentation/middleware/persistence_middleware.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

class _Confirmer() implements ReplicationConfirmer {
  final calls = <String>[];
  bool fail = false;

  @override
  Future<void> confirm({required Duration timeout}) async {
    calls.add('confirm');
    if (fail) throw const ReplicationUnavailableException('テスト');
  }
}

void main() {
  late _Confirmer confirmer;
  late List<String> events;
  late SerialPersistenceGate gate;

  Future<String> run({MaintenanceState? maintenance}) => runGated<String>(
    gate: gate,
    requestDeadline: const Duration(seconds: 30),
    maintenance: maintenance,
    call: () async {
      events.add('handler');
      return 'ok';
    },
  );

  setUp(() {
    confirmer = _Confirmer();
    events = [];
    gate = SerialPersistenceGate(
      executor: const PassthroughExecutor(),
      confirmer: confirmer,
    );
  });

  test('対象の判定: 除外以外はメソッドを問わずゲートを通す', () {
    expect(isGatedCall(Method.post, 'challenge/get'), isTrue);
    expect(isGatedCall(Method.post, '/anonymousIdp/login'), isTrue);
    // Serverpod は GET でも endpoint を実行する。素通りさせない。
    expect(isGatedCall(Method.get, 'anonymousIdp/login'), isTrue);
    expect(isGatedCall(Method.get, 'serverpod_cloud_storage'), isTrue);
    for (final path in [
      'ranking/listRankingEntries',
      'ranking/getMyRankingEntry',
    ]) {
      expect(isGatedCall(Method.post, path), isTrue);
      expect(isGatedCall(Method.get, path), isTrue);
    }
    // 除外
    expect(isGatedCall(Method.post, 'health/ping'), isFalse);
    expect(isGatedCall(Method.post, '/health/ping'), isFalse);
    expect(isGatedCall(Method.get, 'v1/websocket'), isFalse);
    expect(isGatedCall(Method.post, 'v1/websocket'), isFalse);
    expect(isGatedCall(Method.get, ''), isFalse);
    expect(isGatedCall(Method.get, 'livez'), isFalse);
    expect(isGatedCall(Method.get, 'readyz'), isFalse);
    expect(isGatedCall(Method.get, 'startupz'), isFalse);
    expect(isGatedCall(Method.options, 'challenge/get'), isFalse);
  });

  test('処理のあとに複製を確認してから結果を返す', () async {
    expect(await run(), 'ok');
    expect(events, ['handler']);
    expect(confirmer.calls, ['confirm']);
  });

  test('複製を確認できなければ TEMPORARILY_UNAVAILABLE', () async {
    confirmer.fail = true;
    await expectLater(
      run(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.unavailable)
            .having((e) => e.reason, 'reason', 'TEMPORARILY_UNAVAILABLE')
            .having((e) => e.message, 'message', isNot(contains('テスト'))),
      ),
    );
  });

  test('保守中は処理の前に拒否する', () async {
    await expectLater(
      run(maintenance: const MaintenanceState('SCHEMA_TOO_NEW')),
      throwsA(
        isA<ApiException>().having((e) => e.reason, 'reason', 'SCHEMA_TOO_NEW'),
      ),
    );
    expect(events, isEmpty);
    expect(confirmer.calls, isEmpty);
  });
}
