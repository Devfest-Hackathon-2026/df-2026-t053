import 'package:photohunt_server/src/application/migration/migration_ports.dart';
import 'package:photohunt_server/src/application/migration/run_migration.dart';
import 'package:test/test.dart';

/// 呼ばれた操作を順に記録する。
final class _Calls() {
  final List<String> log = [];

  /// この操作を記録した時点で停止要求を受けたことにする（SIGTERM の再現）。
  String? stopAt;
  bool stop = false;

  void record(String operation) {
    log.add(operation);
    if (operation == stopAt) stop = true;
  }
}

final class _FakeLock(
  final _Calls _calls, {
  final bool unavailable = false,
  final bool releaseFails = false,
}) implements WriterLock {
  @override
  Future<HeldWriterLock> acquire() async {
    _calls.record('acquire');
    if (unavailable) throw const WriterLockUnavailable('別の writer がいる');
    return _FakeHeld(_calls, releaseFails: releaseFails);
  }
}

final class _FakeHeld(final _Calls _calls, {final bool releaseFails = false})
    implements HeldWriterLock {
  @override
  String get description => 'fake';

  @override
  Future<void> release() async {
    _calls.record('release');
    if (releaseFails) throw const WriterLockUnavailable('generation が違う');
  }
}

/// [states] を inspect のたびに先頭から返す。
final class _FakeWorkspace(
  final _Calls _calls, {
  final RestoreResult restoreResult = .restored,
  final bool restoreFails = false,
  final List<SchemaState> states = const [],
  final Object? applyError,
  final bool startFails = false,
  final bool confirmFails = false,
  final bool stopsCleanly = true,
}) implements MigrationWorkspace {
  late final List<SchemaState> _remaining = [...states];

  @override
  Future<void> clear() async => _calls.record('clear');

  @override
  Future<RestoreResult> restore() async {
    _calls.record('restore');
    if (restoreFails) throw const ReplicaRestoreFailed('権限がない');
    return restoreResult;
  }

  @override
  Future<SchemaState> inspect() async {
    _calls.record('inspect');
    return _remaining.removeAt(0);
  }

  @override
  Future<void> applyMigrations() async {
    _calls.record('applyMigrations');
    if (applyError case final error?) throw error;
  }

  @override
  Future<ReplicationRun> startReplication() async {
    _calls.record('startReplication');
    if (startFails) throw const ReplicationFailed('socket がない');
    return _FakeRun(
      _calls,
      confirmFails: confirmFails,
      stopsCleanly: stopsCleanly,
    );
  }
}

final class _FakeRun(
  final _Calls _calls, {
  required final bool confirmFails,
  required final bool stopsCleanly,
}) implements ReplicationRun {
  @override
  Future<void> confirm() async {
    _calls.record('confirm');
    if (confirmFails) throw const ReplicationFailed('synced_local のまま');
  }

  @override
  Future<bool> stop() async {
    _calls.record('stop');
    return stopsCleanly;
  }
}

const _applied = {'photohunt': '100'};
const _expected = {'photohunt': '200'};
const _ready = SchemaReady(_expected);
const _needs = SchemaNeedsMigration(applied: _applied, expected: _expected);

