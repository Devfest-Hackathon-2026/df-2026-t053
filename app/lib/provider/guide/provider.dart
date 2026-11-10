import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/model/guide/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/guide/validation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// 認証の接続側と同じ生成Clientを使う。購読のcancel／正常終了により、
/// Serverpod SDKが他のstreamの有無を確認して不要な接続だけを閉じる。
/// closeStreamingMethodConnectionsは他の購読まで終了するため呼ばない。
@riverpod
GuideApiClient guideApiClient(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return GuideApiClient(
    explainNearby: (request) => client.guide.explainNearby(request),
    release: () async {},
  );
}

class const GuideApiClient({
  required final Stream<NearbyGuideEvent> Function(ExplainNearbyRequest)
  explainNearby,
  required final Future<void> Function() release,
});

class const GuideApiUnavailableException() implements Exception;

@riverpod
AudioPlayer Function() guideAudioPlayerFactory(Ref ref) => AudioPlayer.new;

@riverpod
Future<Directory> Function() guideTemporaryDirectory(Ref ref) =>
    getTemporaryDirectory;

@riverpod
Duration guideDeadline(Ref ref) => const Duration(seconds: 60);

/// 通信・検証・一時音声の寿命を担当。表示文言は探索ViewModelで決める。
@riverpod
class GuideNotifier extends _$GuideNotifier {
  _GuideRun? _run;
  Timer? _cooldown;
  int _generation = 0;
  Future<void> _cleanup = Future<void>.value();

  @override
  GuideState build() {
    // 接続先（認証主体）が変われば古い購読・音声を破棄する。
    ref.watch(guideApiClientProvider);
    ref.onDispose(() {
      _cooldown?.cancel();
      _generation++;
      final run = _run;
      _run = null;
      if (run != null) _retire(run);
    });
    return const GuideState();
  }

  bool _current(_GuideRun run) =>
      ref.mounted && identical(_run, run) && !run.disposed;

  Future<void> generate(ExplainNearbyRequest request) async {
    // 待ち時間の間は要求しない（サーバーは GUIDE_RATE_LIMITED を返すだけ）。
    if (state.retryAfterSeconds != null) return;
    final snapshot = request.copyWith();
    final generation = ++_generation;
    final previous = _run;
    _run = null;
    state = const GuideState(phase: .receiving);
    if (previous != null) _retire(previous);
    final run = _GuideRun(ref.read(guideApiClientProvider));
    _run = run;
    run.timer = Timer(
      ref.read(guideDeadlineProvider),
      () => _fail(run, .timeout),
    );
    // 旧購読の解放待ちも操作開始からの絶対期限に含める。
    await _cleanup;
    if (!_current(run) || generation != _generation) return;
    try {
      // DTOはmutableなので境界でコピーし、押した時点の値を固定する。
      run.subscription = run.client
          .explainNearby(snapshot)
          .listen(
            (event) => _event(run, event),
            onError: (Object error, StackTrace stack) {
              _log(error, stack);
              _fail(
                run,
                _failure(error),
                retryAfterSeconds: _retryAfter(error),
              );
            },
            onDone: () => unawaited(_complete(run)),
          );
    } catch (error, stack) {
      _log(error, stack);
      _fail(run, _failure(error));
    }
  }

  void unavailable() {
    unawaited(close());
    state = const GuideState(phase: .unavailable, failure: .notConnected);
  }

  void _event(_GuideRun run, NearbyGuideEvent event) {
    if (!_current(run)) return;
    if (event is GuideText) {
      if (state.text != null || run.sequence != 0 || run.last) {
        _fail(run, .invalidAudio);
        return;
      }
      state = state.copyWith(text: event.copyWith());
      return;
    }
    final text = state.text;
    if (text == null || text.guideId != event.guideId || run.last) {
      _fail(run, .invalidAudio);
      return;
    }
    switch (event) {
      case GuideAudioUnavailable():
        _fail(
          run,
          event.reason == .AUDIO_TIMEOUT ? .timeout : .audioUnavailable,
        );
      case GuideAudioChunk():
        final length = event.data.lengthInBytes;
        if (event.sequence != run.sequence ||
            event.contentType != 'audio/wav' ||
            length < 1 ||
            length > 32768 ||
            run.bytes.length + length > 10 * 1024 * 1024) {
          _fail(run, .invalidAudio);
          return;
        }
        run.bytes.add(
          event.data.buffer.asUint8List(event.data.offsetInBytes, length),
        );
        run.sequence++;
        run.last = event.last;
      case GuideText():
        // 本文は上で処理済み。
        break;
    }
  }

  Future<void> _complete(_GuideRun run) async {
    if (!_current(run)) return;
    if (!run.last || state.text == null) {
      _fail(run, .invalidAudio);
      return;
    }
    final bytes = run.bytes.takeBytes();
    if (!isCompleteGuideWav(bytes)) {
      _fail(run, .invalidAudio);
      return;
    }
    try {
      await run.releaseStream();
      if (!_current(run)) return;
      final root = await ref.read(guideTemporaryDirectoryProvider)();
      if (!_current(run)) return;
      final directory = await root.createTemp('photohunt-guide-');
      // close/dispose中にcreateTempが完了しても必ず回収する。
      if (!_current(run)) {
        await directory.delete(recursive: true);
        return;
      }
      run.directory = directory;
      final file = File('${directory.path}/guide.wav');
      await file.writeAsBytes(bytes, flush: true);
      if (!_current(run)) return;
      final player = ref.read(guideAudioPlayerFactoryProvider)();
      run.player = player;
      run.playerSubscription = player.playerStateStream.listen((value) {
        if (!_current(run) || state.phase == .receiving) return;
        state = state.copyWith(
          phase: value.playing && value.processingState != .completed
              ? .playing
              : .ready,
        );
      });
      run.errorSubscription = player.errorStream.listen((error) {
        _log(error, StackTrace.current);
        _fail(run, .playback);
      });
      await player.setFilePath(file.path);
      if (!_current(run)) return;
      run.timer?.cancel();
      state = state.copyWith(phase: .ready);
    } catch (error, stack) {
      if (_current(run)) {
        _log(error, stack);
        _fail(run, .playback);
      }
    }
  }

