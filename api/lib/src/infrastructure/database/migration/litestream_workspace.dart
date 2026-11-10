import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../application/migration/migration_ports.dart';
import '../../../domain/ports/persistence_gate.dart';
import '../replication/litestream_confirmer.dart';
import 'sqlite_schema_inspector.dart';

/// migration Job のコンテナ内の配置と待ち時間。既定値は `api/scripts/start.sh` と同じ。
class const MigrationWorkspaceConfig({
  /// Litestream の設定（`dbs[].path` が [dbPath] と一致していること）。
  required final String litestreamConfig,
  required final String socketPath,

  /// 同じ image の Serverpod（`/app/main/bin/main`）。
  required final String serverBinary,

  /// image に入れた migration（`/app/migrations`）。
  required final String migrationsDirectory,
  final String dbPath = '/data/db.sqlite',
  final String restoreDirectory = '/data/restore',
  final Duration restoreTimeout = const Duration(seconds: 120),
  final Duration replicationReadyTimeout = const Duration(seconds: 30),
  final Duration syncTimeout = const Duration(seconds: 10),
  final int syncAttempts = 10,
  final Duration stopTimeout = const Duration(seconds: 5),

  /// 停止要求を受けた後、最後に一度だけ複製を確かめる時間（`api/scripts/seed.sh` と同じ）。
  /// Cloud Run の終了猶予（10 秒）のうちに、確認と Litestream の停止を終える。
  final Duration finalSyncTimeout = const Duration(seconds: 3),
});

/// 復元できるバックアップがないときの Litestream の出力（docs/specs.md「DBマイグレーション」）。
///
/// Litestream 0.5.18 は、レプリカが空のときだけでなく、ファイルが残っていても復元の鎖を
/// 組めないとき（先頭のファイルの欠落など）にも同じ文言を返す。そのためこの文言だけで初回と
/// みなさず、[ltxFileCount] でレプリカが本当に空かを確かめる。認証・権限・通信の失敗は
/// この文言にならないので、どちらにしても初回とは扱わない。
bool isNoReplicaMessage(String output) =>
    output.contains('no matching backup files');

/// `litestream ltx -level all -json` の出力から、レプリカに残っている LTX ファイルの数を読む。
///
/// 形が違えば [FormatException]（レプリカの有無を判断できないので、初回とは扱わない）。
int ltxFileCount(String json) => switch (jsonDecode(json)) {
  final List<Object?> files => files.length,
  final other => throw FormatException('LTX ファイルの一覧ではない: $other'),
};

