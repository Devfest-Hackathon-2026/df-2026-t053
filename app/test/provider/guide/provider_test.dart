import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/model/guide/model.dart';
import 'package:app/provider/guide/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import 'support.dart';

void main() {
  late Directory root;
  late ProviderContainer container;
  late List<StreamController<NearbyGuideEvent>> streams;
  late List<FakeGuidePlayer> players;
  late List<ExplainNearbyRequest> requests;
  late int releases;
  late Duration deadline;
  GuideNotifier notifier() => container.read(guideProvider.notifier);
  GuideState state() => container.read(guideProvider);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('guide-test-');
    streams = [];
    players = [];
    requests = [];
    releases = 0;
    deadline = const Duration(seconds: 60);
    container = ProviderContainer(
      overrides: [
        guideDeadlineProvider.overrideWith((ref) => deadline),
        guideApiClientProvider.overrideWithValue(
          GuideApiClient(
            explainNearby: (value) {
              requests.add(value);
              final stream = StreamController<NearbyGuideEvent>(sync: true);
              streams.add(stream);
              return stream.stream;
            },
            release: () async {
              releases++;
            },
          ),
        ),
        guideTemporaryDirectoryProvider.overrideWithValue(() async => root),
        guideAudioPlayerFactoryProvider.overrideWithValue(() {
          final player = FakeGuidePlayer();
          players.add(player);
          return player;
        }),
      ],
    );
    container.listen(guideProvider, (_, _) {});
  });
  tearDown(() async {
    await notifier().close();
    container.dispose();
    for (final stream in streams) {
      unawaited(stream.close());
    }
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('本文を先に表示し、lastと正常終了・WAV検証後だけ再生できる', () async {
    await notifier().generate(request());
    streams.single.add(textEvent());
    expect(state().text?.text, '木の梁を組み合わせた屋根です。');
    streams.single.add(chunk());
    expect(state().phase, GuidePhase.receiving);
    await notifier().togglePlayback();
    expect(players, isEmpty);
    await streams.single.close();
    await eventually(() => state().phase == .ready);
    expect(releases, 1);
    expect(await File(players.single.path ?? '').readAsBytes(), wav());
    expect(players.single.plays, 0);
    await notifier().togglePlayback();
    expect(state().phase, GuidePhase.playing);
    await notifier().togglePlayback();
    expect(state().phase, GuidePhase.ready);
    await notifier().close();
    expect(players.single.disposed, isTrue);
    expect(await root.list().toList(), isEmpty);
  });

  for (final reason in GuideAudioUnavailableReason.values) {
    test('利用不可 $reason は本文を残して部分音声を捨てる', () async {
      await notifier().generate(request());
      streams.single.add(textEvent().copyWith(aiGenerated: false));
      streams.single.add(chunk(last: false));
      streams.single.add(
        GuideAudioUnavailable(guideId: guideId, reason: reason),
      );
      expect(state().phase, GuidePhase.unavailable);
      expect(state().text, isNotNull);
      expect(players, isEmpty);
      await eventually(() => releases == 1);
      expect(await root.list().toList(), isEmpty);
    });
  }

  final invalidEvents = <String, List<NearbyGuideEvent> Function()>{
    '音声が先頭': () => [chunk()],
    '本文重複': () => [textEvent(), textEvent()],
    '別guideId': () => [textEvent(), chunk().copyWith(guideId: otherId)],
    '欠番': () => [textEvent(), chunk(sequence: 1)],
    '重複': () => [textEvent(), chunk(last: false), chunk()],
    'last後のchunk': () => [textEvent(), chunk(), chunk(sequence: 1)],
    'MIME不正': () => [textEvent(), chunk().copyWith(contentType: 'audio/mp3')],
    '空chunk': () => [textEvent(), chunk(bytes: Uint8List(0))],
    'chunk上限超': () => [textEvent(), chunk(bytes: Uint8List(32769))],
    '壊れたWAV': () => [textEvent(), chunk(bytes: Uint8List(48))],
    'lastなし終了': () => [textEvent(), chunk(last: false)],
    '本文だけ終了': () => [textEvent()],
  };
  for (final entry in invalidEvents.entries) {
    test(entry.key, () async {
      await notifier().generate(request());
      for (final event in entry.value()) {
        streams.single.add(event);
      }
      await streams.single.close();
      await eventually(() => state().phase == .unavailable);
      expect(state().failure, GuideFailure.invalidAudio);
      expect(players, isEmpty);
      if (entry.key != '音声が先頭') expect(state().text, isNotNull);
    });
  }

  test('10MiBを超えたら受信を取り消す', () async {
    await notifier().generate(request());
    streams.single.add(textEvent());
    for (var i = 0; i <= 320; i++) {
      streams.single.add(
        chunk(sequence: i, last: false, bytes: Uint8List(32768)),
      );
    }
    expect(state().phase, GuidePhase.unavailable);
    expect(players, isEmpty);
  });

  test('last後でもtransport errorなら音声を使わない', () async {
    await notifier().generate(request());
    streams.single.add(textEvent());
    streams.single.add(chunk());
    streams.single.addError(StateError('接続切断'));
    expect(state().text, isNotNull);
    expect(state().phase, GuidePhase.unavailable);
    expect(players, isEmpty);
  });

  test('再生成は旧本文・音声をクリアし、旧応答を無視する', () async {
    await notifier().generate(request());
    streams.first.add(textEvent(text: '古い本文'));
    final newRequest = request();
    final pending = notifier().generate(newRequest);
    newRequest.positionX = 999;
    streams.first.add(chunk());
    await pending;
    expect(state().text, isNull);
    expect(requests.last.positionX, 10);
    streams.last.add(textEvent(text: '新しい本文'));
    streams.first.add(textEvent(text: '遅い旧本文'));
    expect(state().text?.text, '新しい本文');
    expect(players, isEmpty);
  });

  test('ネイティブ準備中に閉じても再生せずファイルを消す', () async {
    final ready = Completer<void>();
    container.updateOverrides([
      guideDeadlineProvider.overrideWith((ref) => deadline),
      guideApiClientProvider.overrideWithValue(
        GuideApiClient(
          explainNearby: (_) => Stream.fromIterable([textEvent(), chunk()]),
          release: () async {},
        ),
      ),
      guideTemporaryDirectoryProvider.overrideWithValue(() async => root),
      guideAudioPlayerFactoryProvider.overrideWithValue(() {
        final player = FakeGuidePlayer()..loading = ready;
        players.add(player);
        return player;
      }),
    ]);
    await notifier().generate(request());
    await eventually(() => players.isNotEmpty && players.single.path != null);
    await notifier().close();
    ready.complete();
    await Future<void>.delayed(Duration.zero);
    expect(state().phase, GuidePhase.idle);
    expect(players.single.disposed, isTrue);
    expect(players.single.plays, 0);
    expect(await root.list().toList(), isEmpty);
  });
  for (final entry in <String, GuideFailure>{
    ApiErrorReasons.noGuideTarget: .noTarget,
    ApiErrorReasons.invalidCamera: .outOfArea,
    ApiErrorReasons.guideDisabled: .disabled,
    ApiErrorReasons.sessionExpired: .expired,
    ApiErrorReasons.sessionCompleted: .completed,
    ApiErrorReasons.guideRateLimited: .rateLimited,
  }.entries) {
    test('公開エラー ${entry.key} を画面向けの分類にする', () async {
      await notifier().generate(request());
      streams.single.addError(
        ApiException(
          code: entry.value == .rateLimited
              ? .resourceExhausted
              : .failedPrecondition,
          reason: entry.key,
          message: '表示してはいけない内部情報',
        ),
      );
      expect(state().failure, entry.value);
      expect(state().text, isNull);
      expect(players, isEmpty);
    });
  }
  test('GUIDE_RATE_LIMITEDの待ち秒数の間は要求せず、過ぎたら再生成できる（#223）', () async {
    await notifier().generate(request());
    streams.single.addError(
      ApiException(
        code: .resourceExhausted,
        reason: ApiErrorReasons.guideRateLimited,
        message: '表示してはいけない内部情報',
        retryAfterSeconds: 1,
      ),
    );
    expect(state().failure, GuideFailure.rateLimited);
    expect(state().retryAfterSeconds, 1);
    await notifier().generate(request());
    expect(requests, hasLength(1));
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(state().retryAfterSeconds, isNull);
    expect(state().failure, GuideFailure.rateLimited);
    await notifier().generate(request());
    expect(requests, hasLength(2));
  });
  test('ほかの失敗では待ち秒数を持たず、閉じると待ちを解除する', () async {
    await notifier().generate(request());
    streams.single.addError(
      ApiException(
        code: .failedPrecondition,
        reason: ApiErrorReasons.noGuideTarget,
        message: '内部情報',
        retryAfterSeconds: 10,
      ),
    );
    expect(state().retryAfterSeconds, isNull);
    await notifier().generate(request());
    streams.last.addError(
      ApiException(
        code: .resourceExhausted,
        reason: ApiErrorReasons.guideRateLimited,
        message: '内部情報',
        retryAfterSeconds: 10,
      ),
    );
    expect(state().retryAfterSeconds, 10);
    await notifier().close();
    expect(state().retryAfterSeconds, isNull);
    await notifier().generate(request());
    expect(requests, hasLength(3));
  });
  test('旧購読の解放待ちで期限に達したら新たな生成を始めない', () async {
    deadline = const Duration(milliseconds: 25);
    await notifier().generate(request());
    final cancelled = Completer<void>();
    addTearDown(() {
      if (!cancelled.isCompleted) cancelled.complete();
    });
    streams.single.onCancel = () => cancelled.future;
    final retry = notifier().generate(request());
    await eventually(() => state().failure == .timeout);
    expect(requests, hasLength(1));
    cancelled.complete();
    await retry;
    expect(requests, hasLength(1));
    expect(state().failure, GuideFailure.timeout);
  });
  test('購読のcancelが失敗しても接続の解放を試みる', () async {
    await notifier().generate(request());
    streams.single.onCancel = () => throw StateError('cancel failure');
    await notifier().close();
    expect(releases, 1);
    expect(state().phase, GuidePhase.idle);
  });
}
