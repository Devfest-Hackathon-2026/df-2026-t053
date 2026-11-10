import 'package:app/model/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'move_player_use_case.g.dart';

const double kDefaultWalkSpeed = 6;
const double _maxDeltaSeconds = 0.05;

@riverpod
class MovePlayerUseCase extends _$MovePlayerUseCase {
  @override
  void build() {}

  Position call({
    required Position current,
    required vm.Vector2 input,
    required vm.Vector3 cameraForward,
    required vm.Vector3 cameraUp,
    required double deltaTime,
    double speed = kDefaultWalkSpeed,
  }) {
    if (!deltaTime.isFinite || deltaTime <= 0) {
      return current;
    }

    final forward = cameraForward.clone();
    final right = cameraUp.cross(forward).normalized();

    forward.y = 0;
    right.y = 0;
    forward.normalize();
    right.normalize();

    final movement = right * input.x + forward * input.y;
    if (movement.length2 > 1) {
      movement.normalize();
    }

    final elapsed = deltaTime.clamp(0.0, _maxDeltaSeconds).toDouble();
    final displacement = movement * speed * elapsed;
    return Position(
      x: current.x + displacement.x,
      y: current.y + displacement.z,
    );
  }
}