void main() {
  late _Calls calls;
  late List<String> reports;

  setUp(() {
    calls = _Calls();
    reports = [];
  });

  RunMigration migration({
    bool lockUnavailable = false,
    bool releaseFails = false,
    RestoreResult restoreResult = .restored,
    bool restoreFails = false,
    List<SchemaState> states = const [],
    Object? applyError,
    bool startFails = false,
    bool confirmFails = false,
    bool stopsCleanly = true,
  }) => RunMigration(
    lock: _FakeLock(
      calls,
      unavailable: lockUnavailable,
      releaseFails: releaseFails,
    ),
    workspace: _FakeWorkspace(
      calls,
      restoreResult: restoreResult,
      restoreFails: restoreFails,
      states: states,
      applyError: applyError,
      startFails: startFails,
      confirmFails: confirmFails,
      stopsCleanly: stopsCleanly,
    ),
    report: reports.add,
    stopRequested: () => calls.stop,
  );

  group('apply', () {
    test('適用済みなら何も変えず、所有権を解放する', () async {
      final outcome = await migration(states: [_ready]).apply();
      expect(outcome, MigrationOutcome.unchanged);
      expect(outcome.exitCode, 0);
      expect(calls.log, ['acquire', 'clear', 'restore', 'inspect', 'release']);
    });

    test('未適用なら適用 → 照合 → 複製してから所有権を解放する', () async {
      final outcome = await migration(states: [_needs, _ready]).apply();
      expect(outcome, MigrationOutcome.applied);
      expect(calls.log, [
        'acquire',
        'clear',
        'restore',
        'inspect',
        'applyMigrations',
        'inspect',
        'startReplication',
        'confirm',
        'stop',
        'release',
      ]);
    });

    test('所有権を取れなければ、復元も含めて何もしない', () async {
      final outcome = await migration(lockUnavailable: true).apply();
      expect(outcome, MigrationOutcome.lockUnavailable);
      expect(outcome.exitCode, 2);
      expect(calls.log, ['acquire']);
    });

    test('復元に失敗したら、空の DB で続けずに所有権を解放する', () async {
      final outcome = await migration(restoreFails: true).apply();
      expect(outcome, MigrationOutcome.restoreFailed);
      expect(outcome.exitCode, 3);
      expect(calls.log, ['acquire', 'clear', 'restore', 'release']);
    });

    test('レプリカがなければ失敗にする（本番で空の DB を作らない）', () async {
      final outcome = await migration(restoreResult: .noReplica).apply();
      expect(outcome, MigrationOutcome.restoreFailed);
      expect(calls.log, isNot(contains('applyMigrations')));
      expect(calls.log.last, 'release');
    });

    test('--init-if-missing ならレプリカがないときに初回の DB を作る', () async {
      final outcome = await migration(
        restoreResult: .noReplica,
        states: [_ready],
      ).apply(initIfMissing: true);
      expect(outcome, MigrationOutcome.initialized);
      expect(
        calls.log,
        containsAllInOrder(['applyMigrations', 'confirm', 'release']),
      );
    });

    test('DB が壊れていれば復元の失敗として扱い、適用しない', () async {
      final outcome = await migration(
        states: [const SchemaCorrupt('integrity_check')],
      ).apply();
      expect(outcome, MigrationOutcome.restoreFailed);
      expect(calls.log, isNot(contains('applyMigrations')));
    });

    test('DB が image より新しければ、古い image で変更しない', () async {
      final outcome = await migration(
        states: [
          const SchemaTooNew(
            applied: {'photohunt': '300'},
            expected: _expected,
          ),
        ],
      ).apply();
      expect(outcome, MigrationOutcome.tooNew);
      expect(outcome.exitCode, 11);
      expect(calls.log, isNot(contains('applyMigrations')));
      expect(calls.log.last, 'release');
    });

    test('適用に失敗したら複製せず、所有権を解放する（レプリカは元の版のまま）', () async {
      final outcome = await migration(
        states: [_needs],
        applyError: const MigrationApplyFailed('終了コード 1'),
      ).apply();
      expect(outcome, MigrationOutcome.applyFailed);
      expect(outcome.exitCode, 4);
      expect(calls.log, isNot(contains('startReplication')));
      expect(calls.log.last, 'release');
    });

    test('適用後の照合が合わなければ複製しない', () async {
      final outcome = await migration(states: [_needs, _needs]).apply();
      expect(outcome, MigrationOutcome.applyFailed);
      expect(calls.log, isNot(contains('startReplication')));
      expect(calls.log.last, 'release');
    });

    test('想定外の例外でも、複製を始める前なら所有権を解放して投げ直す', () async {
      await expectLater(
        migration(states: [_needs], applyError: StateError('想定外')).apply(),
        throwsStateError,
      );
      expect(calls.log.last, 'release');
    });

    test('複製を確認できなければ所有権を残す（GCS の状態が不明）', () async {
      final outcome = await migration(
        states: [_needs, _ready],
        confirmFails: true,
      ).apply();
      expect(outcome, MigrationOutcome.syncFailed);
      expect(outcome.exitCode, 5);
      expect(calls.log, contains('stop'));
      expect(calls.log, isNot(contains('release')));
    });

    test('Litestream を起動できなければ所有権を残す', () async {
      final outcome = await migration(
        states: [_needs, _ready],
        startFails: true,
      ).apply();
      expect(outcome, MigrationOutcome.syncFailed);
      expect(calls.log, isNot(contains('release')));
    });

    test('Litestream が猶予内に止まらなければ所有権を残す', () async {
      final outcome = await migration(
        states: [_needs, _ready],
        stopsCleanly: false,
      ).apply();
      expect(outcome, MigrationOutcome.syncFailed);
      expect(calls.log, isNot(contains('release')));
    });

    test('所有権を解放できなければ、その旨の終了コードにする', () async {
      final outcome = await migration(
        states: [_ready],
        releaseFails: true,
      ).apply();
      expect(outcome, MigrationOutcome.releaseFailed);
      expect(outcome.exitCode, 21);
    });
  });

  group('init', () {
    test('レプリカが既にあれば作り直さない', () async {
      final outcome = await migration().init();
      expect(outcome, MigrationOutcome.replicaExists);
      expect(outcome.exitCode, 6);
      expect(calls.log, ['acquire', 'clear', 'restore', 'release']);
    });

    test('レプリカがなければ作って複製する', () async {
      final outcome = await migration(
        restoreResult: .noReplica,
        states: [_ready],
      ).init();
      expect(outcome, MigrationOutcome.initialized);
      expect(calls.log, [
        'acquire',
        'clear',
        'restore',
        'clear',
        'applyMigrations',
        'inspect',
        'startReplication',
        'confirm',
        'stop',
        'release',
      ]);
    });

    test('所有権を取れなければ何もしない', () async {
      final outcome = await migration(lockUnavailable: true).init();
      expect(outcome, MigrationOutcome.lockUnavailable);
      expect(calls.log, ['acquire']);
    });
  });

  group('停止要求（SIGTERM）', () {
    test('所有権の取得中に受けたら、復元もせずに解放して 143 で終える', () async {
      calls.stopAt = 'acquire';
      final outcome = await migration(states: [_needs, _ready]).apply();
      expect(outcome, MigrationOutcome.stopped);
      expect(outcome.exitCode, 143);
      expect(calls.log, ['acquire', 'release']);
    });

    test('復元の後に受けたら、照合・適用をせずに解放する', () async {
      calls.stopAt = 'restore';
      final outcome = await migration(states: [_needs, _ready]).apply();
      expect(outcome, MigrationOutcome.stopped);
      expect(calls.log, ['acquire', 'clear', 'restore', 'release']);
    });

    test('適用中に受けて子プロセスが止まったら、適用の失敗ではなく停止として解放する', () async {
      calls.stopAt = 'applyMigrations';
      final outcome = await migration(
        states: [_needs],
        applyError: const MigrationApplyFailed('SIGTERM で終了'),
      ).apply();
      expect(outcome, MigrationOutcome.stopped);
      expect(calls.log, isNot(contains('startReplication')));
      expect(calls.log.last, 'release');
    });

    test('適用後の照合の後に受けたら、Litestream を起動せずに解放する', () async {
      // 1 回目の照合（適用前）では止めず、2 回目（適用後）の照合で止める。
      final outcome = await RunMigration(
        lock: _FakeLock(calls),
        workspace: _FakeWorkspace(calls, states: [_needs, _ready]),
        report: reports.add,
        stopRequested: () => calls.log.where((o) => o == 'inspect').length >= 2,
      ).apply();
      expect(outcome, MigrationOutcome.stopped);
      expect(calls.log, isNot(contains('startReplication')));
      expect(calls.log.last, 'release');
    });

    test('init でも、復元の後に受けたら作らずに解放する', () async {
      calls.stopAt = 'restore';
      final outcome = await migration(restoreResult: .noReplica).init();
      expect(outcome, MigrationOutcome.stopped);
      expect(calls.log, isNot(contains('applyMigrations')));
      expect(calls.log.last, 'release');
    });

    test('複製を始めた後の停止は、確認の結果に従う（確認できなければ所有権を残す）', () async {
      calls.stopAt = 'confirm';
      final outcome = await migration(
        states: [_needs, _ready],
        confirmFails: true,
      ).apply();
      expect(outcome, MigrationOutcome.syncFailed);
      expect(calls.log, isNot(contains('release')));
    });

    test('status は復元の後に受けたら照合せずに 143', () async {
      calls.stopAt = 'restore';
      final outcome = await migration(states: [_ready]).status();
      expect(outcome, MigrationOutcome.stopped);
      expect(calls.log, isNot(contains('inspect')));
    });
  });

  group('status', () {
    test('所有権を取らず、何も書かない', () async {
      final outcome = await migration(states: [_needs]).status();
      expect(outcome, MigrationOutcome.needsMigration);
      expect(outcome.exitCode, 10);
      expect(calls.log, ['clear', 'restore', 'inspect']);
    });

    test('一致していれば 0', () async {
      expect(
        await migration(states: [_ready]).status(),
        MigrationOutcome.upToDate,
      );
    });

    test('レプリカがない・復元できないなら 3', () async {
      expect(
        await migration(restoreResult: .noReplica).status(),
        MigrationOutcome.restoreFailed,
      );
      expect(
        await migration(restoreFails: true).status(),
        MigrationOutcome.restoreFailed,
      );
    });
  });
}
