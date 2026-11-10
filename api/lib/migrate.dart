import 'dart:async';
import 'dart:io';

import 'src/application/migration/run_migration.dart';
import 'src/infrastructure/config/replication_settings.dart';
import 'src/infrastructure/database/migration/gcs_writer_lock.dart';
import 'src/infrastructure/database/migration/litestream_workspace.dart';
import 'src/infrastructure/database/replication/gcs_object_client.dart';
import 'src/infrastructure/database/replication/writer_ownership.dart';
import 'src/infrastructure/google/access_token_provider.dart';

export 'src/application/migration/run_migration.dart' show MigrationOutcome;

/// migration Job（Cloud Run Job `photohunt-migrate`、ローカルは compose の `migrate`）の本体（#34）。
///
/// ```
/// migrate apply [--init-if-missing]  未適用の migration を適用する（既定）
/// migrate init                       初回の DB を作る。レプリカがあれば作り直さない
/// migrate status                     レプリカの適用版を照合する（所有権を取らず、何も書かない）
/// ```
///
/// `--init-if-missing` はローカル環境用。本番の Job は付けずに実行し、初回だけ `init` を明示する。
///
/// 終了コード（[MigrationOutcome]）: 0 成功・無変更、1 使い方・想定外の失敗、2 所有権を取得できない、
/// 3 復元できない・レプリカがない・DB が壊れている、4 適用の失敗、5 複製を確認できない（所有権を残す）、
/// 6 init でレプリカが既にある、10 未適用の migration がある（status）、11 DB が image より新しい、
/// 21 所有権を解放できない、143 停止要求を受けて途中で終えた（複製の前。所有権は解放済み）。
/// image 内の配置（api/Dockerfile）。
const String _appDir = '/app';

Future<int> runMigrate(List<String> args, Map<String, String> env) async {
  final command = args.isEmpty ? 'apply' : args.first;
  final options = args.skip(1).toList();
  final known = switch (command) {
    'apply' => const {'--init-if-missing'},
    'init' || 'status' => const <String>{},
    _ => null,
  };
  if (known == null || options.any((o) => !known.contains(o))) {
    return _usage();
  }

  final workspace = LitestreamMigrationWorkspace(
    MigrationWorkspaceConfig(
      litestreamConfig:
          env['LITESTREAM_CONFIG'] ?? '$_appDir/config/litestream.yml',
      socketPath: env['LITESTREAM_SOCKET_PATH'] ?? '/var/run/litestream.sock',
      serverBinary: '$_appDir/main/bin/main',
      migrationsDirectory: '$_appDir/migrations',
    ),
  );
  final migration = RunMigration(
    // 所有権の設定は取得するときに読む（status は所有権を使わないので、その設定がなくても動く）。
    lock: GcsWriterLock(() => _ownershipManager(env)),
    workspace: workspace,
    report: (message) => stdout.writeln('migrate: $message'),
    stopRequested: () => workspace.stopRequested,
  );

  // Job の期限切れ・停止で SIGTERM を受けたら、停止要求を記録して復元・適用の子プロセスを止める。
  // 複製を始める前なら次の段階へ進まずに所有権を解放する。複製中なら最後に一度だけ確かめ、
  // 確認できれば解放、できなければ残す（RunMigration・LitestreamMigrationWorkspace の規則）。
  final signals = [
    for (final signal in [ProcessSignal.sigterm, ProcessSignal.sigint])
      signal.watch().listen((received) {
        stdout.writeln('migrate: $received を受けた。次の段階へ進まない');
        workspace.requestStop();
      }),
  ];
  try {
    final outcome = switch (command) {
      'init' => await migration.init(),
      'status' => await migration.status(),
      _ => await migration.apply(
        initIfMissing: options.contains('--init-if-missing'),
      ),
    };
    stdout.writeln('migrate: 結果 ${outcome.name}（終了コード ${outcome.exitCode}）');
    return outcome.exitCode;
  } finally {
    await [for (final s in signals) s.cancel()].wait;
  }
}

int _usage() {
  stderr.writeln('usage: migrate [apply [--init-if-missing] | init | status]');
  return 1;
}

WriterOwnershipManager _ownershipManager(Map<String, String> env) {
  rejectEmulatorOnCloudRun(env);
  String need(String key) => switch (env[key]) {
    final value? when value.isNotEmpty => value,
    _ => throw StateError('必須の設定がありません: $key'),
  };
  return WriterOwnershipManager(
    gcs: HttpGcsObjectClient(
      emulatorHost: env['STORAGE_EMULATOR_HOST'],
      tokens: MetadataServerAccessTokenProvider(),
    ),
    bucket: need('DB_REPLICA_BUCKET'),
    object: need('DB_WRITER_OWNER_OBJECT'),
    releaseId: need('RELEASE_ID'),
  );
}
