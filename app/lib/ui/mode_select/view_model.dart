import 'dart:async';
import 'dart:developer';

import 'package:app/model/assets/model.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/model/play/model.dart';
import 'package:app/model/health/model.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/provider/health/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/provider/profile/provider.dart';
import 'package:app/provider/ranking/provider.dart';
import 'package:app/ui/components/clue_photo_message.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_model.freezed.dart';
part 'view_model.g.dart';

enum ModeSelectFlow { none, preparing, chooseSpot, done }

enum ModeSelectBoot { booting, ready, failed }

@freezed
abstract class ModeSelectState with _$ModeSelectState {
  const factory ModeSelectState({
    @Default('旅人4821') String nickname,
    @Default(ModeSelectFlow.none) ModeSelectFlow flow,
    @Default(ExplorationMode.free) ExplorationMode mode,
    @Default(null) String? spot,
    @Default(0) double progress,
    @Default(ModeSelectBoot.booting) ModeSelectBoot boot,
    @Default([]) List<SpawnEntrance> entrances,
    String? notice,
    @Default(PlayPhase.idle) PlayPhase playPhase,
    PlayMode? pendingSessionMode,
  }) = _ModeSelectState;
}

@riverpod
class ModeSelectViewModel extends _$ModeSelectViewModel {
  @override
  ModeSelectState build() {
    // watch するとセッション更新のたびに build がやり直しになり、
    // 進行中の開始処理と画面状態が破棄される。変化だけを反映する。
    final play = ref.read(playProvider);
    ref.listen(playProvider, (previous, next) {
      state = state.copyWith(
        playPhase: next.phase,
        pendingSessionMode: next.session?.mode,
      );
    });
    ref.onDispose(() {
      _prepareGeneration++;
      _bootGeneration++;
      _timer?.cancel();
    });
    // 探索画面に遷移しても SceneAdapter が破棄されないよう、
    // ViewModel 自身の生存期間中はプロバイダーを購読しておく。
    ref.watch(sceneAdapterProvider);
    ref.watch(profileProvider);
    ref.watch(healthProvider);
    final generation = ++_bootGeneration;
    unawaited(Future<void>.microtask(() => _boot(generation)));
    return ModeSelectState(
      playPhase: play.phase,
      pendingSessionMode: play.session?.mode,
    );
  }

  Timer? _timer;
  int _prepareGeneration = 0;
  int _bootGeneration = 0;

  /// 起動時の認証復旧・プロフィール・出題取得と、保留中の撮影の照会。
  Future<void> _boot(int generation) async {
    // build()から呼ばれた直後はstateへ触れない。初期状態がbootingのため、
    // 最初の代入はawaitを挟んだ後（成功・失敗時）でよい。
    if (!ref.mounted || generation != _bootGeneration) return;
    try {
      await ref.read(healthProvider.notifier).ping();
      if (!ref.mounted || generation != _bootGeneration) return;
      await ref.read(authProvider.notifier).ensureSignedIn();
      if (!ref.mounted || generation != _bootGeneration) return;
      final profile = await ref.read(profileProvider.notifier).getMyProfile();
      if (!ref.mounted || generation != _bootGeneration) return;
      await ref.read(playProvider.notifier).restorePending();
      if (!ref.mounted || generation != _bootGeneration) return;
      final play = ref.read(playProvider);
      final revisionId =
          play.session?.revisionId ??
          (play.phase == .submitUnknown ? play.pendingShot?.revisionId : null);
      if (revisionId == null) {
        await ref.read(challengeProvider.notifier).loadCurrent();
      } else {
        await ref.read(challengeProvider.notifier).loadRevision(revisionId);
      }
      if (!ref.mounted || generation != _bootGeneration) {
        return;
      }
      state = state.copyWith(boot: .ready, nickname: profile.nickname);
    } catch (error, stackTrace) {
      log('起動時の準備に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (!ref.mounted || generation != _bootGeneration) {
        return;
      }
      state = state.copyWith(
        boot: .failed,
        notice: switch (error) {
          HealthFailure(kind: .unreachable) => 'APIに届きません。接続を確認してください。',
          HealthFailure(kind: .releaseMismatch) => 'APIの版が一致しません。接続先を確認してください。',
          ChallengeFailure(kind: .notFound) => '公開中の出題がありません。',
          _ => '通信または認証に失敗しました。',
        },
      );
    }
  }

