import 'dart:async';

import '../../../domain/ports/persistence_gate.dart';
import 'replication_confirmer.dart';

/// ゲート内の DB 処理を実行する層。Session / Transaction は各 repository が管理する。
abstract interface class DatabaseExecutor() {
  Future<T> write<T>(Future<T> Function() fn, {required bool immediate});

  Future<T> read<T>(Future<T> Function() fn);
}

/// 要求を 1 件ずつ処理し、書き込みは複製確認まで次を通さないゲート。
///
/// 注意: [fn] の中から同じゲートを呼ばない（自分の完了を待って止まる）。
class SerialPersistenceGate({
  required final DatabaseExecutor _executor,
  required final ReplicationConfirmer _confirmer,

  /// 複製を確認できず、未複製のローカル状態が残る恐れがあるときに呼ぶ。
  /// 呼び出し側は Serverpod と Litestream を止め、GCS から復旧する。
  final void Function()? onUnrecoverable,
}) implements PersistenceGate {
  Future<void> _tail = Future.value();

  /// 直前の変更の複製を確認できていない。確認できるまで何も通さない。
  bool _unconfirmed = false;

  Future<T> _enter<T>(Future<T> Function() body) {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    return previous.then((_) => body()).whenComplete(done.complete);
  }

  @override
  Future<T> runWrite<T>(
    Future<T> Function() fn, {
    required Duration deadline,
    bool immediate = false,
  }) {
    final clock = Stopwatch()..start();
    Duration remaining() => deadline - clock.elapsed;
    return _enter(() async {
      // 待ち行列で期限を過ぎた要求は、何も実行せずに失敗させる。複製の失敗ではないので、
      // 停止（onUnrecoverable）へは進めない。
      if (remaining() <= Duration.zero) {
        throw const ReplicationUnavailableException('待ち行列で期限を過ぎた');
      }
      await _recoverIfNeeded();
      final T result;
      try {
        result = await _executor.write(fn, immediate: immediate);
      } on Object {
        // 業務エラーの前に更新が commit されている場合がある（認証など）。
        // その同期結果を確定してから、元のエラーを返す。
        await _confirmOrClose(remaining);
        rethrow;
      }
      await _confirmOrClose(remaining);
      return result;
    });
  }

  @override
  Future<T> runRead<T>(Future<T> Function() fn) {
    return _enter(() async {
      await _recoverIfNeeded();
      return _executor.read(fn);
    });
  }

  /// 複製を確認する。失敗したらゲートを閉じ、この要求は失敗として返す。
  ///
  /// 再同期での確認は、この要求の応答を返した後に、ゲートを閉じたまま行う
  /// （[_scheduleRecovery]）。クライアントには先に `TEMPORARILY_UNAVAILABLE` が届く。
  Future<void> _confirmOrClose(Duration Function() remaining) async {
    try {
      await _confirmer.confirm(timeout: syncTimeout(remaining()));
    } on ReplicationUnavailableException {
      _unconfirmed = true;
      _scheduleRecovery();
      rethrow;
    }
  }

  /// 後続の要求より先に、未確認の変更の複製を再確認する。
  /// 確認できれば受付を再開し、できなければ [onUnrecoverable] で停止へ進む。
  void _scheduleRecovery() {
    unawaited(
      _enter(_recoverIfNeeded).then<void>((_) {}, onError: (Object _) {}),
    );
  }

  /// 要求の残り時間とは切り離して再確認する。待ち行列で期限が切れた要求が、
  /// Litestream が健全なのに「確認できない」と判断して停止へ進むのを避けるため。
  Future<void> _recoverIfNeeded() async {
    if (!_unconfirmed) return;
    try {
      await _confirmer.confirm(timeout: const Duration(seconds: 8));
      _unconfirmed = false;
    } on ReplicationUnavailableException {
      onUnrecoverable?.call();
      rethrow;
    }
  }
}
