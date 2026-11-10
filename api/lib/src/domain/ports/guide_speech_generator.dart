import 'dart:typed_data';

import 'guide_cancellation.dart';

/// 音声の上限（デコード後の WAV 全体）。docs/specs.md「モデル・本文・音声の検証」。
const int kGuideAudioMaxBytes = 10 * 1024 * 1024;

/// 音声生成の失敗の分類。どれも、呼び出し側は「音声なし」で本文だけを返す（#32）。
enum GuideSpeechFailure() {
  /// 時間内に終わらなかった。
  timeout,

  /// 上限（[kGuideAudioMaxBytes]）を超えた。
  tooLarge,

  /// 出力の形式が WAV でも PCM でもない、または壊れている。
  invalidFormat,

  /// 通信・認証・上限など、そのほかの失敗。
  unavailable,
}

class const GuideSpeechException(
  final GuideSpeechFailure reason, {
  final String? detail,
}) implements Exception {
  @override
  String toString() => 'GuideSpeechException($reason)';
}

/// 確定した本文から、1 つの完全な WAV（RIFF ヘッダー付き）を作る。
abstract interface class GuideSpeechGenerator() {
  /// 失敗したら [GuideSpeechException]、取り消されたら [GuideCancelledException]。
  Future<Uint8List> synthesize(
    String text, {
    required Duration timeout,
    GuideCancellation? cancellation,
  });
}
