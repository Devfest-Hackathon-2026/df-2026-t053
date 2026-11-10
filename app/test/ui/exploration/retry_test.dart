import 'dart:async';
import 'dart:io';
import 'dart:ui' show FrameTiming;

import 'package:app/model/auth/model.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/ui/exploration/components/exploration_result_overlay.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/ui/result/screen.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scene/scene.dart' show CameraComponent, Node;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:vector_math/vector_math.dart' as vec;

import '../../support/api_client.dart';
import '../../support/play.dart';

/// 描画資源の生成とロードだけを省き、プレイ・撮影・再挑戦処理は実装を使う。
class _NoSceneAdapter extends SceneAdapter {
  @override
  void build() {
    // 実装同様、フレーム計測が読む値は同期初期化する。GPU資源は作らない。
    player = Node(name: 'test-player');
    cameraComponent = CameraComponent();
    player.addComponent(cameraComponent);
  }

  @override
  void setStartPosition(double x, double z, {double? y}) {}

  @override
  void setPlayerRotation(vec.Matrix3 rotation) {}
}

class _LoadedExplorationViewModel extends ExplorationViewModel {
  @override
  ExplorationState build() => super.build().copyWith(isLoading: false);
}

class _SignedInAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: .signedIn, authUserId: testAuthUserId);
}

class _LoadedChallengeNotifier extends ChallengeNotifier {
  @override
  ChallengeState build() =>
      ChallengeState(challengeId: 1, revision: fakeRevision());

  void refresh(ChallengeRevision revision) {
    state = state.copyWith(revision: revision);
  }
}

/// 撮影応答を差し替えられるプレイのテストダブル。
class _PlayFake {
  final challenge = _LoadedChallengeNotifier();
  Future<SubmitShotResponse> Function(SubmitShotRequest)? onSubmit;
  int createCalls = 0;
  final requests = <CreatePlaySessionRequest>[];

  Future<PlaySession> create(CreatePlaySessionRequest request) async {
    createCalls++;
    requests.add(request);
    return fakePlaySession(mode: request.mode)
        .copyWith(spawnPointId: request.spawnPointId ?? 1);
  }

  Future<SubmitShotResponse> submit(SubmitShotRequest request) {
    final handler = onSubmit;
    return handler != null
        ? handler(request)
        : Future.value(fakeSubmitShotResponse());
  }
}

