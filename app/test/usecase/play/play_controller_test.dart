import 'dart:math' as math;

import 'package:app/model/position.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 送る姿勢（yaw・pitch）が、描画の向きと仕様（yaw は北 0°・東 90°、pitch は上向きが正）に
/// 一致することを確かめる（#200）。
void main() {
  late ProviderContainer container;
  late PlayController play;

  setUp(() {
    container = ProviderContainer();
    play = container.read(playControllerProvider.notifier);
  });
  tearDown(() => container.dispose());

  /// 描画の前方。探索は回転を、前方 +Z のカメラに掛けて描く。
  vm.Vector3 renderedForward() =>
      play.buildPlayerRotation().transformed(vm.Vector3(0, 0, 1));

  double degrees(double radians) => radians * 180 / math.pi;

  test('上を向くと pitch は正、下を向くと負', () {
    play
      ..applyStartDirection(0)
      ..rotateCamera(const Offset(0, -60)); // 上へドラッグ
    expect(renderedForward().y, greaterThan(0));
    expect(play.pitchDegrees, greaterThan(0));

    play
      ..applyStartDirection(0)
      ..rotateCamera(const Offset(0, 60)); // 下へドラッグ
    expect(renderedForward().y, lessThan(0));
    expect(play.pitchDegrees, lessThan(0));
  });

  for (final (dx, dy) in [
    (0.0, -60.0),
    (0.0, 60.0),
    (120.0, -30.0),
    (-90.0, 45.0),
  ]) {
    test('送る yaw・pitch は描画の向きと一致する（ドラッグ $dx, $dy）', () {
      play
        ..applyStartDirection(30 * math.pi / 180)
        ..rotateCamera(Offset(dx, dy));
      final forward = renderedForward();
      // 描画の float32 の誤差を許す。
      expect(play.pitchDegrees, closeTo(degrees(math.asin(forward.y)), 1e-3));
      final yaw = (degrees(math.atan2(forward.x, forward.z)) % 360 + 360) % 360;
      expect(play.yawDegrees, closeTo(yaw, 1e-3));
    });
  }

  test('撮影の確定値にも、上向きが正の pitch が入る', () {
    play
      ..applyStartDirection(0)
      ..rotateCamera(const Offset(0, -60)); // 上へドラッグ
    // 入力がなければ移動せず、現在位置だけを確定する。
    play.computeMove(
      current: const Position(x: 1, y: 2),
      cameraForward: renderedForward(),
      cameraUp: vm.Vector3(0, 1, 0),
      deltaSeconds: 0.016,
    );
    final shot = play.fixShotInput();
    expect(shot.pitchDegrees, greaterThan(0));
    expect(shot.pitchDegrees, play.pitchDegrees);
  });
}
