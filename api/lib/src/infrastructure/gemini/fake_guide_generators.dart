import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/ports/guide_cancellation.dart';
import '../../domain/ports/guide_speech_generator.dart';
import '../../domain/ports/guide_text_generator.dart';
import '../audio/wav.dart';
import 'gemini_guide_text_generator.dart' show directionLabel, distanceLabel;

/// fake の振る舞い。ローカル・テストで、失敗の経路を試すために切り替える。
enum FakeGuideBehavior() {
  /// 正常に本文・音声を返す。
  normal,

  /// 空の本文（文生成だけ）。
  empty,

  /// 生成を拒否された（文生成だけ）。
  refused,

  /// 待ち上限まで待ってから失敗する。
  timeout,

  /// 通信の失敗として失敗する。
  unavailable;

  /// `GUIDE_FAKE_BEHAVIOR` の値。未設定は [normal]。知らない値は null。
  static FakeGuideBehavior? parse(String? value) {
    if (value == null || value.isEmpty) return normal;
    for (final b in values) {
      if (b.name == value) return b;
    }
    return null;
  }
}

/// [delay] だけ待つ。取り消されたら、待たずに [GuideCancelledException]。
Future<void> _wait(Duration delay, GuideCancellation? cancellation) async {
  if (cancellation?.isCancelled ?? false) throw const GuideCancelledException();
  if (delay <= Duration.zero) return;
  final cancelled = cancellation?.whenCancelled;
  final done = Future<void>.delayed(delay);
  await (cancelled == null ? done : Future.any([done, cancelled]));
  if (cancellation?.isCancelled ?? false) throw const GuideCancelledException();
}

/// 名称と方向から決まる固定文を返す（ネットワークを使わない）。本文の先頭に【fake】を付け、
/// 生成した本文ではないことが画面でも分かるようにする。
class FakeGuideTextGenerator({
  final FakeGuideBehavior behavior = FakeGuideBehavior.normal,
  final Duration delay = Duration.zero,
}) implements GuideTextGenerator {
  @override
  Future<GeneratedGuideText> generate(
    GuideTextInput input, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async {
    switch (behavior) {
      case .timeout:
        await _wait(timeout, cancellation);
        throw const GuideTextException(GuideTextFailure.timeout);
      case .unavailable:
        await _wait(delay, cancellation);
        throw const GuideTextException(GuideTextFailure.unavailable);
      case .refused:
        await _wait(delay, cancellation);
        throw const GuideTextException(GuideTextFailure.refused);
      case .empty:
        await _wait(delay, cancellation);
        return const GeneratedGuideText(text: '', model: 'fake');
      case .normal:
        await _wait(delay, cancellation);
        final parts = [
          for (final s in input.subjects)
            s.direction == GuideDirection.none
                ? '${s.name}がこの近くにあります。'
                : '${directionLabel(s.direction)}の方向の${_place(s.distanceBand)}に、${s.name}があります。',
        ];
        return GeneratedGuideText(text: '【fake】${parts.join()}', model: 'fake');
    }
  }
}

/// 約 1 秒（24 kHz・モノラル・16 bit）の正弦波を、有効な WAV として返す。
/// 32 KiB を超えるので、#32 で複数 chunk に分かれる経路を試せる。
class FakeGuideSpeechGenerator({
  final FakeGuideBehavior behavior = FakeGuideBehavior.normal,
  final Duration delay = Duration.zero,
}) implements GuideSpeechGenerator {
  @override
  Future<Uint8List> synthesize(
    String text, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async {
    switch (behavior) {
      case .timeout:
        await _wait(timeout, cancellation);
        throw const GuideSpeechException(GuideSpeechFailure.timeout);
      case .unavailable || .refused || .empty:
        await _wait(delay, cancellation);
        throw const GuideSpeechException(GuideSpeechFailure.unavailable);
      case .normal:
        await _wait(delay, cancellation);
        return fakeToneWav();
    }
  }
}

/// [seconds] 秒・440 Hz の正弦波の WAV（24 kHz・モノラル・16 bit）。
Uint8List fakeToneWav({double seconds = 1.0}) {
  const format = PcmFormat();
  final samples = (format.sampleRate * seconds).round();
  final pcm = ByteData(samples * 2);
  for (var i = 0; i < samples; i++) {
    final value = math.sin(2 * math.pi * 440 * i / format.sampleRate) * 0.2;
    pcm.setInt16(i * 2, (value * 32767).round(), Endian.little);
  }
  return pcmToWav(pcm.buffer.asUint8List(), format: format);
}

/// fake の文での距離の書き方。帯の説明（括弧の中の数値）は付けない。
String _place(GuideDistanceBand band) => distanceLabel(band).split('（').first;
