import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' show FrameTiming, Offset;

import 'package:app/model/collision_grid.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/model/guide/model.dart';
import 'package:app/model/map/model.dart';
import 'package:app/model/play/model.dart';
import 'package:app/model/position.dart';
import 'package:app/model/scene_asset.dart';
import 'package:app/provider/assets/asset_store.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/guide/provider.dart';
import 'package:app/provider/map/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/usecase/play/collision_resolver.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:app/usecase/play/walkable_movement.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_scene/scene.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'view_model.freezed.dart';
part 'view_model.g.dart';

enum ExplorationPanel {
  none,
  photo,
  map,
  help,
  guide,
  teleport,
  exitConfirm,
  submitting,
  submitPending,
}

const List<String> kTeleportSpots = <String>[
  'コネクティングゾーン',
  'セービングゾーン',
  'エンパワーリングゾーン',
  'シグネチャーゾーン',
  '静けさの森ゾーン',
  '東ゲートゾーン',
  '西ゲートゾーン',
  'フューチャーライフゾーン',
  'リング上',
];

const Map<String, ({double x, double z, double? y})> kSpotCoordinates = {
  '東ゲート': (x: 580.0, z: 123.4, y: null),
  '西ゲート': (x: -572.3, z: 342.9, y: null),
  'コネクティングゾーン': (x: -82.4, z: 300.0, y: null),
  'エンパワーリングゾーン': (x: 253.9, z: 22.4, y: null),
  'セービングゾーン': (x: -296.3, z: 73.8, y: null),
  'シグネチャーゾーン': (x: -0.2, z: -97.9, y: null),
  '静けさの森ゾーン': (x: 6.6, z: 105.2, y: null),
  '東ゲートゾーン': (x: 326.2, z: -71.8, y: null),
  '西ゲートゾーン': (x: -312.8, z: 224.8, y: null),
  'フューチャーライフゾーン': (x: -690.8, z: 544.5, y: null),
  'リング上': (x: 285.8, z: 85.6, y: 28.5),
};

@freezed
abstract class ExplorationState with _$ExplorationState {
  const factory ExplorationState({
    required SceneAsset asset,
    @Default(ExplorationMode.free) ExplorationMode mode,
    String? spot,
    @Default(ExplorationPanel.none) ExplorationPanel panel,
    @Default(false) bool showResult,
    @Default(true) bool isLoading,
    @Default(false) bool loadFailed,
    double? importSeconds,
    @Default(0) double fps,
    @Default(0) double frameMs,
    Position? playerPosition,
    @Default(0) double cameraForwardX,
    @Default(0) double cameraForwardZ,
    @Default(false) bool onRing,
    PlaySession? session,
    SubmitShotResponse? result,
    @Default(false) bool sessionExpired,
    PlayFailureKind? shotFailure,
    @Default([]) List<MapPinData> mapPins,
    ChallengeRevision? revision,
    @Default(true) bool showShotFrame,
  }) = _ExplorationState;
}

@riverpod
class ExplorationViewModel extends _$ExplorationViewModel {
  @override
  ExplorationState build() {
    final adapter = ref.watch(sceneAdapterProvider.notifier);
    ref.watch(playControllerProvider.notifier);
    final mapPins = ref.read(mapPinsProvider);
    final challengeState = ref.read(challengeProvider);
    // 表示データの更新で、セッション・ロード完了・撮影待ちを初期化しない。
    ref.listen(mapPinsProvider, (_, next) {
      state = state.copyWith(mapPins: next);
    });
    ref.listen(challengeProvider, (_, next) {
      state = state.copyWith(revision: next.revision);
    });
    ref.listen(authProvider, (previous, next) {
      if (previous?.authUserId != next.authUserId) {
        ref.read(guidePanelViewModelProvider.notifier).close();
      }
    });
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    ref.onDispose(() {
      WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    });
    _buildAdapter = adapter;
    _buildPlayController = ref.read(playControllerProvider.notifier);
    _loadCollisionGrid();
    if (challengeState.revision == null) {
      // listen先の同期通知が初期stateの確定より先に走らないようにする。
      unawaited(
        Future<void>.microtask(() {
          if (ref.mounted) {
            ref.read(challengeProvider.notifier).loadCurrent().ignore();
          }
        }),
      );
    }
    return ExplorationState(
      asset: ref.read(assetStoreProvider).resolve(),
      mapPins: mapPins,
      revision: challengeState.revision,
    );
  }

