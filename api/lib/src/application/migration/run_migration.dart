import 'migration_ports.dart';

/// migration Job の結果と終了コード（#34）。
enum MigrationOutcome(final int exitCode) {
  /// 適用済みで、何も変えなかった。
  unchanged(0),

  /// migration を適用し、GCS への複製を確認した。
  applied(0),

  /// 初回の DB を作り、GCS への複製を確認した。
  initialized(0),

  /// status：DB は image が期待する版と一致している。
  upToDate(0),

  /// writer 所有権を取得できない（稼働中の API・Job がある、GCS の失敗）。DB は変えていない。
  lockUnavailable(2),

  /// 復元できない、レプリカがない（apply）、DB が壊れている。DB は変えていない。
  restoreFailed(3),

  /// 適用に失敗した。GCS のレプリカは元の版のまま。
  applyFailed(4),

  /// 複製を確認できない。GCS の状態が不明なので、所有権を残して保守を続ける。
  syncFailed(5),

  /// init：レプリカが既にあるので作り直さない。
  replicaExists(6),

  /// status：未適用の migration がある（`MAINTENANCE`）。
  needsMigration(10),

  /// DB が image より新しい（`SCHEMA_TOO_NEW`）。古い image で変更しない。
  tooNew(11),

  /// 処理は終えたが、所有権を解放できなかった。運用者が確認して解除する。
  releaseFailed(21),

  /// 停止要求（SIGTERM）を受け、次の段階へ進まずに終えた。複製を始める前なので、
  /// レプリカは変えておらず、所有権も解放した。
  stopped(143),
}