void main() {
  Future<(ProviderContainer, _PlayFake)> mount(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tempDir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('exploration_test'),
    );
    if (tempDir == null) throw StateError('テスト用保存先を作れませんでした');
    addTearDown(() => tempDir.delete(recursive: true));
    final fake = _PlayFake();
    final container = ProviderContainer(
      overrides: [
        sceneAdapterProvider.overrideWith(_NoSceneAdapter.new),
        explorationViewModelProvider.overrideWith(
          _LoadedExplorationViewModel.new,
        ),
        apiClientProvider.overrideWithValue(
          TestApiClient(
            getProfile: (_) async => throw StateError('未設定'),
            setNickname: (_) async => throw StateError('未設定'),
            refreshAuthentication: () async {},
            createPlaySession: fake.create,
            submitShot: fake.submit,
            getPlaySession: (_) async => fakePlaySession(),
          ),
        ),
        authProvider.overrideWith(_SignedInAuthNotifier.new),
        challengeProvider.overrideWith(() => fake.challenge),
        playSupportDirectoryProvider.overrideWithValue(() async => tempDir),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationResultOverlay(
              onModeSelect: () {},
              onRanking: () {},
            ),
          ),
        ),
      ),
    );
    return (container, fake);
  }

  /// モード選択と同じく、セッションを作成してから探索を開始する。
  Future<void> beginPlay(
    ProviderContainer container,
    ExplorationMode mode,
  ) async {
    await container
        .read(playProvider.notifier)
        .createSession(
          revisionId: 1,
          mode: switch (mode) {
            .free => PlayMode.free,
            .near => PlayMode.near,
          },
          spawnPointId: mode == .free ? 1 : null,
        );
    final vm = container.read(explorationViewModelProvider.notifier);
    vm.startPlay(mode: mode, spot: '東ゲート');
  }

  testWidgets('セッション採用直後はtickなしでスポーン位置を撮影できる', (tester) async {
    final (container, _) = await mount(tester);
    await tester.runAsync(() => beginPlay(container, .near));
    final controller = container.read(playControllerProvider.notifier);
    final pose = controller.fixShotInput();
    expect(pose.positionX, 100);
    expect(pose.positionZ, 50);
    expect(pose.yawDegrees, closeTo(90, 1e-6));
    await tester.runAsync(
      () => container.read(explorationViewModelProvider.notifier).submitShot(),
    );
    expect(container.read(explorationViewModelProvider).showResult, isTrue);
  });

  testWidgets('出題と地図の更新では進行・読み込み完了・撮影姿勢を失わない', (tester) async {
    final (container, fake) = await mount(tester);
    await tester.runAsync(() => beginPlay(container, .free));
    final vm = container.read(explorationViewModelProvider.notifier);
    vm.openPanel(.map);
    final session = container.read(explorationViewModelProvider).session;
    final updated = fakeRevision().copyWith(photoAlt: '更新済みの説明');
    fake.challenge.refresh(updated);
    await tester.pump();
    final state = container.read(explorationViewModelProvider);
    expect(state.session, same(session));
    expect(state.isLoading, isFalse);
    expect(state.panel, ExplorationPanel.map);
    expect(state.revision, same(updated));
    expect(
      container.read(playControllerProvider.notifier).fixShotInput().positionX,
      100,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('セッション未接続のシャッターに再開始を案内する', (tester) async {
    final (container, _) = await mount(tester);
    final vm = container.read(explorationViewModelProvider.notifier);
    await vm.submitShot();
    expect(vm.shotMessage, contains('探索を開始し直してください'));
  });

  testWidgets('再試行用の描画代替でもフレーム計測が位置とカメラを読める', (tester) async {
    final (container, _) = await mount(tester);
    final timing = FrameTiming(
      vsyncStart: 0,
      buildStart: 0,
      buildFinish: 1000,
      rasterStart: 1000,
      rasterFinish: 2000,
      rasterFinishWallTime: 2000,
    );
    final report = tester.platformDispatcher.onReportTimings;
    if (report == null) throw StateError('フレーム計測が登録されていません');
    // エンジンの実フレームが混ざらないよう、保存したcallbackへfixtureだけを送る。
    tester.platformDispatcher.onReportTimings = null;
    addTearDown(() => tester.platformDispatcher.onReportTimings = report);
    report([timing]);
    // 実装のDateTime.nowによる1秒窓を確実に越す。pumpの仮想時間では進まない。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    report([timing]);
    expect(tester.takeException(), isNull);
    expect(
      container.read(explorationViewModelProvider).playerPosition,
      isNotNull,
    );
    expect(container.read(explorationViewModelProvider).frameMs, 2);

    // 次の集計窓は前のフレームを含めず、新しい所要時間だけを平均する。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    report([
      FrameTiming(
        vsyncStart: 0,
        buildStart: 0,
        buildFinish: 2000,
        rasterStart: 2000,
        rasterFinish: 6000,
        rasterFinishWallTime: 6000,
      ),
    ]);
    expect(container.read(explorationViewModelProvider).frameMs, 6);
  });

  for (final mode in ExplorationMode.values) {
    testWidgets('$mode 撮影→もう一度挑戦→未撮影終了で古い結果を出さない', (tester) async {
      final (container, fake) = await mount(tester);
      await tester.runAsync(() => beginPlay(container, mode));
      final vm = container.read(explorationViewModelProvider.notifier);
      await tester.runAsync(() async {
        await vm.submitShot();
      });
      await tester.pump();
      expect(find.byType(ResultScreen), findsOneWidget);
      // 結果はサーバーの結果DTO（500点）を表示する。
      expect(find.text('500'), findsWidgets);
      await tester.tap(find.text('もう一度挑戦'));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(container.read(explorationViewModelProvider).mode, mode);
      // 再挑戦の開始点は新しいセッションのスポーンで、地点名は持たない。
      expect(container.read(explorationViewModelProvider).spot, isNull);
      expect(fake.createCalls, 2);
      expect(fake.requests, hasLength(2));
      expect(fake.requests[0].requestId, isNot(fake.requests[1].requestId));
      if (mode == .free) {
        expect(fake.requests[0].spawnPointId, 1);
        expect(fake.requests[1].spawnPointId, 1);
      } else {
        expect(fake.requests[0].spawnPointId, isNull);
        expect(fake.requests[1].spawnPointId, isNull);
      }
      expect(find.byType(ResultScreen), findsNothing);
      vm.openPanel(ExplorationPanel.exitConfirm);
      vm.endPlay();
      await tester.pump();
      expect(
        container.read(explorationViewModelProvider).panel,
        ExplorationPanel.none,
      );
      expect(find.byType(ResultScreen), findsNothing);
      // 次のプレイで撮影したときだけ、新しい結果が表示される。
      await tester.runAsync(() => beginPlay(container, mode));
      await tester.runAsync(() async {
        await vm.submitShot();
      });
      await tester.pump();
      expect(find.byType(ResultScreen), findsOneWidget);
    });
  }

  testWidgets('プレイ切替で古い撮影待ち処理を取り消す', (tester) async {
    final (container, fake) = await mount(tester);
    await tester.runAsync(() => beginPlay(container, .free));
    final vm = container.read(explorationViewModelProvider.notifier);
    final completer = Completer<SubmitShotResponse>();
    fake.onSubmit = (_) => completer.future;
    await tester.runAsync(() async {
      unawaited(vm.submitShot());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    expect(
      container.read(explorationViewModelProvider).panel,
      ExplorationPanel.submitting,
    );
    await tester.runAsync(
      () => container.read(playProvider.notifier).discardPending(),
    );
    await tester.runAsync(() => beginPlay(container, .near));
    completer.complete(fakeSubmitShotResponse());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(
      container.read(explorationViewModelProvider).mode,
      ExplorationMode.near,
    );
    expect(container.read(explorationViewModelProvider).showResult, isFalse);
    expect(find.byType(ResultScreen), findsNothing);
  });

  testWidgets('終了後に撮影待ちの結果が遅れて表示されない', (tester) async {
    final (container, fake) = await mount(tester);
    await tester.runAsync(() => beginPlay(container, .free));
    final vm = container.read(explorationViewModelProvider.notifier);
    final completer = Completer<SubmitShotResponse>();
    fake.onSubmit = (_) => completer.future;
    await tester.runAsync(() async {
      unawaited(vm.submitShot());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    vm.endPlay();
    completer.complete(fakeSubmitShotResponse());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(container.read(explorationViewModelProvider).showResult, isFalse);
    expect(find.byType(ResultScreen), findsNothing);
  });

  testWidgets('モード選択へ戻ると前回の結果を破棄する', (tester) async {
    final (container, _) = await mount(tester);
    await tester.runAsync(() => beginPlay(container, .free));
    final vm = container.read(explorationViewModelProvider.notifier);
    await tester.runAsync(() async {
      await vm.submitShot();
    });
    await tester.pump();
    expect(find.byType(ResultScreen), findsOneWidget);
    await tester.tap(find.text('モード選択'));
    await tester.pump();
    expect(find.byType(ResultScreen), findsNothing);
    vm.startPlay(mode: .near);
    vm.endPlay();
    await tester.pump();
    expect(find.byType(ResultScreen), findsNothing);
  });
}