  late final SceneAdapter _buildAdapter;
  late final PlayController _buildPlayController;
  CollisionResolver? _collisionResolver;
  final Completer<void> _collisionGridLoaded = Completer<void>();

  SceneAdapter get _adapter => _buildAdapter;

  Scene get scene => _adapter.scene;
  ResourceGroup get loading => _adapter.loading;

  PlayController get _playController => _buildPlayController;

  Future<void> _loadCollisionGrid() async {
    try {
      final data = await rootBundle.load('assets/collision.bin');
      final grid = CollisionGrid.fromBytes(data.buffer.asUint8List());
      _collisionResolver = CollisionResolver(grid: grid);
      _collisionGridLoaded.complete();
    } catch (error, stackTrace) {
      _collisionGridLoaded.completeError(error, stackTrace);
      rethrow;
    }
  }

  String get modeLabel {
    final base = switch (state.mode) {
      .free => '自由探索',
      .near => 'ゴール周辺探索',
    };
    final spot = state.spot;
    return spot == null ? base : '$base ・ $spot';
  }

  void toggleShotFrame() {
    state = state.copyWith(showShotFrame: !state.showShotFrame);
  }

  void openPanel(ExplorationPanel panel) {
    if (state.isLoading || state.panel == panel) {
      return;
    }
    // 撮影の送信中・結果不明の間は、結果確認を優先しパネルを開かない。
    if (state.panel == ExplorationPanel.submitting ||
        state.panel == ExplorationPanel.submitPending) {
      return;
    }
    if (state.panel == ExplorationPanel.guide) {
      ref.read(guidePanelViewModelProvider.notifier).close();
    }
    if (panel == ExplorationPanel.guide) {
      resetJoystickPan();
      ref.read(guidePanelViewModelProvider.notifier).generate();
    }
    state = state.copyWith(panel: panel);
  }

  void closePanel() {
    if (state.panel == ExplorationPanel.guide) {
      ref.read(guidePanelViewModelProvider.notifier).close();
    }
    state = state.copyWith(panel: ExplorationPanel.none);
  }

  void teleportTo(String spotName) {
    final coords = kSpotCoordinates[spotName];
    if (coords != null) {
      final onRing = spotName == 'リング上';
      var yaw = math.atan2(-coords.x, -coords.z);
      if (spotName == '西ゲート') {
        yaw += math.pi / 2;
      }
      if (spotName == '東ゲートゾーン') {
        // 日本館前のため、リング中心とは反対の日本館側を向く。
        yaw += math.pi;
      }
      _placePlayer(x: coords.x, z: coords.z, y: coords.y, yaw: yaw);
      state = state.copyWith(spot: spotName, onRing: onRing);
    } else {
      state = state.copyWith(spot: spotName, onRing: false);
    }
    closePanel();
  }

  /// 撮影失敗の表示文言。失敗がない場合は null。
  String? get shotMessage => switch (state.shotFailure) {
    .invalidCamera => '撮影位置が範囲外のため送信できませんでした。場所や向きを変えてお試しください。',
    .requestIdReused => '撮影情報に不整合がありました。探索を開始し直してください。',
    .rateLimited => '撮影が集中しています。少し待ってからお試しください。',
    .maintenance => 'メンテナンス中です。しばらくしてからお試しください。',
    .authentication => '認証を確認できません。探索を開始し直してください。',
    .notFound || .notOwner => 'プレイが見つかりませんでした。探索を開始し直してください。',
    .poseNotReady => '現在位置がまだ確定していないため撮影できません。少し待ってからお試しください。',
    null => null,
    _ => '撮影を送信できませんでした。',
  };

