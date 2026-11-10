import 'dart:async';

import 'package:photohunt_server/src/domain/ports/persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/replication_confirmer.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/serial_persistence_gate.dart';
import 'package:test/test.dart';

class _Executor() implements DatabaseExecutor {
  final events = <String>[];

  @override
  Future<T> write<T>(Future<T> Function() fn, {required bool immediate}) async {
    events.add('write${immediate ? '(immediate)' : ''}');
    return fn();
  }

  @override
  Future<T> read<T>(Future<T> Function() fn) {
    events.add('read');
    return fn();
  }
}

class _Confirmer(final List<String> events) implements ReplicationConfirmer {
  final timeouts = <Duration>[];

  /// 呼ばれるたびに先頭から消費する。空なら成功。
  final results = <Object?>[];

  @override
  Future<void> confirm({required Duration timeout}) async {
    events.add('confirm');
    timeouts.add(timeout);
    if (results.isEmpty) return;
    final next = results.removeAt(0);
    if (next is Exception) throw next;
  }
}

void main() {
  late _Executor executor;
  late _Confirmer confirmer;
  late int unrecoverable;
  late SerialPersistenceGate gate;

  setUp(() {
    executor = _Executor();
    confirmer = _Confirmer(executor.events);
    unrecoverable = 0;
    gate = SerialPersistenceGate(
      executor: executor,
      confirmer: confirmer,
      onUnrecoverable: () => unrecoverable++,
    );
  });

  const unavailable = ReplicationUnavailableException('テスト');

  test('書き込みは commit のあとに複製を確認してから値を返す', () async {
    final value = await gate.runWrite(
      () async => 7,
      deadline: const Duration(seconds: 30),
    );
    expect(value, 7);
    expect(executor.events, ['write', 'confirm']);
  });

  test('immediate を実行層へ渡す', () async {
    await gate.runWrite(
      () async {},
      deadline: const Duration(seconds: 30),
      immediate: true,
    );
    expect(executor.events.first, 'write(immediate)');
  });

  test('複製確認の待ちは min(8秒, 残り時間)', () async {
    await gate.runWrite(() async {}, deadline: const Duration(seconds: 3));
    expect(
      confirmer.timeouts.single,
      lessThanOrEqualTo(const Duration(seconds: 3)),
    );
    await gate.runWrite(() async {}, deadline: const Duration(seconds: 60));
    expect(confirmer.timeouts.last, const Duration(seconds: 8));
  });

  test('同時に2件の書き込みが重ならない', () async {
    final order = <String>[];
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();

    final first = gate.runWrite(() async {
      order.add('first:start');
      firstStarted.complete();
      await releaseFirst.future;
      order.add('first:end');
    }, deadline: const Duration(seconds: 30));
    final second = gate.runWrite(() async {
      order.add('second:start');
    }, deadline: const Duration(seconds: 30));

    await firstStarted.future;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(order, ['first:start']);
    releaseFirst.complete();
    await Future.wait([first, second]);
    expect(order, ['first:start', 'first:end', 'second:start']);
  });

  test('読み取りも前の書き込みの複製確認が終わるまで待つ', () async {
    final releaseConfirm = Completer<void>();
    final slow = _SlowConfirmer(releaseConfirm.future);
    final g = SerialPersistenceGate(executor: executor, confirmer: slow);

    final write = g.runWrite(
      () async {},
      deadline: const Duration(seconds: 30),
    );
    var readDone = false;
    final read = g.runRead(() async {}).then((_) => readDone = true);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(readDone, isFalse);
    releaseConfirm.complete();
    await Future.wait([write, read]);
    expect(readDone, isTrue);
  });

  test('複製を確認できなければ失敗を返し、再同期で確認できれば受付を再開する', () async {
    confirmer.results.addAll([unavailable, null]); // 1回目失敗 → 再確認で成功
    await expectLater(
      gate.runWrite(() async => 1, deadline: const Duration(seconds: 30)),
      throwsA(isA<ReplicationUnavailableException>()),
    );

    final value = await gate.runWrite(
      () async => 2,
      deadline: const Duration(seconds: 30),
    );
    expect(value, 2);
  });

  test('再同期でも確認できなければ onUnrecoverable を呼び、後続は閉じたまま', () async {
    confirmer.results.addAll([unavailable, unavailable, unavailable]);
    await expectLater(
      gate.runWrite(() async => 1, deadline: const Duration(seconds: 30)),
      throwsA(isA<ReplicationUnavailableException>()),
    );
    // 応答のあとで、ゲートを閉じたまま再確認し、確認できなければ停止へ進む。
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(unrecoverable, 1);

    // 後続の読み取りは、未複製のデータを返さない。
    executor.events.clear();
    await expectLater(
      gate.runRead(() async => 'leak'),
      throwsA(isA<ReplicationUnavailableException>()),
    );
    expect(executor.events, isNot(contains('read')));
  });

  test('失敗の応答は再確認を待たずに返る', () async {
    final release = Completer<void>();
    final slow = _FailThenSlow(release.future);
    final g = SerialPersistenceGate(executor: executor, confirmer: slow);

    // 再確認が止まっていても、最初の要求は失敗を返せる。
    await expectLater(
      g.runWrite(() async => 1, deadline: const Duration(seconds: 30)),
      throwsA(isA<ReplicationUnavailableException>()),
    );
    // 再確認が終わるまで、後続はゲートの外で待たされる。
    var done = false;
    final next = g.runRead(() async => 1).then((_) => done = true);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(done, isFalse);
    release.complete();
    await next;
    expect(done, isTrue);
  });

  test('待ち行列で期限を過ぎた要求は、実行せず失敗し、停止へ進まない', () async {
    final release = Completer<void>();
    final first = gate.runWrite(
      () => release.future,
      deadline: const Duration(seconds: 30),
    );
    final late = gate.runWrite(() async {
      fail('期限切れの要求は実行しない');
    }, deadline: const Duration(milliseconds: 10));
    final lateResult = expectLater(
      late,
      throwsA(isA<ReplicationUnavailableException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    release.complete();
    await first;
    await lateResult;
    expect(unrecoverable, 0);
  });

  test('業務エラーでも複製を確認してから元のエラーを返す', () async {
    await expectLater(
      gate.runWrite<void>(
        () async => throw StateError('business'),
        deadline: const Duration(seconds: 30),
      ),
      throwsA(isA<StateError>()),
    );
    expect(executor.events, ['write', 'confirm']);
  });

  test('業務エラーのあとに複製を確認できなければ unavailable を優先する', () async {
    confirmer.results.addAll([unavailable, unavailable, unavailable]);
    await expectLater(
      gate.runWrite<void>(
        () async => throw StateError('business'),
        deadline: const Duration(seconds: 30),
      ),
      throwsA(isA<ReplicationUnavailableException>()),
    );
  });

  test('syncTimeout は残り時間がなければ 0', () {
    expect(syncTimeout(Duration.zero), Duration.zero);
    expect(syncTimeout(const Duration(seconds: -1)), Duration.zero);
    expect(syncTimeout(const Duration(seconds: 2)), const Duration(seconds: 2));
    expect(syncTimeout(const Duration(minutes: 1)), const Duration(seconds: 8));
  });
}

class _SlowConfirmer(final Future<void> gate) implements ReplicationConfirmer {
  @override
  Future<void> confirm({required Duration timeout}) => gate;
}

/// 1 回目は失敗し、2 回目（再確認）は [release] まで止まる。
class _FailThenSlow(final Future<void> release)
    implements ReplicationConfirmer {
  var _calls = 0;

  @override
  Future<void> confirm({required Duration timeout}) async {
    _calls++;
    if (_calls == 1) throw const ReplicationUnavailableException('テスト');
    await release;
  }
}
