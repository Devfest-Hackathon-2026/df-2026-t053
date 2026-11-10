import 'dart:io';

import 'package:app/model/auth/model.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/model/position.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:vector_math/vector_math.dart' as vec;

import '../../support/api_client.dart';
import '../../support/play.dart';

/// 描画と区画読み込みを省き、配置と撮影の接続だけを実装のまま使う。
class _IdleScene extends SceneAdapter {
  @override
  void build() {}

  @override
  void setStartPosition(double x, double z, {double? y}) {}

  @override
  void setPlayerRotation(vec.Matrix3 rotation) {}

  @override
  Future<double> loadModel({Future<({double x, double z})>? startAt}) async =>
      0;
}

class _ReadyWithoutPlacement extends ExplorationViewModel {
  @override
  ExplorationState build() => super.build().copyWith(isLoading: false);
}

class _SignedInAuth extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: .signedIn, authUserId: testAuthUserId);
}

class _LoadedChallenge extends ChallengeNotifier {
  @override
  ChallengeState build() =>
      ChallengeState(challengeId: 1, revision: fakeRevision());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, List<SubmitShotRequest>)> mount({
    required bool loading,
  }) async {
    final directory = await Directory.systemTemp.createTemp('first_shot');
    addTearDown(() => directory.delete(recursive: true));
    final requests = <SubmitShotRequest>[];
    final container = ProviderContainer(
      overrides: [
        sceneAdapterProvider.overrideWith(_IdleScene.new),
        if (!loading)
          explorationViewModelProvider.overrideWith(_ReadyWithoutPlacement.new),
        apiClientProvider.overrideWithValue(
          TestApiClient(
            getProfile: (_) async => throw StateError('未設定'),
            setNickname: (_) async => throw StateError('未設定'),
            refreshAuthentication: () async {},
            createPlaySession: (_) async => fakePlaySession(),
            submitShot: (request) async {
              requests.add(request);
              return fakeSubmitShotResponse();
            },
            getPlaySession: (_) async => fakePlaySession(),
          ),
        ),
        authProvider.overrideWith(_SignedInAuth.new),
        challengeProvider.overrideWith(_LoadedChallenge.new),
        playSupportDirectoryProvider.overrideWithValue(() async => directory),
      ],
    );
    addTearDown(container.dispose);
    container.listen(explorationViewModelProvider, (_, _) {});
    await container
        .read(playProvider.notifier)
        .createSession(revisionId: 1, mode: .free);
    container
        .read(explorationViewModelProvider.notifier)
        .startPlay(mode: .free);
    return (container, requests);
  }

  Future<void> finishLoading(ProviderContainer container) async {
    final vm = container.read(explorationViewModelProvider.notifier);
    vm.loadModel();
    for (var i = 0; i < 100; i++) {
      if (!container.read(explorationViewModelProvider).isLoading) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw StateError('モデル読み込みが終わりませんでした');
  }

  test('読み込み完了直後、tickなしでスポーン位置を撮影できる', () async {
    final (container, requests) = await mount(loading: true);
    await finishLoading(container);
    final vm = container.read(explorationViewModelProvider.notifier);
    expect(container.read(explorationViewModelProvider).isLoading, isFalse);
    await vm.submitShot();
    expect(requests, hasLength(1));
    final camera = requests.single.camera;
    expect(camera.positionX, 100);
    expect(camera.positionZ, 50);
    expect(camera.yawDegrees, closeTo(90, 0.001));
    expect(camera.pitchDegrees, 0);
    expect(vm.shotMessage, isNull);
  });

  test('公開前の原点tickは、配置したスポーン位置で上書きされる', () async {
    final (container, requests) = await mount(loading: true);
    container
        .read(playControllerProvider.notifier)
        .computeMove(
          current: const Position(x: 0, y: 0),
          cameraForward: vec.Vector3(0, 0, -1),
          cameraUp: vec.Vector3(0, 1, 0),
          deltaSeconds: 0.016,
        );
    await finishLoading(container);
    await container.read(explorationViewModelProvider.notifier).submitShot();
    expect(requests, hasLength(1));
    expect(requests.single.camera.positionX, 100);
    expect(requests.single.camera.positionZ, 50);
  });

  test('テレポート直後のtick前でも移動先を撮影する', () async {
    final (container, requests) = await mount(loading: true);
    await finishLoading(container);
    final vm = container.read(explorationViewModelProvider.notifier);
    vm.teleportTo('東ゲート');
    await vm.submitShot();
    expect(requests, hasLength(1));
    expect(requests.single.camera.positionX, 580);
    expect(requests.single.camera.positionZ, 123.4);
  });

  test('再挑戦の開始点もtickなしで撮影できる', () async {
    final (container, requests) = await mount(loading: true);
    await finishLoading(container);
    final vm = container.read(explorationViewModelProvider.notifier);
    await vm.submitShot();
    requests.clear();
    await vm.retryPlay();
    await vm.submitShot();
    expect(requests, hasLength(1));
    expect(requests.single.camera.positionX, 100);
    expect(requests.single.camera.positionZ, 50);
  });

  test('位置が未確定のシャッターは無反応にせず理由を出す', () async {
    final (container, requests) = await mount(loading: false);
    // 採用時には位置が確定するため、この異常系は姿勢の破棄を明示的に再現する。
    container
        .read(playControllerProvider.notifier)
        .beginSession(testPlaySessionId);
    final vm = container.read(explorationViewModelProvider.notifier);
    await vm.submitShot();
    expect(requests, isEmpty);
    expect(vm.shotMessage, '現在位置がまだ確定していないため撮影できません。少し待ってからお試しください。');
  });
}
