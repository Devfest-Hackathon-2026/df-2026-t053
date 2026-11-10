import 'dart:async';
import 'dart:typed_data';

import 'package:photohunt_server/src/application/dto/guide_output.dart';
import 'package:photohunt_server/src/application/dto/guide_text_result.dart';
import 'package:photohunt_server/src/application/usecase/compose_guide_text.dart';
import 'package:photohunt_server/src/application/usecase/explain_nearby.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/ports/guide_admission.dart';
import 'package:photohunt_server/src/domain/ports/guide_cancellation.dart';
import 'package:photohunt_server/src/domain/ports/guide_speech_generator.dart';
import 'package:photohunt_server/src/infrastructure/gemini/fake_guide_generators.dart';
import 'package:photohunt_server/src/infrastructure/guide/in_memory_guide_admission.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

class _Speech(final int size) implements GuideSpeechGenerator {
  late final Uint8List bytes = Uint8List(size);
  @override
  Future<Uint8List> synthesize(
    String text, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async => bytes;
}

class _WaitingSpeech() implements GuideSpeechGenerator {
  final started = Completer<void>();
  final stopped = Completer<void>();
  @override
  Future<Uint8List> synthesize(
    String text, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async {
    final signal = cancellation;
    if (signal == null) throw StateError('取消が必要');
    started.complete();
    await signal.whenCancelled;
    stopped.complete();
    throw const GuideCancelledException();
  }
}

const materials = [
  GuideMaterial(
    structureId: 1,
    name: '大屋根',
    facts: '登録済みの事実',
    fallbackText: '固定の説明',
    sources: [],
    direction: .front,
    distanceMeters: 10,
  ),
];
void main() {
  const uuid = Uuid();
  ExplainNearby useCase({
    GuideSpeechGenerator? speech,
    FakeGuideBehavior textBehavior = .normal,
    Duration textDelay = Duration.zero,
    Duration textLimit = const Duration(seconds: 15),
    Duration speechLimit = const Duration(seconds: 30),
    bool Function()? enabled,
    InMemoryGuideAdmission? admission,
  }) => ExplainNearby(
    text: ComposeGuideText(
      FakeGuideTextGenerator(behavior: textBehavior, delay: textDelay),
    ),
    speech: speech ?? FakeGuideSpeechGenerator(),
    admission: admission ?? InMemoryGuideAdmission(),
    enabled: enabled ?? () => true,
    textLimit: textLimit,
    speechLimit: speechLimit,
  );
  Stream<GuideOutput> run(
    ExplainNearby uc, {
    String locale = 'ja-JP',
    Duration lifetime = const Duration(seconds: 55),
  }) {
    final watch = Stopwatch()..start();
    return uc.execute(
      userId: uuid.v4obj(),
      locale: locale,
      load: () async => materials,
      remaining: () => lifetime - watch.elapsed,
    );
  }

  for (final size in [32768, 32769]) {
    test('$size bytesは欠番なく分割し最後だけlast', () async {
      final speech = _Speech(size);
      final events = await run(useCase(speech: speech)).toList();
      expect(events.first, isA<GuideTextOutput>());
      final chunks = events.whereType<GuideAudioOutput>().toList();
      expect(chunks.length, size == 32768 ? 1 : 2);
      expect(
        chunks.map((e) => e.sequence),
        List.generate(chunks.length, (i) => i),
      );
      expect(
        chunks.map((e) => e.data.lengthInBytes).reduce((a, b) => a + b),
        size,
      );
      expect(chunks.where((e) => e.last), hasLength(1));
      expect(chunks.last.last, isTrue);
      for (final chunk in chunks) {
        expect(chunk.data.buffer, speech.bytes.buffer);
      }
    });
  }
  for (final behavior in [
    FakeGuideBehavior.empty,
    FakeGuideBehavior.refused,
    FakeGuideBehavior.timeout,
  ]) {
    test('本文$behaviorは固定文とTEXT_FALLBACKだけ', () async {
      final events = await run(
        useCase(
          textBehavior: behavior,
          textLimit: const Duration(milliseconds: 10),
        ),
      ).toList();
      expect(events, hasLength(2));
      expect(
        events.first,
        isA<GuideTextOutput>().having((e) => e.result.aiGenerated, 'ai', false),
      );
      expect(
        events.last,
        isA<GuideUnavailableOutput>().having(
          (e) => e.reason,
          'reason',
          GuideAudioFailure.textFallback,
        ),
      );
    });
  }
  test('待ち上限を無視した本文生成も固定文になる', () async {
    final events = await run(
      useCase(
        textDelay: const Duration(milliseconds: 100),
        textLimit: const Duration(milliseconds: 10),
      ),
    ).toList();
    expect(
      events.last,
      isA<GuideUnavailableOutput>().having(
        (e) => e.reason,
        'reason',
        GuideAudioFailure.textFallback,
      ),
    );
  });
  test('TTS失敗・時間超過・サイズ超過は本文の後に通知だけ', () async {
    for (final (speech, reason) in [
      (
        FakeGuideSpeechGenerator(behavior: .unavailable),
        GuideAudioFailure.ttsFailed,
      ),
      (FakeGuideSpeechGenerator(behavior: .timeout), GuideAudioFailure.timeout),
      (_Speech(kGuideAudioMaxBytes + 1), GuideAudioFailure.ttsFailed),
    ]) {
      final events = await run(
        useCase(speech: speech, speechLimit: const Duration(milliseconds: 10)),
      ).toList();
      expect(events, hasLength(2));
      expect(
        events.last,
        isA<GuideUnavailableOutput>().having((e) => e.reason, 'reason', reason),
      );
    }
  });
  test('全体期限はTTSの個別期限より先に切れ、上流を止める', () async {
    final speech = _WaitingSpeech();
    // 全体期限はTTSの個別期限（30秒）より十分短く、本文の生成（fake）には
    // 十分長くする。短すぎると負荷の高い実行で本文の前に期限が切れ、
    // 確かめたいTTS中の期限切れにならない（#144）。
    final events = await run(
      useCase(speech: speech),
      lifetime: const Duration(seconds: 1),
    ).toList();
    await speech.stopped.future;
    expect(events.first, isA<GuideTextOutput>());
    expect(
      events.last,
      isA<GuideUnavailableOutput>().having(
        (e) => e.reason,
        'reason',
        GuideAudioFailure.timeout,
      ),
    );
  });
  test('期限タイマー発火時に残り時間が正でもtimeoutを通知する', () async {
    final speech = _WaitingSpeech();
    final events = await useCase(speech: speech)
        .execute(
          userId: uuid.v4obj(),
          locale: 'ja-JP',
          load: () async => materials,
          // 時計の精度差を決定的に再現する。再計算値だけでは期限切れにならない。
          remaining: () => const Duration(milliseconds: 50),
        )
        .toList();
    await speech.stopped.future;
    expect(events.first, isA<GuideTextOutput>());
    expect(
      events.last,
      isA<GuideUnavailableOutput>().having(
        (event) => event.reason,
        'reason',
        GuideAudioFailure.timeout,
      ),
    );
  });

  test('取消は上流を止め、予約枠を返す', () async {
    final speech = _WaitingSpeech();
    final admission = InMemoryGuideAdmission();
    final subscription = run(useCase(speech: speech, admission: admission))
        .listen((_) {});
    await speech.started.future;
    await subscription.cancel();
    await speech.stopped.future;
    // 取消が枠を返していれば2件とも受理できる。
    final a = admission.acquire(uuid.v4obj());
    final b = admission.acquire(uuid.v4obj());
    a.release();
    b.release();
  });
  test('本文後に停止するとUNKNOWN相当で終わり、上流を止める', () async {
    var enabled = true;
    final speech = _WaitingSpeech();
    final pending = run(useCase(speech: speech, enabled: () => enabled))
        .toList();
    await speech.started.future;
    enabled = false;
    final events = await pending;
    await speech.stopped.future;
    expect(
      events.last,
      isA<GuideUnavailableOutput>().having(
        (e) => e.reason,
        'reason',
        GuideAudioFailure.disabled,
      ),
    );
  });
  test('pause中にchunkを先送りせずresumeから続ける', () async {
    final events = <GuideOutput>[];
    final paused = Completer<void>();
    final done = Completer<void>();
    late StreamSubscription<GuideOutput> sub;
    sub = run(useCase()).listen((event) {
      events.add(event);
      if (event is GuideTextOutput) {
        sub.pause();
        paused.complete();
      }
    }, onDone: done.complete);
    await paused.future;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(events, hasLength(1));
    sub.resume();
    await done.future;
    expect(events.whereType<GuideAudioOutput>(), hasLength(2));
  });
  test('locale・停止はイベントより前に失敗する', () async {
    await expectLater(
      run(useCase(), locale: 'en-US'),
      emitsError(isA<GuidePreconditionException>()),
    );
    await expectLater(
      run(useCase(enabled: () => false)),
      emitsError(isA<GuidePreconditionException>()),
    );
  });
  test('クールダウン・UTC日次30回・翌日リセット・同時2件', () {
    var now = DateTime.utc(2026, 11, 9);
    final admission = InMemoryGuideAdmission(now: () => now);
    final id = uuid.v4obj();
    admission.acquire(id).release();
    expect(
      () => admission.acquire(id),
      throwsA(
        isA<GuideRateLimitedException>().having(
          (e) => e.retryAfterSeconds,
          'retry',
          10,
        ),
      ),
    );
    for (var i = 1; i < 30; i++) {
      now = now.add(const Duration(seconds: 10));
      admission.acquire(id).release();
    }
    now = now.add(const Duration(seconds: 10));
    expect(
      () => admission.acquire(id),
      throwsA(isA<GuideRateLimitedException>()),
    );
    now = DateTime.utc(2026, 11, 10);
    final a = admission.acquire(id);
    final b = admission.acquire(uuid.v4obj());
    expect(
      () => admission.acquire(uuid.v4obj()),
      throwsA(isA<GuideRateLimitedException>()),
    );
    a.release();
    a.release();
    final c = admission.acquire(uuid.v4obj());
    b.release();
    c.release();
  });
  test('事前検査で終わった要求は利用制限を消費しない（#223）', () async {
    final admission = InMemoryGuideAdmission();
    final uc = useCase(admission: admission);
    final id = uuid.v4obj();
    for (final error in <Exception>[
      const NoGuideTargetException(),
      const InvalidGuidePoseException(),
      const GuidePreconditionException(.expired),
    ]) {
      await expectLater(
        uc.execute(
          userId: id,
          locale: 'ja-JP',
          load: () async => throw error,
          remaining: () => const Duration(seconds: 55),
        ),
        emitsError(same(error)),
      );
    }
    // 待ち時間も同時枠も使っていないので、すぐに受け付ける。
    final a = admission.acquire(id);
    final b = admission.acquire(uuid.v4obj());
    a.release();
    b.release();
  });
  test('検査を通った要求は利用制限を消費し、続けて押すと制限する', () async {
    final admission = InMemoryGuideAdmission();
    final uc = useCase(admission: admission);
    final id = uuid.v4obj();
    Stream<GuideOutput> start() => uc.execute(
      userId: id,
      locale: 'ja-JP',
      load: () async => materials,
      remaining: () => const Duration(seconds: 55),
    );
    await start().toList();
    await expectLater(start(), emitsError(isA<GuideRateLimitedException>()));
  });
}
