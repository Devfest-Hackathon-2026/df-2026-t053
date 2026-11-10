import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:app/model/camera_direction.dart';
import 'package:app/model/position.dart';
import 'package:app/usecase/play/camera_rotate_use_case.dart';
import 'package:app/usecase/play/move_player_use_case.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'play_controller.g.dart';

/// PlayControllerの確定姿勢と接続済みセッションからガイド要求を組み立てる。
@riverpod
ExplainNearbyRequest Function() guideRequestSnapshot(Ref ref) {
  final controller = ref.watch(playControllerProvider.notifier);
  return () => controller.buildExplainNearbyRequest(locale: 'ja-JP');
}

@riverpod
class PlayController extends _$PlayController {
  @override
  void build() {}

  final vm.Vector2 _input = vm.Vector2.zero();
  CameraDirection _direction = const CameraDirection(n: 0, e: 0, w: 0, s: 0);
  UuidValue? _sessionId;
  Position? _lastPosition;

  CameraDirection get direction => _direction;

  /// 接続中のプレイセッション。未接続なら null。
  UuidValue? get sessionId => _sessionId;

  void beginSession(UuidValue sessionId) {
    _lastPosition = null;
    _input.setZero();
    _sessionId = sessionId;
  }

  void endSession() {
    _lastPosition = null;
    _input.setZero();
    _sessionId = null;
  }

  /// 描画と同じ計算で得る現在のヨー角（度、0以上360未満）。
  double get yawDegrees {
    final degrees = (_direction.e - _direction.w) * 180 / math.pi;
    return (degrees % 360 + 360) % 360;
  }

  /// 描画と同じ計算で得る現在のピッチ角（度）。仕様どおり上向きが正（#200）。
  ///
  /// 描画の回転角（[buildPlayerRotation] の X 軸まわり）は正で前方 +Z を下へ傾けるので、
  /// 送る値は符号を反転する。
  double get pitchDegrees {
    final pitch = (_direction.s - _direction.n).clamp(-0.785, 0.785).toDouble();
    return -pitch * 180 / math.pi;
  }

  /// シャッター時点の姿勢を固定する。以後の再送でもこの値を変えない。
  ShotInput fixShotInput() {
    final position = _lastPosition;
    if (position == null) {
      throw StateError('現在位置が未確定です');
    }
    return ShotInput(
      positionX: position.x,
      positionZ: position.y,
      yawDegrees: yawDegrees,
      pitchDegrees: pitchDegrees,
    );
  }

  /// ガイド要求を現在のセッションと確定姿勢から組み立てる。
  ExplainNearbyRequest buildExplainNearbyRequest({required String locale}) {
    final sessionId = _sessionId;
    final position = _lastPosition;
    if (sessionId == null || position == null) {
      throw StateError('プレイのセッションが未接続です');
    }
    return ExplainNearbyRequest(
      playSessionId: sessionId,
      positionX: position.x,
      positionZ: position.y,
      yawDegrees: yawDegrees,
      locale: locale,
    );
  }

  Offset applyPan(
    Offset localPosition, {
    required double size,
    required double maxDistance,
  }) {
    final center = Offset(size / 2, size / 2);
    final offset = localPosition - center;
    if (offset == Offset.zero) {
      _input.setZero();
      return Offset.zero;
    }
    final distance = offset.distance;
    final clamped = distance > maxDistance
        ? offset / distance * maxDistance
        : offset;
    updateJoystick(clamped, maxDistance);
    return clamped;
  }

  void updateJoystick(Offset offset, double maxDistance) {
    if (maxDistance <= 0 || offset == Offset.zero) {
      _input.setZero();
      return;
    }
    _input
      ..x = offset.dx / maxDistance
      ..y = -offset.dy / maxDistance;
  }

  void resetJoystick() {
    _input.setZero();
  }

  void rotateCamera(Offset delta) {
    _direction = ref
        .read(cameraRotateUseCaseProvider.notifier)
        .call(current: _direction, delta: delta);
  }

  /// スポーン時の視点をヨー角 [yaw] へ設定する。
  void applyStartDirection(double yaw) {
    _direction = CameraDirection(n: 0, e: yaw, w: 0, s: 0);
  }

  /// 配置した足元を撮影姿勢へ入れる。移動の tick より前でもシャッターで使える。
  ///
  /// 開始前の tick が原点を記録していても、ここが上書きする。
  void applyPosition(Position position) {
    _lastPosition = position;
  }

  vm.Matrix3 buildPlayerRotation() {
    final yaw = _direction.e - _direction.w;
    final pitch = (_direction.s - _direction.n).clamp(-0.785, 0.785).toDouble();
    final qYaw = vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), yaw);
    final qPitch = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), pitch);
    return (qYaw * qPitch).asRotationMatrix();
  }

  Position? computeMove({
    required Position current,
    required vm.Vector3 cameraForward,
    required vm.Vector3 cameraUp,
    required double deltaSeconds,
    double speed = kDefaultWalkSpeed,
  }) {
    _lastPosition = current;
    if (_input.length2 == 0) {
      return null;
    }
    return ref
        .read(movePlayerUseCaseProvider.notifier)
        .call(
          current: current,
          input: _input,
          cameraForward: cameraForward,
          cameraUp: cameraUp,
          deltaTime: deltaSeconds,
          speed: speed,
        );
  }
}
