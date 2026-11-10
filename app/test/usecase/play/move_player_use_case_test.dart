import 'dart:math' as math;

import 'package:app/model/position.dart';
import 'package:app/usecase/play/move_player_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;

// 移動量はVector3（float32）で計算するため、結果はfloat32の丸めを含む。
// 1m前後の値で1ulpは約1.2e-7mなので、複数回の演算の累積を見込んで1e-6m
// （1マイクロメートル）とする。歩行の仕様上、これより小さい差は意味を持たない。
// 期待値は歩行速度の定数から求め、速度の調整でテストが壊れないようにする。
const _float32Tolerance = 1e-6;

void main() {
  Position move(vm.Vector2 input, double elapsed) => MovePlayerUseCase().call(
    current: const Position(x: 0, y: 0),
    input: input,
    cameraForward: vm.Vector3(0, 0, -1),
    cameraUp: vm.Vector3(0, 1, 0),
    deltaTime: elapsed,
  );

  test('half tilt walks at half speed', () {
    expect(
      move(vm.Vector2(0, 0.5), 0.04).y,
      closeTo(-0.5 * kDefaultWalkSpeed * 0.04, _float32Tolerance),
    );
  });

  test('diagonal input does not exceed walking speed', () {
    final position = move(vm.Vector2(1, 1), 0.04);
    final distance = math.sqrt(
      position.x * position.x + position.y * position.y,
    );
    expect(distance, closeTo(kDefaultWalkSpeed * 0.04, _float32Tolerance));
  });

  test('a long frame moves at most 50 ms worth', () {
    expect(
      move(vm.Vector2(0, 1), 2).y,
      closeTo(-kDefaultWalkSpeed * 0.05, _float32Tolerance),
    );
  });
}