/// 作業用の DB を Litestream と子プロセスの Serverpod で扱う。
class LitestreamMigrationWorkspace(final MigrationWorkspaceConfig _config)
    implements MigrationWorkspace {
  /// 停止要求（SIGTERM）を受けたら止めてよい子プロセス（復元と適用）。
  ///
  /// `litestream replicate` は含めない。複製の途中で止めると GCS の状態が分からなくなるので、
  /// 停止要求の後も最後に一度だけ複製を確かめてから止める（[_LitestreamRun.confirm]）。
  final Set<Process> _stoppable = {};

  bool _stopRequested = false;

  /// 停止要求を受けたときに、進行中の複製確認を打ち切る処理（確認中だけ設定する）。
  void Function()? _onStop;

  /// 停止要求を受けたか。usecase は各段階の前にこれを確かめ、次の段階へ進まない。
  bool get stopRequested => _stopRequested;

  /// 停止要求を記録し、止めてよい子プロセスを止める。止めた段階は失敗として扱われる。
  ///
  /// 子プロセスがないとき（所有権の取得中など）に受けても、記録は残る。
  void requestStop() {
    _stopRequested = true;
    for (final child in _stoppable) {
      child.kill();
    }
    _onStop?.call();
  }

  @override
  Future<void> clear() async {
    final db = File(_config.dbPath);
    for (final path in [
      _config.dbPath,
      '${_config.dbPath}-wal',
      '${_config.dbPath}-shm',
    ]) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
    // 前回の複製位置を残したまま別の DB を複製しないよう、Litestream の位置情報も消す。
    for (final path in [
      '${db.parent.path}/.${db.uri.pathSegments.last}-litestream',
      _config.restoreDirectory,
    ]) {
      final directory = Directory(path);
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    }
  }

  @override
  Future<RestoreResult> restore() async {
    final restored = '${_config.restoreDirectory}/db.sqlite';
    Directory(_config.restoreDirectory).createSync(recursive: true);
    final (exitCode, text) = await _runLitestream([
      'restore',
      '-config',
      _config.litestreamConfig,
      '-o',
      restored,
      _config.dbPath,
    ]);
    if (exitCode == 0) {
      File(restored).renameSync(_config.dbPath);
      Directory(_config.restoreDirectory).deleteSync(recursive: true);
      return .restored;
    }
    if (!isNoReplicaMessage(text)) {
      throw ReplicaRestoreFailed(
        'litestream restore が終了コード $exitCode で失敗した: $text',
      );
    }
    // 復元できるバックアップがない。レプリカが本当に空か（壊れた既存のレプリカでないか）を、
    // 復元の鎖と関係なく LTX ファイルの一覧で確かめる。空のときだけ初回とみなす。
    final remaining = await _countLtxFiles();
    if (remaining == 0) return .noReplica;
    throw ReplicaRestoreFailed(
      '復元できるバックアップがないが、レプリカに LTX ファイルが $remaining 件残っている'
      '（破損の可能性がある。空の DB で作り直さない）',
    );
  }

  Future<int> _countLtxFiles() async {
    final (exitCode, text) = await _runLitestream([
      'ltx',
      '-config',
      _config.litestreamConfig,
      '-level',
      'all',
      '-json',
      _config.dbPath,
    ], captureStderr: false);
    if (exitCode != 0) {
      throw ReplicaRestoreFailed(
        'レプリカの有無を確認できない（litestream ltx が終了コード $exitCode で失敗した）',
      );
    }
    try {
      return ltxFileCount(text);
    } on FormatException catch (e) {
      throw ReplicaRestoreFailed('レプリカの有無を確認できない: ${e.message}');
    }
  }

  /// 復元・一覧のための Litestream を実行し、終了コードと出力を返す。期限内に終わらなければ
  /// 止めて [ReplicaRestoreFailed]。停止要求でも止まる（終了コードが 0 以外になる）。
  Future<(int, String)> _runLitestream(
    List<String> arguments, {
    bool captureStderr = true,
  }) async {
    final process = await _start('litestream', arguments, mode: .normal);
    _stoppable.add(process);
    if (_stopRequested) process.kill();
    final output = StringBuffer();
    final stdoutDone = process.stdout
        .transform(utf8.decoder)
        .forEach(output.write);
    final stderrDone = captureStderr
        ? process.stderr.transform(utf8.decoder).forEach(output.write)
        : process.stderr.transform(utf8.decoder).forEach(stderr.write);
    try {
      final exitCode = await process.exitCode.timeout(_config.restoreTimeout);
      await (stdoutDone, stderrDone).wait;
      return (exitCode, output.toString().trim());
    } on TimeoutException {
      process.kill();
      throw ReplicaRestoreFailed(
        'litestream ${arguments.first} が ${_config.restoreTimeout.inSeconds} 秒で終わらない',
      );
    } finally {
      _stoppable.remove(process);
    }
  }

  @override
  Future<SchemaState> inspect() async => inspectSqliteSchema(
    dbPath: _config.dbPath,
    migrationsDirectory: _config.migrationsDirectory,
  );

  @override
  Future<void> applyMigrations() async {
    final process = await _start(
      _config.serverBinary,
      ['--mode=production', '--role=maintenance', '--apply-migrations'],
      environment: {'SERVERPOD_DATABASE_FILE_PATH': _config.dbPath},
    );
    // 適用はトランザクションなので、停止要求で止めても DB は元の版のまま（複製もしない）。
    _stoppable.add(process);
    if (_stopRequested) process.kill();
    final int exitCode;
    try {
      exitCode = await process.exitCode;
    } finally {
      _stoppable.remove(process);
    }
    if (exitCode != 0) {
      throw MigrationApplyFailed('Serverpod が終了コード $exitCode で終わった');
    }
  }

  @override
  Future<ReplicationRun> startReplication() async {
    Directory(File(_config.socketPath).parent.path).createSync(recursive: true);
    final process = await _start('litestream', [
      'replicate',
      '-config',
      _config.litestreamConfig,
    ]);
    final run = _LitestreamRun(this, process);
    final deadline = DateTime.now().add(_config.replicationReadyTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (run.exited) {
        throw ReplicationFailed(
          'Litestream が終了した（終了コード ${await process.exitCode}）',
        );
      }
      if (FileSystemEntity.typeSync(_config.socketPath) == .unixDomainSock) {
        return run;
      }
      if (_stopRequested) {
        await run.stop();
        throw const ReplicationFailed('IPC socket の準備中に停止要求を受けた');
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    await run.stop();
    throw ReplicationFailed(
      'IPC socket（${_config.socketPath}）が ${_config.replicationReadyTimeout.inSeconds} 秒で用意されない',
    );
  }

  Future<Process> _start(
    String executable,
    List<String> arguments, {
    Map<String, String>? environment,
    ProcessStartMode mode = .inheritStdio,
  }) => Process.start(
    executable,
    arguments,
    environment: environment,
    mode: mode,
  );
}

class _LitestreamRun(
  final LitestreamMigrationWorkspace _workspace,
  final Process _process,
) implements ReplicationRun {
  this {
    unawaited(_process.exitCode.then((_) => exited = true));
  }

  bool exited = false;

  MigrationWorkspaceConfig get _config => _workspace._config;

  /// POST /sync で GCS まで複製されたことを確かめる。起動直後は応答できないことがあるので、
  /// 決めた回数まで繰り返す（`api/scripts/seed.sh` と同じ）。
  ///
  /// 停止要求を受けたら、進行中の確認を打ち切り、[MigrationWorkspaceConfig.finalSyncTimeout]
  /// で最後に一度だけ確かめる（`seed.sh` の終了時の確認と同じ）。確認できれば成功として返し、
  /// 呼び出し元が Litestream を止めて所有権を解放する。できなければ [ReplicationFailed]。
  @override
  Future<void> confirm() async {
    String? lastError;
    for (var attempt = 0; attempt < _config.syncAttempts; attempt++) {
      if (_workspace._stopRequested) return _finalConfirm(lastError);
      if (exited) throw const ReplicationFailed('Litestream が途中で終了した');
      final confirmer = LitestreamConfirmer(
        socketPath: _config.socketPath,
        dbPath: _config.dbPath,
      );
      // 停止要求で接続を閉じ、進行中の確認を打ち切る。
      _workspace._onStop = confirmer.close;
      try {
        await confirmer.confirm(timeout: _config.syncTimeout);
        return;
      } on ReplicationUnavailableException catch (e) {
        lastError = e.reason;
      } finally {
        _workspace._onStop = null;
        confirmer.close();
      }
      if (!_workspace._stopRequested) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    if (_workspace._stopRequested) return _finalConfirm(lastError);
    throw ReplicationFailed(
      '${_config.syncAttempts} 回確かめても複製を確認できない: $lastError',
    );
  }

  Future<void> _finalConfirm(String? lastError) async {
    if (exited) throw const ReplicationFailed('停止要求を受けた。Litestream は既に終了している');
    final confirmer = LitestreamConfirmer(
      socketPath: _config.socketPath,
      dbPath: _config.dbPath,
    );
    try {
      await confirmer.confirm(timeout: _config.finalSyncTimeout);
    } on ReplicationUnavailableException catch (e) {
      throw ReplicationFailed(
        '停止要求を受けた。最後の確認でも複製を確認できない: ${e.reason}（その前: $lastError）',
      );
    } finally {
      confirmer.close();
    }
  }

  @override
  Future<bool> stop() async {
    if (!exited) _process.kill();
    try {
      await _process.exitCode.timeout(_config.stopTimeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}