  Future<void> submitShot() async {
    if (state.isLoading ||
        state.showResult ||
        state.panel == ExplorationPanel.submitting ||
        state.panel == ExplorationPanel.submitPending) {
      return;
    }
    if (state.session == null) {
      log('セッション未接続のため撮影できません');
      state = state.copyWith(shotFailure: .notFound);
      return;
    }
    final ShotInput shot;
    try {
      // シャッターの瞬間に姿勢を一度だけ固定する。
      shot = _playController.fixShotInput();
    } on StateError catch (error, stackTrace) {
      log('撮影姿勢を固定できませんでした', error: error, stackTrace: stackTrace);
      state = state.copyWith(shotFailure: .poseNotReady);
      return;
    }
    state = state.copyWith(
      panel: ExplorationPanel.submitting,
      shotFailure: null,
    );
    await _awaitShot(
      () => ref.read(playProvider.notifier).submitShot(shot),
      _shotGeneration,
    );
  }

  /// 結果不明の撮影を、固定した姿勢とrequestIdのまま再送する。
  Future<void> resendShot() async {
    if (state.panel != ExplorationPanel.submitPending) {
      return;
    }
    state = state.copyWith(panel: ExplorationPanel.submitting);
    await _awaitShot(
      () => ref.read(playProvider.notifier).resendShot(),
      _shotGeneration,
    );
  }

  /// 結果不明の撮影の保存済み結果を照会する。
  Future<void> checkShotResult() async {
    if (state.panel != ExplorationPanel.submitPending) {
      return;
    }
    state = state.copyWith(panel: ExplorationPanel.submitting);
    await _awaitShot(
      () => ref.read(playProvider.notifier).checkShotResult(),
      _shotGeneration,
    );
  }

  /// 撮影の試行世代。プレイを切り替えたら進め、旧試行の遅い応答を捨てる。
  int _shotGeneration = 0;

  Future<void> _awaitShot(
    Future<SubmitShotResponse?> Function() action,
    int generation,
  ) async {
    try {
      final result = await action();
      if (!ref.mounted || generation != _shotGeneration) {
        return;
      }
      if (result != null) {
        // 正式な点数は結果DTOから表示し、ローカル採点へ置き換えない。
        final session = ref.read(playProvider).session;
        if (session == null) throw const PlayFailure(.rejected);
        state = state.copyWith(
          panel: ExplorationPanel.none,
          result: result,
          session: session,
          mode: _explorationModeOf(session.mode),
          showResult: true,
        );
        return;
      }
      // 結果不明・期限切れはプレイProviderの状態から反映する。
      if (ref.read(playProvider).phase == .sessionExpired) {
        state = state.copyWith(
          panel: ExplorationPanel.none,
          sessionExpired: true,
        );
      } else {
        state = state.copyWith(panel: ExplorationPanel.submitPending);
      }
    } on PlayFailure catch (failure) {
      if (!ref.mounted || generation != _shotGeneration) {
        return;
      }
      if (failure.kind == .sessionExpired) {
        state = state.copyWith(
          panel: ExplorationPanel.none,
          sessionExpired: true,
        );
        return;
      }
      // 入力拒否が確定して探索へ戻る場合など、理由だけを表示する。
      state = state.copyWith(
        panel: ref.read(playProvider).pendingShot == null
            ? ExplorationPanel.none
            : ExplorationPanel.submitPending,
        shotFailure: failure.kind,
      );
    } catch (error, stackTrace) {
      log('撮影の送信に失敗しました', error: error, stackTrace: stackTrace);
      if (!ref.mounted || generation != _shotGeneration) {
        return;
      }
      state = state.copyWith(
        panel: ref.read(playProvider).pendingShot == null
            ? ExplorationPanel.none
            : ExplorationPanel.submitPending,
        shotFailure: .rejected,
      );
    }
  }

  void acknowledgeSessionExpired() {
    state = state.copyWith(sessionExpired: false);
    endPlay();
  }

