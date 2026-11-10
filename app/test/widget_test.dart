import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'package:app/model/position.dart';
import 'package:app/usecase/play/move_player_use_case.dart';

void main() {
  test('ジョイスティックの前入力でカメラ前方に移動する', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final next = container
        .read(movePlayerUseCaseProvider.notifier)
        .call(
          current: const Position(x: 0, y: 0),
          input: vm.Vector2(0, 1),
          cameraForward: vm.Vector3(0, 0, 1),
          cameraUp: vm.Vector3(0, 1, 0),
          deltaTime: 0.02,
        );

    expect(next.x, closeTo(0, 0.0001));
    expect(next.y, closeTo(kDefaultWalkSpeed * 0.02, 0.0001));
  });
}
