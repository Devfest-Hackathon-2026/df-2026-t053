import 'runtime_environment.dart';

/// 起動時に読む永続化まわりの設定。必須値が欠けていれば [ConfigurationException]。
/// 空 DB のまま起動させないため、黙って既定値で補わない。
class const ReplicationSettings({
  required final String dbPath,
  required final String replicaBucket,
  required final String replicaPrefix,
  required final String writerOwnerObject,
  required final String litestreamSocketPath,
  required final String releaseId,

  /// true のとき、所有権取得・DB 復元・複製を行わず、認証・業務要求を処理前に拒否する。
  required final bool maintenanceMode,

  /// 保守応答の reason（`MAINTENANCE` または `SCHEMA_TOO_NEW`）。
  required final String maintenanceReason,

  /// ローカルだけで設定する GCS emulator。production では未設定でなければならない。
  final String? emulatorHost,
}) {
  /// 環境変数から読む。[dbPath] は Serverpod の `database.filePath`。
  factory fromEnvironment(Map<String, String> env, {required String dbPath}) {
    final maintenance = env['MAINTENANCE_MODE'] == 'true';
    final missing = <String>[];
    String need(String key) {
      final value = env[key];
      if (value == null || value.isEmpty) {
        missing.add(key);
        return '';
      }
      return value;
    }

    // 保守モードは DB に触れないので、複製の設定は要らない。
    final bucket = maintenance ? '' : need('DB_REPLICA_BUCKET');
    final prefix = maintenance ? '' : need('DB_REPLICA_PREFIX');
    final owner = maintenance ? '' : need('DB_WRITER_OWNER_OBJECT');
    final socket = maintenance ? '' : need('LITESTREAM_SOCKET_PATH');
    final release = need('RELEASE_ID');
    if (missing.isNotEmpty) {
      throw ConfigurationException('必須の設定がありません: ${missing.join(', ')}');
    }
    final reason = env['MAINTENANCE_REASON'] ?? 'MAINTENANCE';
    if (reason != 'MAINTENANCE' && reason != 'SCHEMA_TOO_NEW') {
      throw ConfigurationException('MAINTENANCE_REASON が不正です: $reason');
    }
    // レプリカと所有権は別 prefix に置く（同じ prefix だと Litestream が所有権を触る）。
    if (!maintenance && (owner == prefix || owner.startsWith('$prefix/'))) {
      throw const ConfigurationException(
        'DB_WRITER_OWNER_OBJECT は DB_REPLICA_PREFIX と別の prefix に置いてください',
      );
    }
    rejectEmulatorOnCloudRun(env);
    final emulator = env['STORAGE_EMULATOR_HOST'];
    return ReplicationSettings(
      dbPath: dbPath,
      replicaBucket: bucket,
      replicaPrefix: prefix,
      writerOwnerObject: owner,
      litestreamSocketPath: socket,
      releaseId: release,
      maintenanceMode: maintenance,
      maintenanceReason: reason,
      emulatorHost: (emulator == null || emulator.isEmpty) ? null : emulator,
    );
  }
}

/// Cloud Run（サービス・Job）で
/// `STORAGE_EMULATOR_HOST` が設定されていたら拒否する。
///
/// emulator へは認証なしで接続するので、本番に紛れ込むと所有権が実 GCS の排他にならず、
/// 2 つの writer が同時に動きうる。
void rejectEmulatorOnCloudRun(Map<String, String> env) {
  final emulator = env['STORAGE_EMULATOR_HOST'] ?? '';
  if (isCloudRun(env) && emulator.isNotEmpty) {
    throw const ConfigurationException(
      'Cloud Run では STORAGE_EMULATOR_HOST を設定できません',
    );
  }
}

class const ConfigurationException(final String message) implements Exception {
  @override
  String toString() => 'ConfigurationException: $message';
}