/// スキーマ変更と初回の DB 作成（docs/specs.md「DBマイグレーション」の 3〜6）。
///
/// API・seed と同じ writer 所有権を取ってから、GCS のレプリカを復元し、
/// 同じ image の Serverpod で適用し、照合してから複製する。
/// 失敗・部分適用のローカル DB は複製しない。複製を始めた後に確認できなくなったら、
/// GCS の状態が不明なので所有権を残す（自動では解放しない）。
class RunMigration({
  required final WriterLock _lock,
  required final MigrationWorkspace _workspace,
  required final void Function(String message) _report,

  /// 停止要求を受けたか。各段階の前に確かめ、受けていれば次の段階へ進まない。
  required final bool Function() _stopRequested,
}) {
  /// 未適用の migration を適用する。
  ///
  /// [initIfMissing] が true ならレプリカがないときに初回の DB を作る（ローカル環境用）。
  /// false なら、レプリカがないことを失敗として扱う（本番で空の DB を作らない）。
  Future<MigrationOutcome> apply({bool initIfMissing = false}) =>
      _withLock(() async {
        await _workspace.clear();
        final restored = await _workspace.restore();
        _throwIfStopping();
        switch (restored) {
          case .noReplica when initIfMissing:
            _report('レプリカがないので、初回の DB を作る');
            return _create(done: .initialized);
          case .noReplica:
            _report('レプリカがない。初回は init で作る');
            return .restoreFailed;
          case .restored:
            break;
        }
        switch (await _workspace.inspect()) {
          case SchemaReady(:final applied):
            _report('適用済みのため変更しない（適用版 $applied）');
            return .unchanged;
          case SchemaTooNew(:final applied, :final expected):
            _report('DB が image より新しい。変更しない（期待 $expected、適用 $applied）');
            return .tooNew;
          case SchemaCorrupt(:final reason):
            _report('復元した DB を使えない: $reason');
            return .restoreFailed;
          case SchemaNeedsMigration(:final applied, :final expected):
            _report('migration を適用する（期待 $expected、適用 $applied）');
            return _applyAndReplicate(done: .applied);
        }
      });

  /// 初回の DB を作る。レプリカが既にあれば何もしない（作り直さない）。
  Future<MigrationOutcome> init() => _withLock(() async {
    await _workspace.clear();
    final restored = await _workspace.restore();
    _throwIfStopping();
    switch (restored) {
      case .restored:
        _report('レプリカが既にあるため、作り直さない');
        return .replicaExists;
      case .noReplica:
        return _create(done: .initialized);
    }
  });

  /// レプリカの適用版を照合する。所有権は取らず、何も書かない。
  Future<MigrationOutcome> status() async {
    try {
      await _workspace.clear();
      final restored = await _workspace.restore();
      if (_stopRequested()) {
        _report('停止要求を受けたため、照合しない');
        return .stopped;
      }
      if (restored == .noReplica) {
        _report('レプリカがない（init が必要）');
        return .restoreFailed;
      }
      switch (await _workspace.inspect()) {
        case SchemaReady(:final applied):
          _report('DB は image と一致している（適用版 $applied）');
          return .upToDate;
        case SchemaNeedsMigration(:final applied, :final expected):
          _report('未適用の migration がある（期待 $expected、適用 $applied）');
          return .needsMigration;
        case SchemaTooNew(:final applied, :final expected):
          _report('DB が image より新しい（期待 $expected、適用 $applied）');
          return .tooNew;
        case SchemaCorrupt(:final reason):
          _report('復元した DB を使えない: $reason');
          return .restoreFailed;
      }
    } on ReplicaRestoreFailed catch (e) {
      if (_stopRequested()) {
        _report('停止要求を受けたため、復元を止めた');
        return .stopped;
      }
      _report('復元できない: ${e.message}');
      return .restoreFailed;
    }
  }

  Future<MigrationOutcome> _create({required MigrationOutcome done}) async {
    await _workspace.clear();
    return _applyAndReplicate(done: done);
  }

  /// 適用 → 照合 → 複製。照合を通るまで Litestream を起動しない（レプリカを変えない）。
  Future<MigrationOutcome> _applyAndReplicate({
    required MigrationOutcome done,
  }) async {
    _throwIfStopping();
    try {
      await _workspace.applyMigrations();
    } on MigrationApplyFailed catch (e) {
      // 停止要求で子プロセスを止めた場合は、適用の失敗ではなく停止として扱う。
      _throwIfStopping();
      _report('migration の適用に失敗した。レプリカは元の版のまま: ${e.message}');
      return .applyFailed;
    }
    switch (await _workspace.inspect()) {
      case SchemaReady(:final applied):
        _report('適用後の DB を照合した（適用版 $applied）');
        // Litestream を起動したら GCS が変わり得る。停止要求を受けていたら、その前に止める。
        _throwIfStopping();
      case final other:
        _report('適用後の DB が期待と合わない。複製しない: $other');
        return .applyFailed;
    }
    return _replicate(done: done);
  }

  /// Litestream を起動してから止めるまで。ここでの失敗は、どれも GCS の状態が不明になるので
  /// 所有権を残す（想定外の例外も同じ。[_KeepLock] に包んで返す）。
  Future<MigrationOutcome> _replicate({required MigrationOutcome done}) async {
    final ReplicationRun run;
    try {
      run = await _workspace.startReplication();
    } on Object catch (e) {
      _report('Litestream を起動できない: $e');
      throw const _KeepLock(.syncFailed);
    }
    try {
      await run.confirm();
    } on Object catch (e) {
      await _stopQuietly(run);
      _report('GCS への複製を確認できない: $e');
      throw const _KeepLock(.syncFailed);
    }
    final bool stopped;
    try {
      stopped = await run.stop();
    } on Object catch (e) {
      _report('Litestream を止められない: $e');
      throw const _KeepLock(.syncFailed);
    }
    if (!stopped) {
      _report('Litestream が猶予内に止まらなかった。アップロードが残っている可能性がある');
      throw const _KeepLock(.syncFailed);
    }
    _report('GCS への複製を確認した');
    return done;
  }

  Future<void> _stopQuietly(ReplicationRun run) async {
    try {
      await run.stop();
    } on Object catch (e) {
      _report('Litestream の停止に失敗した: $e');
    }
  }

  /// 所有権を取って [body] を実行し、最後に解放する。
  ///
  /// 複製を始めた後の失敗（[_KeepLock]）だけは解放しない。それより前の失敗は、想定外の例外も
  /// 含めて GCS のレプリカを変えていないので、解放してから結果を返す（想定外の例外は投げ直す）。
  Future<MigrationOutcome> _withLock(
    Future<MigrationOutcome> Function() body,
  ) async {
    final HeldWriterLock held;
    try {
      held = await _lock.acquire();
    } on WriterLockUnavailable catch (e) {
      _report('writer 所有権を取得できない。稼働中の API・Job を止めてから実行する: ${e.message}');
      return .lockUnavailable;
    }
    _report('writer 所有権を取得した ${held.description}');
    final MigrationOutcome outcome;
    try {
      // 所有権の取得を待つ間に停止要求を受けていたら、何もせずに解放する。
      _throwIfStopping();
      outcome = await body();
    } on _KeepLock catch (e) {
      _report(
        '所有権を残す。全 writer の停止を確認し、GCS の適用版を確かめてから解除する'
        '（runbook「Job の同期結果が不明」）',
      );
      return e.outcome;
    } on _Stop {
      _report('停止要求を受けたため、次の段階へ進まない。レプリカは変えていない');
      return _release(held, outcome: .stopped);
    } on ReplicaRestoreFailed catch (e) {
      if (_stopRequested()) {
        _report('停止要求を受けたため、復元を止めた。レプリカは変えていない');
        return _release(held, outcome: .stopped);
      }
      _report('復元できない: ${e.message}');
      return _release(held, outcome: .restoreFailed);
    } on Object {
      await _release(held, outcome: .applyFailed);
      rethrow;
    }
    return _release(held, outcome: outcome);
  }

  /// 停止要求を受けていれば [_Stop] を投げる。複製を始める前の段階でだけ呼ぶ。
  void _throwIfStopping() {
    if (_stopRequested()) throw const _Stop();
  }

  Future<MigrationOutcome> _release(
    HeldWriterLock held, {
    required MigrationOutcome outcome,
  }) async {
    try {
      await held.release();
      _report('writer 所有権を解放した');
      return outcome;
    } on WriterLockUnavailable catch (e) {
      _report('writer 所有権を解放できない: ${e.message}');
      return .releaseFailed;
    }
  }
}

/// 複製を始めた後の失敗。所有権を残す。
class const _KeepLock(final MigrationOutcome outcome) implements Exception;

/// 複製を始める前に停止要求を受けた。所有権を解放して [MigrationOutcome.stopped] で終える。
class const _Stop() implements Exception;