  Future<void> togglePlayback() async {
    final run = _run;
    if (run == null || !_current(run)) return;
    final player = run.player;
    if (player == null || (state.phase != .ready && state.phase != .playing)) {
      return;
    }
    final operation = ++run.playGeneration;
    final stopping = state.phase == .playing;
    state = state.copyWith(phase: stopping ? .ready : .playing);
    try {
      if (stopping) {
        await player.pause();
        if (!_current(run) || operation != run.playGeneration) return;
        await player.seek(Duration.zero);
      } else {
        await player.seek(Duration.zero);
        if (!_current(run) || operation != run.playGeneration) return;
        // playのFutureは再生終了まで完了しない。
        unawaited(
          player.play().catchError((Object error, StackTrace stack) {
            if (!_current(run)) return;
            _log(error, stack);
            _fail(run, .playback);
          }),
        );
      }
    } catch (error, stack) {
      if (!_current(run)) return;
      _log(error, stack);
      _fail(run, .playback);
    }
  }

  void _fail(_GuideRun run, GuideFailure failure, {int? retryAfterSeconds}) {
    if (!_current(run)) return;
    state = state.copyWith(
      phase: .unavailable,
      failure: failure,
      retryAfterSeconds: retryAfterSeconds,
    );
    _run = null;
    _retire(run);
    if (retryAfterSeconds != null) _startCooldown(retryAfterSeconds);
  }

  /// 待ち時間が過ぎたら再生成できる状態に戻す。閉じる・破棄で取り消す。
  void _startCooldown(int seconds) {
    _cooldown?.cancel();
    _cooldown = Timer(Duration(seconds: seconds), () {
      _cooldown = null;
      if (!ref.mounted) return;
      state = state.copyWith(retryAfterSeconds: null);
    });
  }

  void _retire(_GuideRun run) {
    _cleanup = Future.wait([_cleanup, run.dispose()]).then((_) {});
  }

  /// 同期的に世代を無効にし、その後ネイティブ資源を解放する。
  Future<void> close() async {
    _cooldown?.cancel();
    _cooldown = null;
    _generation++;
    final run = _run;
    _run = null;
    state = const GuideState();
    if (run != null) _retire(run);
    await _cleanup;
  }
}

GuideFailure _failure(Object error) {
  if (error is GuideApiUnavailableException) return .notConnected;
  if (error is ApiException) {
    return switch (error.reason) {
      ApiErrorReasons.noGuideTarget => .noTarget,
      ApiErrorReasons.invalidCamera => .outOfArea,
      ApiErrorReasons.guideDisabled => .disabled,
      ApiErrorReasons.sessionExpired => .expired,
      ApiErrorReasons.sessionCompleted => .completed,
      _ => error.code == .resourceExhausted ? .rateLimited : .disconnected,
    };
  }
  return .disconnected;
}

/// GUIDE_RATE_LIMITED の待ち秒数。ほかのエラー・秒数なしは null。
int? _retryAfter(Object error) => switch (error) {
  ApiException(code: .resourceExhausted, :final retryAfterSeconds?)
      when retryAfterSeconds > 0 =>
    retryAfterSeconds,
  _ => null,
};

void _log(Object error, StackTrace stack) =>
    log('ガイド処理に失敗しました', error: error.runtimeType, stackTrace: stack);

/// 1回の購読が所有する可変資源。公開データモデルではない。
class _GuideRun(final GuideApiClient client) {
  final bytes = BytesBuilder();
  int sequence = 0;
  int playGeneration = 0;
  bool last = false;
  bool disposed = false;
  Timer? timer;
  StreamSubscription<NearbyGuideEvent>? subscription;
  StreamSubscription<PlayerState>? playerSubscription;
  StreamSubscription<PlayerException>? errorSubscription;
  AudioPlayer? player;
  Directory? directory;
  Future<void>? _release;
  Future<void>? _disposal;

  Future<void> releaseStream() => _release ??= _releaseStream();
  Future<void> _releaseStream() async {
    try {
      await subscription?.cancel();
    } catch (error, stack) {
      _log(error, stack);
    }
    try {
      await client.release();
    } catch (error, stack) {
      _log(error, stack);
    }
  }

  Future<void> dispose() => _disposal ??= _dispose();
  Future<void> _dispose() async {
    disposed = true;
    timer?.cancel();
    bytes.clear();
    // 各資源は独立に解放し、一つの失敗で残りをリークさせない。
    for (final cleanup in <Future<void> Function()>[
      () async => playerSubscription?.cancel(),
      () async => errorSubscription?.cancel(),
      () async => player?.dispose(),
      releaseStream,
      () async {
        final dir = directory;
        if (dir != null && await dir.exists()) {
          await dir.delete(recursive: true);
        }
      },
    ]) {
      try {
        await cleanup();
      } catch (error, stack) {
        _log(error, stack);
      }
    }
  }
}