  /// 起動時の準備を最初からやり直す。
  void retryBoot() {
    if (state.boot == .booting) return;
    state = state.copyWith(boot: .booting, notice: null);
    unawaited(_boot(++_bootGeneration));
  }

  /// 照会不通でセッションが未確定なら、モードを推測せず再照会する。
  Future<ExplorationMode?> resumePending() async {
    try {
      final playNotifier = ref.read(playProvider.notifier);
      await playNotifier.checkShotResult();
      if (!ref.mounted) return null;
      final session = ref.read(playProvider).session;
      if (session == null) throw const PlayFailure(.rejected);
      return switch (session.mode) {
        .free => ExplorationMode.free,
        .near => ExplorationMode.near,
        .unknown => throw const PlayFailure(.rejected),
      };
    } catch (error, stackTrace) {
      log('保留撮影の再開に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (ref.mounted) {
        state = state.copyWith(notice: '前回のプレイを確認できません。接続を確認して再試行してください。');
      }
      return null;
    }
  }

  Future<void> startPlay(ExplorationMode mode) async {
    if (state.boot != .ready || state.flow == .preparing) {
      return;
    }
    final revision = ref.read(challengeProvider).revision;
    if (revision == null) {
      state = state.copyWith(notice: '出題を読み込めませんでした。');
      return;
    }
    if (mode == .free) {
      final entrances = [
        for (final config in revision.modes)
          if (config.mode == .free) ...config.entrances,
      ];
      if (entrances.isEmpty) {
        state = state.copyWith(notice: '入口を確認できませんでした。');
        return;
      }
      state = state.copyWith(
        mode: mode,
        spot: null,
        flow: .chooseSpot,
        entrances: entrances,
        notice: null,
      );
      return;
    }
    await _begin(mode, spawnPointId: null, spot: null);
  }

  /// 自由探索で公開された入口を選び、その ID でセッションを作る。
  void chooseEntrance(SpawnEntrance entrance) {
    if (state.flow != .chooseSpot || state.boot != .ready) return;
    final known = state.entrances.any((e) => e.id == entrance.id);
    if (!known) {
      state = state.copyWith(flow: .none, notice: '入口を確認できませんでした。');
      return;
    }
    unawaited(_begin(.free, spawnPointId: entrance.id, spot: entrance.label));
  }