  void startPlay({required ExplorationMode mode, String? spot}) {
    _resetLocal();
    // 接続済みセッションがあれば、その開始点と結果を引き継ぐ。
    // 照会できなかった保留中の撮影は、セッションなしでも確認を引き継ぐ。
    final play = ref.read(playProvider);
    final session = play.session;
    final adoptsPending =
        play.pendingShot != null && play.phase == .submitUnknown;
    if (session != null || adoptsPending) {
      state = state.copyWith(
        mode: session == null ? mode : _explorationModeOf(session.mode),
        spot: spot,
        session: session,
        result: play.phase == .completed ? play.result : null,
        panel: play.phase == .submitUnknown
            ? ExplorationPanel.submitPending
            : ExplorationPanel.none,
        sessionExpired: play.phase == .sessionExpired,
        showResult:
            !state.isLoading && play.phase == .completed && play.result != null,
      );
      if (session != null) _applySpawn(session);
      return;
    }
    state = state.copyWith(mode: mode, spot: spot);
  }

  ExplorationMode _explorationModeOf(PlayMode playMode) {
    return switch (playMode) {
      .near => ExplorationMode.near,
      .free => ExplorationMode.free,
      .unknown => throw const PlayFailure(.rejected),
    };
  }

  Future<void> retryPlay() async {
    if (!state.showResult) return;
    final revisionId = state.session?.revisionId;
    if (revisionId == null) {
      state = state.copyWith(showResult: false, shotFailure: .rejected);
      return;
    }
    final generation = ++_shotGeneration;
    ref.read(guidePanelViewModelProvider.notifier).close();
    state = state.copyWith(
      showResult: false,
      shotFailure: null,
      panel: ExplorationPanel.submitting,
    );
    try {
      // 再挑戦は新しいrequestIdで別セッションを開始する。
      final session = await ref
          .read(playProvider.notifier)
          .createSession(
            revisionId: revisionId,
            mode: switch (state.mode) {
              .free => PlayMode.free,
              .near => PlayMode.near,
            },
            spawnPointId: _retrySpawnPointId(),
          );
      if (!ref.mounted) {
        return;
      }
      if (generation != _shotGeneration) return;
      state = state.copyWith(
        session: session,
        result: null,
        panel: ExplorationPanel.none,
      );
      _applySpawn(session);
    } on PlayFailure catch (failure) {
      if (!ref.mounted) {
        return;
      }
      if (generation != _shotGeneration) return;
      state = state.copyWith(
        shotFailure: failure.kind,
        panel: ExplorationPanel.none,
        showResult: true,
      );
    }
  }

  /// 自由探索の再挑戦は、同じ入口 ID を新しい requestId で送る。
  int? _retrySpawnPointId() {
    if (state.mode != .free) return null;
    return state.session?.spawnPointId;
  }

  void dismissResult() {
    state = state.copyWith(showResult: false);
  }

  void endPlay() {
    _resetLocal();
    ref.read(playProvider.notifier).clearSession();
  }

  void _resetLocal() {
    _shotGeneration++;
    ref.read(guidePanelViewModelProvider.notifier).close();
    closePanel();
    resetJoystickPan();
    state = state.copyWith(
      showResult: false,
      session: null,
      result: null,
      sessionExpired: false,
      shotFailure: null,
    );
  }

  /// セッションの開始点をプレイヤーへ適用する。開始点はサーバー決定が正本。
  void _applySpawn(PlaySession session) {
    final spawn = session.spawn;
    _placePlayer(
      x: spawn.positionX,
      z: spawn.positionZ,
      y: _eyeY(session),
      yaw: spawn.yawDegrees * math.pi / 180,
    );
    state = state.copyWith(onRing: false, spot: null);
  }

  /// 足元と向きを描画と撮影姿勢の両方へ入れる。移動の tick を待たない。
  void _placePlayer({
    required double x,
    required double z,
    double? y,
    required double yaw,
  }) {
    _buildAdapter.setStartPosition(x, z, y: y);
    _playController.applyPosition(Position(x: x, y: z));
    _playController.applyStartDirection(yaw);
    _applyCameraRotation();
  }

  double _eyeY(PlaySession session) {
    final eyeHeight =
        ref.read(challengeProvider).revision?.eyeHeightMeters ??
        kPlayerEyeHeight - kGroundTopY;
    return session.spawn.positionY + eyeHeight;
  }

