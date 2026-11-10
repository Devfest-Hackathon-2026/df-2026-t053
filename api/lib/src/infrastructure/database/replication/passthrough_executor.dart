import 'serial_persistence_gate.dart';

/// DB を開かず、渡された処理をそのまま実行する層。
/// ゲートの単位が RPC 全体のとき、トランザクションは各 repository が持つ。
/// 要求は 1 件ずつなので、`immediate`（BEGIN IMMEDIATE 相当）でも競合は起きない。
class const PassthroughExecutor() implements DatabaseExecutor {
  @override
  Future<T> write<T>(Future<T> Function() fn, {required bool immediate}) =>
      fn();

  @override
  Future<T> read<T>(Future<T> Function() fn) => fn();
}
