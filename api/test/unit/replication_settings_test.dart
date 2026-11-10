import 'package:photohunt_server/src/infrastructure/config/replication_settings.dart';
import 'package:test/test.dart';

const full = {
  'DB_REPLICA_BUCKET': 'b',
  'DB_REPLICA_PREFIX': 'replica/local',
  'DB_WRITER_OWNER_OBJECT': 'owner/local/writer.json',
  'LITESTREAM_SOCKET_PATH': '/var/run/litestream.sock',
  'RELEASE_ID': 'r1',
};

void main() {
  test('必須値がそろっていれば読める', () {
    final s = ReplicationSettings.fromEnvironment(
      full,
      dbPath: '/data/db.sqlite',
    );
    expect(s.replicaBucket, 'b');
    expect(s.maintenanceMode, isFalse);
    expect(s.emulatorHost, isNull);
  });

  test('欠けた値を全部挙げて失敗する', () {
    expect(
      () =>
          ReplicationSettings.fromEnvironment({'RELEASE_ID': 'r'}, dbPath: 'x'),
      throwsA(
        isA<ConfigurationException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('DB_REPLICA_BUCKET'),
            contains('LITESTREAM_SOCKET_PATH'),
          ),
        ),
      ),
    );
  });

  test('所有権がレプリカ prefix の下にあると失敗する', () {
    expect(
      () => ReplicationSettings.fromEnvironment({
        ...full,
        'DB_WRITER_OWNER_OBJECT': 'replica/local/writer.json',
      }, dbPath: 'x'),
      throwsA(isA<ConfigurationException>()),
    );
  });

  test('保守モードは複製の設定が要らない', () {
    final s = ReplicationSettings.fromEnvironment({
      'MAINTENANCE_MODE': 'true',
      'RELEASE_ID': 'r',
    }, dbPath: 'x');
    expect(s.maintenanceMode, isTrue);
    expect(s.maintenanceReason, 'MAINTENANCE');
  });

  test('保守理由が不正なら失敗する', () {
    expect(
      () => ReplicationSettings.fromEnvironment({
        'MAINTENANCE_MODE': 'true',
        'MAINTENANCE_REASON': 'x',
        'RELEASE_ID': 'r',
      }, dbPath: 'x'),
      throwsA(isA<ConfigurationException>()),
    );
  });

  test('Cloud Run では STORAGE_EMULATOR_HOST を拒否する', () {
    for (final key in ['K_SERVICE', 'CLOUD_RUN_JOB']) {
      expect(
        () => ReplicationSettings.fromEnvironment({
          ...full,
          key: 'x',
          'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
        }, dbPath: 'x'),
        throwsA(isA<ConfigurationException>()),
      );
    }
    // emulator がなければ Cloud Run でも読める。
    expect(
      ReplicationSettings.fromEnvironment({
        ...full,
        'K_SERVICE': 'api',
      }, dbPath: 'x').emulatorHost,
      isNull,
    );
  });
}
