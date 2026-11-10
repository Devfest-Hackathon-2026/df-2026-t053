import 'dart:async';

/// ガイドの生成の取消（購読の終了）を、文生成・音声生成へ伝える印。#32 の stream が使う。
///
/// 取り消されたら、上流（Gemini）への要求を止める。取消は失敗とは別で、固定文への
/// 切り替えも行わない。
class GuideCancellation() {
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;

  /// 取り消されたときに完了する。
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

/// 生成の途中で取り消された。
class const GuideCancelledException() implements Exception {
  @override
  String toString() => 'GuideCancelledException';
}