  void handleSystemBack() {
    // 撮影の送信中・結果不明の間は、戻る操作で送信を取り消さない。
    if (state.panel == ExplorationPanel.submitting ||
        state.panel == ExplorationPanel.submitPending) {
      return;
    }
    if (state.panel == ExplorationPanel.none) {
      openPanel(ExplorationPanel.exitConfirm);
    } else {
      closePanel();
    }
  }

  void loadModel() {
    if (!state.isLoading) {
      return;
    }
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _collisionGridLoaded.future;
    final adapter = _buildAdapter;
    final session = state.session;
    var onRing = false;
    if (session != null) {
      // 開始点はセッションのスポーンを使う。再送・再試行で引き直さない。
      final spawn = session.spawn;
      _placePlayer(
        x: spawn.positionX,
        z: spawn.positionZ,
        y: _eyeY(session),
        yaw: spawn.yawDegrees * math.pi / 180,
      );
    } else {
      final spot = state.spot;
      final coords = kSpotCoordinates[spot];
      final startX = coords?.x ?? kStartPositionX;
      final startZ = coords?.z ?? kStartPositionZ;
      final startY = coords?.y;
      onRing = spot == 'リング上';
      var yaw = math.atan2(-startX, -startZ);
      if (spot == '西ゲート') {
        yaw += math.pi / 2;
      }
      if (spot == '東ゲートゾーン') {
        // 日本館前のため、リング中心とは反対の日本館側を向く。
        yaw += math.pi;
      }
      _placePlayer(x: startX, z: startZ, y: startY, yaw: yaw);
    }
    try {
      final importSeconds = await adapter.loadModel();
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        importSeconds: importSeconds,
        onRing: onRing,
        // 復旧済みの保存結果があれば、読み込み完了後に結果を表示する。
        showResult: state.result != null,
      );
    } catch (error, stackTrace) {
      log('3Dモデルの読み込みに失敗しました', error: error, stackTrace: stackTrace);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(isLoading: false, loadFailed: true);
    }
  }

  /// プレイ中のセッションの版・モードの歩行領域。セッションがない、または表示中の版と
  /// セッションの版が違う間は null（歩行領域では制限しない）。
  WalkableArea? get _walkable {
    final session = state.session;
    final revision = state.revision;
    if (session == null || revision == null) return null;
    if (revision.id != session.revisionId) return null;
    return revision.modes
        .where((config) => config.mode == session.mode)
        .firstOrNull
        ?.walkable;
  }

  void onTick(Duration elapsed, double deltaSeconds) {
    final adapter = _buildAdapter;
    final camera = adapter.camera;
    final translation = adapter.player.localTransform.getTranslation();
    final next = state.panel == ExplorationPanel.none
        ? _playController.computeMove(
            current: Position(x: translation.x, y: translation.z),
            cameraForward: camera.forward,
            cameraUp: camera.up,
            deltaSeconds: deltaSeconds,
          )
        : null;
    if (next != null) {
      final resolver = _collisionResolver;
      if (resolver != null) {
        final resolved = resolver.resolve(
          currentX: translation.x,
          currentZ: translation.z,
          currentY: translation.y,
          nextX: next.x,
          nextZ: next.y,
          onRing: state.onRing,
        );
        // 衝突グリッドに加え、プレイ中の版・モードの歩行領域でも制限する（#221）。
        // サーバーは撮影・ガイドの位置を同じ歩行領域で検査する。
        final walkable = _walkable;
        final position = walkable == null
            ? PointXZ(x: resolved.x, z: resolved.z)
            : moveWithinWalkable(
                walkable,
                PointXZ(x: translation.x, z: translation.z),
                PointXZ(x: resolved.x, z: resolved.z),
              );
        adapter.setPlayerPosition(position.x, resolved.y, position.z);
      }
    }
    _applyCameraRotation();
    adapter.player.markTransformDirty();
  }

  void _applyCameraRotation() {
    _buildAdapter.setPlayerRotation(_playController.buildPlayerRotation());
  }

  Offset updateJoystickPan(
    Offset localPosition, {
    required double size,
    required double maxDistance,
  }) {
    return _playController.applyPan(
      localPosition,
      size: size,
      maxDistance: maxDistance,
    );
  }

  void resetJoystickPan() {
    _playController.resetJoystick();
  }

  void rotateCamera(Offset delta) {
    _playController.rotateCamera(delta);
    _applyCameraRotation();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    _frameCountInWindow += timings.length;
    for (final timing in timings) {
      _frameMicroTotal += timing.totalSpan.inMicroseconds;
    }
    final now = DateTime.now();
    final start = _windowStart;
    if (start == null) {
      _windowStart = now;
      return;
    }
    final seconds = now.difference(start).inMicroseconds / 1e6;
    if (seconds < 1 || _frameCountInWindow == 0) {
      return;
    }
    final count = _frameCountInWindow;
    final frameMs = _frameMicroTotal / count / 1000;
    _frameCountInWindow = 0;
    _frameMicroTotal = 0;
    _windowStart = now;
    if (!ref.mounted) {
      return;
    }
    final translation = _buildAdapter.player.localTransform.getTranslation();
    final cameraForward = _buildAdapter.camera.forward;
    state = state.copyWith(
      fps: count / seconds,
      frameMs: frameMs,
      playerPosition: Position(x: translation.x, y: translation.z),
      cameraForwardX: cameraForward.x,
      cameraForwardZ: cameraForward.z,
    );
  }

  int _frameCountInWindow = 0;
  double _frameMicroTotal = 0;
  DateTime? _windowStart;
}