  Future<void> _begin(
    ExplorationMode mode, {
    required int? spawnPointId,
    required String? spot,
  }) async {
    final revision = ref.read(challengeProvider).revision;
    if (revision == null) {
      state = state.copyWith(notice: '出題を読み込めませんでした。');
      return;
    }
    _timer?.cancel();
    final generation = ++_prepareGeneration;
    state = state.copyWith(
      mode: mode,
      spot: spot,
      flow: ModeSelectFlow.preparing,
      progress: 0,
      notice: null,
    );
    final adapter = ref.read(sceneAdapterProvider.notifier);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!ref.mounted || generation != _prepareGeneration) return;
      final photo = ref.read(cluePhotoProvider);
      final photoProgress = switch (photo.phase) {
        .ready => 1.0,
        .loading => photo.progress,
        _ => 0.0,
      };
      final model = adapter.loading.progress.value;
      state = state.copyWith(progress: (photoProgress + model) / 2);
    });
    try {
      // 写真を確認してからセッションを作る。区画manifestはセッション作成と
      // 並行して読み、区画はスポーンの周りを読む。探索画面の表示後に
      // 詳細度を入れ替えないため。開始点はセッションのスポーン。
      final play = ref.read(playProvider);
      final existing = play.session;
      final playMode = mode == .free ? PlayMode.free : PlayMode.near;
      final sameEntrance =
          mode != .free || existing?.spawnPointId == spawnPointId;
      final reuse =
          existing != null &&
          play.phase == .active &&
          existing.revisionId == revision.id &&
          existing.mode == playMode &&
          sameEntrance;
      if (reuse && existing.expireTime.isBefore(DateTime.now().toUtc())) {
        throw const PlayFailure(.sessionExpired);
      }
      await ref.read(cluePhotoProvider.notifier).ensureReady(revision);
      if (!ref.mounted || generation != _prepareGeneration) return;
      final session = reuse
          ? Future<PlaySession>.value(existing)
          : ref
                .read(playProvider.notifier)
                .createSession(
                  revisionId: revision.id,
                  mode: playMode,
                  spawnPointId: spawnPointId,
                );
      await adapter.loadModel(
        startAt: session.then(
          (session) => (x: session.spawn.positionX, z: session.spawn.positionZ),
        ),
      );
    } on AssetFailure catch (failure, stackTrace) {
      log(
        '手がかり写真の取得に失敗しました',
        error: failure.runtimeType,
        stackTrace: stackTrace,
      );
      if (!ref.mounted || generation != _prepareGeneration) return;
      _timer?.cancel();
      state = state.copyWith(
        flow: .none,
        notice: cluePhotoFailureMessage(failure.kind),
      );
      return;
    } on PlayFailure catch (failure) {
      if (!ref.mounted || generation != _prepareGeneration) {
        return;
      }
      _timer?.cancel();
      state = state.copyWith(flow: .none, notice: _startNotice(failure));
      if (failure.kind == .revisionNotPlayable) {
        // 更新中は旧版での再開始を止める。
        state = state.copyWith(boot: .booting);
        await _reloadRevision();
      }
      return;
    } catch (error, stackTrace) {
      _timer?.cancel();
      log('プレイの開始に失敗しました', error: error, stackTrace: stackTrace);
      if (!ref.mounted || generation != _prepareGeneration) {
        return;
      }
      state = state.copyWith(
        flow: .none,
        notice: '開始できませんでした。接続を確認して再度お試しください。',
      );
      return;
    }
    if (!ref.mounted || generation != _prepareGeneration) {
      return;
    }
    _timer?.cancel();
    state = state.copyWith(flow: .done, progress: 1);
  }

  Future<void> _reloadRevision() async {
    try {
      await ref.read(challengeProvider.notifier).loadCurrent();
      if (ref.mounted) state = state.copyWith(boot: .ready);
    } catch (error, stackTrace) {
      log('出題の再取得に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (ref.mounted) state = state.copyWith(boot: .failed);
    }
  }

  String _startNotice(PlayFailure failure) {
    return switch (failure.kind) {
      .revisionNotPlayable => '出題が更新されました。最新の出題で開始してください。',
      .sessionExpired => 'セッションの有効期限が切れました。再度お試しください。',
      .rateLimited =>
        failure.retryAfterSeconds == null
            ? '開始が集中しています。少し待ってからお試しください。'
            : '開始が集中しています。${failure.retryAfterSeconds}秒ほど待ってからお試しください。',
      .maintenance => 'メンテナンス中です。しばらくしてからお試しください。',
      .authentication => '認証を確認できませんでした。最初から読み直してください。',
      .unavailable => '通信できませんでした。接続を確認して再度お試しください。',
      _ => '開始できませんでした。',
    };
  }

  void cancelPrepare() {
    _prepareGeneration++;
    _timer?.cancel();
    ref.read(playProvider.notifier).clearSession();
    state = state.copyWith(flow: ModeSelectFlow.none);
  }

  /// 入口パネルを閉じる。準備の取消とは違い、進行中のセッションは残す。
  void closeEntranceChoice() {
    if (state.flow != .chooseSpot) return;
    state = state.copyWith(flow: .none);
  }

  void discardPending() {
    ref.read(playProvider.notifier).discardPending();
  }

  void resetFlow() {
    _timer?.cancel();
    state = state.copyWith(flow: ModeSelectFlow.none);
  }
}

/// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。
@Riverpod(retry: _noRecordRetry)
class ModeRecordViewModel extends _$ModeRecordViewModel {
  @override
  Future<String> build(PlayMode mode) async {
    final auth = ref.watch(authProvider);
    final revisionId = ref.watch(
      challengeProvider.select((value) => value.revision?.id),
    );
    ref.watch(playProvider.select((value) => value.result));
    if (auth.status != .signedIn || revisionId == null) {
      return '記録を確認する準備中です';
    }
    final provider = rankingProvider(revisionId, mode);
    ref.watch(provider);
    final entry = await ref.read(provider.notifier).getMyRankingEntry();
    return entry == null ? '未記録' : '自己ベスト ${entry.score}点 ／ ${entry.rank}位';
  }

  String get label => state.when(
    skipLoadingOnRefresh: false,
    skipLoadingOnReload: false,
    data: (value) => value,
    loading: () => '記録を確認しています',
    error: (_, _) => '記録を取得できませんでした',
  );

  void reload() => ref.invalidateSelf();
}

/// 読み取りの待ち上限後は失敗を表示し、利用者の再試行を待つ。
Duration? _noRecordRetry(int retryCount, Object error) => null;
