import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app/ui/result/view_model.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_scene/scene.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../../support/play.dart';

class _SceneAdapter extends SceneAdapter {
  final cameras = <Camera>[];
  final pending = <Completer<void>>[];
  final currentChecks = <bool Function()>[];
  bool wait = false;
  bool fail = false;
  bool failSecond = false;

  @override
  void build() {}

  final images = <ui.Image>[];

  @override
  Future<ui.Image> captureResultCamera(
    Camera camera, {
    required int width,
    required int height,
    required bool Function() isCurrent,
  }) async {
    await prepareResultCamera(camera, isCurrent: isCurrent);
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xFF4488AA), .src);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width, height);
    picture.dispose();
    images.add(image);
    return image;
  }

  @override
  Future<void> prepareResultCamera(
    Camera camera, {
    required bool Function() isCurrent,
  }) async {
    cameras.add(camera);
    currentChecks.add(isCurrent);
    if (fail || (failSecond && cameras.length == 2)) {
      throw StateError('/private/internal-scene-path');
    }
    if (wait) {
      final completer = Completer<void>();
      pending.add(completer);
      await completer.future;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('絶対XYZ・北0度東90度・上向きpitch・垂直FOVを描画へ変換する', () {
    final pose = fakeShot().camera.copyWith(
      positionY: 27,
      yawDegrees: 0,
      pitchDegrees: 30,
      verticalFovDegrees: 42,
    );
    final north = resultCamera(pose);
    expect(north.position.y, 27);
    expect(north.position.x, pose.positionX);
    expect(north.position.z, pose.positionZ);
    expect(north.forward.x, closeTo(0, 1e-6));
    expect(north.forward.y, closeTo(0.5, 1e-6));
    expect(north.forward.z, closeTo(math.sqrt(3) / 2, 1e-6));
    expect(north.fovRadiansY, closeTo(42 * math.pi / 180, 1e-9));
    final east = resultCamera(pose.copyWith(yawDegrees: 90, pitchDegrees: 0));
    expect(east.forward.x, closeTo(1, 1e-6));
    expect(east.forward.z, closeTo(0, 1e-6));
  });

  test('yaw の向きは探索の描画と同じ（実行時は +Z が北）', () {
    // 探索は PlayController の回転を、前方 +Z のカメラ（NodeCamera）に掛けて描く。
    // 探索の回転は float32（vector_math）で計算するので、誤差は 1e-4 まで許す。
    final controllers = ProviderContainer();
    addTearDown(controllers.dispose);
    final play = controllers.read(playControllerProvider.notifier);
    for (final yaw in [0.0, 30.0, 90.0, 180.0, 270.0, 359.8]) {
      play.applyStartDirection(yaw * math.pi / 180);
      final explored = play.buildPlayerRotation().transformed(
        vm.Vector3(0, 0, 1),
      );
      final camera = resultCamera(
        fakeShot().camera.copyWith(yawDegrees: yaw, pitchDegrees: 0),
      );
      expect(camera.forward.x, closeTo(explored.x, 1e-4), reason: 'yaw=$yaw');
      expect(camera.forward.y, closeTo(explored.y, 1e-4), reason: 'yaw=$yaw');
      expect(camera.forward.z, closeTo(explored.z, 1e-4), reason: 'yaw=$yaw');
    }
  });

  late ProviderContainer container;
  late _SceneAdapter adapter;
  setUp(() {
    adapter = _SceneAdapter();
    container = ProviderContainer(
      overrides: [sceneAdapterProvider.overrideWith(() => adapter)],
    );
  });
  tearDown(() => container.dispose());

  test('保存するyaw・pitchから復元した視線は探索カメラと一致する', () {
    final controller = container.read(playControllerProvider.notifier);
    for (final drag in [
      const Offset(40, -50),
      const Offset(-100, 90),
      const Offset(500, -100),
      const Offset(-20, 10),
    ]) {
      controller.rotateCamera(drag);
      final expected = controller.buildPlayerRotation() * vm.Vector3(0, 0, 1);
      final actual = resultCamera(
        fakeShot().camera.copyWith(
          yawDegrees: controller.yawDegrees,
          pitchDegrees: controller.pitchDegrees,
        ),
      ).forward;
      // Vector3のfloat32座標でtarget-positionを計算する際の丸め誤差を許容する。
      expect(actual.x, closeTo(expected.x, 2e-5));
      expect(actual.y, closeTo(expected.y, 2e-5));
      expect(actual.z, closeTo(expected.z, 2e-5));
    }
  });

  test('両視点を順番に画像化しmutable DTOの変更を受けず、破棄時に画像を解放する', () async {
    final response = resultResponse();
    final goalX = response.reveal.goalCamera.positionX;
    adapter.wait = true;
    final provider = resultComparisonViewModelProvider(response, 4, 3);
    final subscription = container.listen(provider, (_, _) {});
    final future = container.read(provider.future);
    response.reveal.goalCamera.positionX = -999;
    expect(adapter.cameras, hasLength(1));
    adapter.wait = false;
    adapter.pending.single.complete();
    final images = await future;
    expect(adapter.cameras, hasLength(2));
    expect(adapter.cameras.last.position.x, goalX);
    expect(adapter.cameras.first.position.y, 11);
    expect(images.shot, same(adapter.images.first));
    expect(images.goal, same(adapter.images.last));
    expect(images.shot.debugDisposed, isFalse);
    subscription.close();
    await container.pump();
    expect(adapter.images.every((image) => image.debugDisposed), isTrue);
  });

  test('準備失敗を画面状態へ返す', () async {
    final provider = resultComparisonViewModelProvider(resultResponse(), 4, 3);
    adapter.fail = true;
    container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsStateError);
    expect(container.read(provider).hasError, isTrue);
  });

  test('2枚目の準備失敗時も作成済みの1枚目を解放する', () async {
    adapter.failSecond = true;
    final provider = resultComparisonViewModelProvider(resultResponse(), 4, 3);
    container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsStateError);
    expect(adapter.images.single.debugDisposed, isTrue);
  });

  test('破棄後に完了した画像は解放して次の視点を読み込まない', () async {
    adapter.wait = true;
    final provider = resultComparisonViewModelProvider(resultResponse(), 4, 3);
    final subscription = container.listen(provider, (_, _) {});
    // 破棄後の画像の寿命と区画要求を検査する。
    subscription.close();
    await container.pump();
    expect(adapter.currentChecks.single(), isFalse);
    adapter.pending.single.complete();
    await Future<void>.delayed(Duration.zero);
    expect(adapter.images.single.debugDisposed, isTrue);
    expect(adapter.cameras, hasLength(1));
  });
}

SubmitShotResponse resultResponse() => SubmitShotResponse(
  shot: fakeShot(),
  reveal: fakeReveal(),
  myRankingEntry: fakeRankingEntry(),
);
