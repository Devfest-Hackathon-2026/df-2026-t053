import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/ports/guide_admission.dart';
import '../../domain/ports/guide_cancellation.dart';
import '../../domain/ports/guide_speech_generator.dart';
import '../dto/guide_output.dart';
import '../dto/guide_text_result.dart';
import 'compose_guide_text.dart';
import 'guide_preconditions.dart';

/// DBはloadの短い区間だけ。生成・配信中はゲートを保持しない。
class ExplainNearby({
  required final ComposeGuideText text,
  required final GuideSpeechGenerator speech,
  required final GuideAdmission admission,
  required final bool Function() enabled,
  final Duration textLimit = const Duration(seconds: 15),
  final Duration speechLimit = const Duration(seconds: 30),
}) {
  Stream<GuideOutput> execute({
    required UuidValue userId,
    required String locale,
    required Future<List<GuideMaterial>> Function() load,
    required Duration Function() remaining,
  }) {
    final cancellation = GuideCancellation();
    final controller = StreamController<GuideOutput>();
    StreamSubscription<GuideOutput>? upstream;
    Timer? deadline;
    var deadlineExpired = false;
    Timer? stopCheck;
    void cancelGeneration() {
      cancellation.cancel();
      if (upstream?.isPaused ?? false) upstream?.resume();
    }

    void stop() {
      deadline?.cancel();
      stopCheck?.cancel();
      cancellation.cancel();
    }

    // addStreamの取消はasync*のawait完了を待つため、先に上流へ取消を通知する。
    controller.onCancel = () {
      stop();
      return upstream?.cancel();
    };
    controller.onPause = () => upstream?.pause();
    controller.onResume = () => upstream?.resume();
    controller.onListen = () {
      final lifetime = remaining();
      deadline = Timer(lifetime > Duration.zero ? lifetime : Duration.zero, () {
        // Timerと残り時間の時計の精度差があっても、期限取消を購読取消と取り違えない。
        deadlineExpired = true;
        cancelGeneration();
      });
      stopCheck = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!enabled()) cancelGeneration();
      });
      upstream =
          _events(
            userId,
            locale,
            load,
            remaining,
            cancellation,
            () => deadlineExpired,
          ).listen(
            controller.add,
            onError: controller.addError,
            onDone: () {
              stop();
              unawaited(controller.close());
            },
          );
    };
    return controller.stream;
  }

  Stream<GuideOutput> _events(
    UuidValue userId,
    String locale,
    Future<List<GuideMaterial>> Function() load,
    Duration Function() remaining,
    GuideCancellation cancellation,
    bool Function() deadlineExpired,
  ) async* {
    rejectUnsupportedGuideLocale(locale);
    if (!enabled()) rejectDisabledGuide();
    GuideLease? lease;
    var sentText = false;
    try {
      final materials = await load();
      // 所有者・期限・姿勢・歩行領域・資料の検査を通ってから利用制限を消費する（#223）。
      // 検査で終わった要求は Gemini を呼ばないので、待ち時間と回数を使わせない。
      lease = admission.acquire(userId);
      _check(cancellation, remaining);
      final textTimeout = _limit(textLimit, remaining());
      final textCancel = GuideCancellation();
      final result = await _cancelWith(cancellation, textCancel, () async {
        try {
          return await text
              .execute(
                materials,
                timeout: textTimeout,
                cancellation: textCancel,
              )
              .timeout(textTimeout);
        } on TimeoutException {
          textCancel.cancel();
          final first = materials.first;
          return GuideTextResult(
            text: first.fallbackText,
            aiGenerated: false,
            structureIds: [first.structureId],
            sources: first.sources,
            fallbackReason: .timeout,
          );
        }
      });
      _check(cancellation, remaining);
      sentText = true;
      yield GuideTextOutput(result, [
        for (final m in materials)
          if (result.structureIds.contains(m.structureId)) m.name,
      ]);
      if (!result.aiGenerated) {
        yield GuideUnavailableOutput(.textFallback);
        return;
      }
      _check(cancellation, remaining);
      final speechTimeout = _limit(speechLimit, remaining());
      final speechCancel = GuideCancellation();
      final Uint8List wav;
      try {
        wav = await _cancelWith(
          cancellation,
          speechCancel,
          () => speech
              .synthesize(
                result.text,
                timeout: speechTimeout,
                cancellation: speechCancel,
              )
              .timeout(speechTimeout),
        );
      } on TimeoutException {
        speechCancel.cancel();
        yield GuideUnavailableOutput(.timeout);
        return;
      } on GuideSpeechException catch (error) {
        yield GuideUnavailableOutput(
          error.reason == .timeout ? .timeout : .ttsFailed,
        );
        return;
      }
      if (wav.isEmpty || wav.length > kGuideAudioMaxBytes) {
        yield GuideUnavailableOutput(.ttsFailed);
        return;
      }
      for (
        var offset = 0, sequence = 0;
        offset < wav.length;
        offset += 32768, sequence++
      ) {
        _check(cancellation, remaining);
        final end = math.min(offset + 32768, wav.length);
        yield GuideAudioOutput(
          sequence,
          ByteData.sublistView(wav, offset, end),
          end == wav.length,
        );
        // event loopに戻して切断・停止・期限を観測する。pauseは上流購読へ伝播する。
        await Future<void>.delayed(Duration.zero);
      }
    } on GuideCancelledException {
      if (!enabled()) {
        if (sentText) {
          yield GuideUnavailableOutput(.disabled);
        } else {
          throw const GuidePreconditionException(.disabled);
        }
      } else if (deadlineExpired() || remaining() <= Duration.zero) {
        if (sentText) {
          yield GuideUnavailableOutput(.timeout);
        } else {
          throw const GuidePreconditionException(.deadline);
        }
      }
      // 購読取消ならイベントを追加しない。
    } finally {
      lease?.release();
    }
  }
}

Duration _limit(Duration stage, Duration remaining) =>
    stage < remaining ? stage : remaining;
void _check(GuideCancellation cancellation, Duration Function() remaining) {
  if (cancellation.isCancelled || remaining() <= Duration.zero) {
    throw const GuideCancelledException();
  }
}

Future<T> _cancelWith<T>(
  GuideCancellation parent,
  GuideCancellation child,
  Future<T> Function() operation,
) async {
  final listener = parent.whenCancelled.asStream().listen(
    (_) => child.cancel(),
  );
  try {
    if (parent.isCancelled) throw const GuideCancelledException();
    return await Future.any([
      operation(),
      parent.whenCancelled.then<T>((_) {
        throw const GuideCancelledException();
      }),
    ]);
  } finally {
    await listener.cancel();
    child.cancel();
  }
}