/// 解説の表示判断。通信・ネイティブ音声は機能別Providerに委譲する。
@riverpod
class GuidePanelViewModel extends _$GuidePanelViewModel {
  @override
  GuideState build() {
    final lifecycle = AppLifecycleListener(
      onStateChange: (value) {
        if (value != AppLifecycleState.resumed) close();
      },
    );
    ref.onDispose(lifecycle.dispose);
    ref.listen(guideProvider, (_, next) {
      state = next;
    });
    return ref.read(guideProvider);
  }

  void generate() {
    try {
      final request = ref.read(guideRequestSnapshotProvider)();
      unawaited(ref.read(guideProvider.notifier).generate(request));
    } catch (error, stackTrace) {
      log(
        'ガイドのプレイ情報を取得できません',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      ref.read(guideProvider.notifier).unavailable();
    }
  }

  void close() => unawaited(ref.read(guideProvider.notifier).close());

  /// 待ち時間（GUIDE_RATE_LIMITED）の間は再生成を押せない。
  bool get canRegenerate => state.retryAfterSeconds == null;
  void togglePlayback() =>
      unawaited(ref.read(guideProvider.notifier).togglePlayback());

  String get message => switch (state.failure) {
    .notConnected => '解説に必要なプレイ情報に接続できません。探索を開始し直してください。',
    .noTarget => 'この出題には解説できる対象が登録されていません。',
    .outOfArea => 'この場所では解説できません。歩ける範囲の中で、もう一度お試しください。',
    .disabled => '現在、解説を利用できません。しばらくしてからお試しください。',
    .rateLimited => switch (state.retryAfterSeconds) {
      final seconds? => '続けて解説するには少し待つ必要があります。約$seconds秒後にガイドを再生成できます。',
      null => '待ち時間が過ぎました。ガイドを再生成できます。',
    },
    .expired => 'プレイの有効期限が切れました。探索を開始し直してください。',
    .completed => '撮影済みのプレイです。新しい探索で解説をご利用ください。',
    .timeout => '音声の準備が時間内に終わりませんでした。ガイドを再生成できます。',
    .audioUnavailable ||
    .invalidAudio ||
    .playback => '音声を利用できません。本文を読むか、ガイドを再生成してください。',
    .disconnected => '解説の通信が切れました。接続を確認してガイドを再生成してください。',
    null => switch (state.phase) {
      .idle => '解説を中断しました。ガイドを再生成できます。',
      .receiving => state.text == null ? '説明を生成しています…' : '音声を準備しています…',
      .ready || .playing || .unavailable => '',
    },
  };
}
