import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

part 'model.freezed.dart';

enum GuidePhase { idle, receiving, ready, playing, unavailable }

enum GuideFailure {
  disconnected,
  invalidAudio,
  timeout,
  audioUnavailable,
  playback,
  notConnected,
  noTarget,

  /// 位置が出題の歩行領域の外（INVALID_CAMERA）。
  outOfArea,
  disabled,
  rateLimited,
  expired,
  completed,
}

@freezed
abstract class GuideState with _$GuideState {
  const factory GuideState({
    GuideText? text,
    @Default(GuidePhase.idle) GuidePhase phase,
    GuideFailure? failure,

    /// GUIDE_RATE_LIMITED で、再生成できるまでの秒数（サーバーの retryAfterSeconds）。
    /// 待っている間だけ値を持ち、待ち時間が過ぎたら null に戻す。
    int? retryAfterSeconds,
  }) = _GuideState;
}
