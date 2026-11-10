import 'package:photohunt_server/src/application/usecase/submit_shot.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/services/shot_scorer.dart';
import 'package:test/test.dart';

void main() {
  ScoringPose pose({
    double x = 0,
    double z = 0,
    double yaw = 0,
    double pitch = 0,
  }) => ScoringPose(
    positionX: x,
    positionZ: z,
    yawDegrees: yaw,
    pitchDegrees: pitch,
  );
  test('負のゼロを4値すべてで正規化する', () {
    final result = validateShotCamera(
      pose(x: -0.0, z: -0.0, yaw: -0.0, pitch: -0.0),
    );
    for (final value in [
      result.positionX,
      result.positionZ,
      result.yawDegrees,
      result.pitchDegrees,
    ]) {
      expect(value, 0);
      expect(value.isNegative, isFalse);
    }
  });
  test('yaw と pitch の境界を許す', () {
    for (final yaw in [0.0, 359.999]) {
      for (final pitch in [-65.0, 65.0]) {
        expect(
          validateShotCamera(pose(yaw: yaw, pitch: pitch)).pitchDegrees,
          pitch,
        );
      }
    }
  });
  test('非有限・操作範囲外は項目名付きで拒否する', () {
    for (final (camera, field) in [
      (pose(x: double.nan), 'camera.positionX'),
      (pose(z: double.infinity), 'camera.positionZ'),
      (pose(yaw: double.negativeInfinity), 'camera.yawDegrees'),
      (pose(pitch: double.nan), 'camera.pitchDegrees'),
      (pose(yaw: 360), 'camera.yawDegrees'),
      (pose(yaw: -0.001), 'camera.yawDegrees'),
      (pose(pitch: 65.0001), 'camera.pitchDegrees'),
      (pose(pitch: -65.0001), 'camera.pitchDegrees'),
    ]) {
      expect(
        () => validateShotCamera(camera),
        throwsA(
          isA<ShotException>()
              .having((e) => e.reason, 'reason', ShotFailure.invalidCamera)
              .having((e) => e.fields, 'fields', [field]),
        ),
      );
    }
  });
}
