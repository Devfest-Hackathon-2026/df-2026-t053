import 'dart:math' as math;

import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/services/shot_scorer.dart';
import 'package:test/test.dart';

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

const scorer = ShotScorer();

ShotScore score(ScoringPose camera, {ScoringPose? goal}) => scorer.score(
  scoringVersion: ShotScorer.v1,
  camera: camera,
  goal: goal ?? pose(),
);

void main() {
  group('v1の仕様例', () {
    test('丸め境界でも仕様式の距離と得点に一致する', () {
      for (final (camera, goal, expected) in [
        (
          pose(x: 4.7489153389438785, z: -10.878231108505526),
          pose(x: -2.550956192637166, z: -14.460935377601455),
          443,
        ),
        (
          pose(x: 8.50276229128957, z: -15.857010052962531),
          pose(x: -6.602671431969544, z: -15.586298306969969),
          221,
        ),
      ]) {
        final dx = camera.positionX - goal.positionX;
        final dz = camera.positionZ - goal.positionZ;
        final result = score(camera, goal: goal);
        expect(result.distanceMeters, math.sqrt(dx * dx + dz * dz));
        expect(result.score, expected);
      }
    });
    test('完全一致は1000点、誤差は0', () {
      final result = score(pose());
      expect(result.score, 1000);
      expect(result.distanceMeters, 0);
      expect(result.yawDiffDegrees, 0);
      expect(result.pitchDiffDegrees, 0);
    });
    test('同じ位置で真後ろは500点', () {
      expect(score(pose(yaw: 180)).score, 500);
    });
    test('距離2m・角度一致は819点', () {
      expect(score(pose(x: 2)).score, 819);
    });
    test('距離5m・角度一致は607点', () {
      expect(score(pose(x: 5)).score, 607);
    });
    test('XZの両軸で距離を求める', () {
      final result = score(pose(x: -3, z: 4));
      expect(result.distanceMeters, 5);
      expect(result.score, 607);
    });
    test('yaw359°と1°の差は2°', () {
      expect(score(pose(yaw: 359), goal: pose(yaw: 1)).yawDiffDegrees, 2);
    });
    test('pitchの差は循環させない', () {
      expect(
        score(pose(pitch: -65), goal: pose(pitch: 65)).pitchDiffDegrees,
        130,
      );
    });
    test('整数化は四捨五入する', () {
      for (final (raw, expected) in [(512.49, 512), (512.51, 513)]) {
        final distance = -10 * math.log(raw / 1000);
        expect(score(pose(x: distance)).score, expected);
      }
    });
  });

  group('計算の性質', () {
    test('角度が同じなら、距離が増えて得点が上がることはない', () {
      var previous = 1000;
      for (var distance = 0; distance <= 100; distance++) {
        final result = score(pose(x: distance.toDouble()));
        expect(result.score, lessThanOrEqualTo(previous));
        previous = result.score;
      }
    });
    test('位置が同じなら、yaw・pitchの誤差で得点が上がることはない', () {
      for (final yawAxis in [true, false]) {
        var previous = 1000;
        for (var angle = 0; angle <= 180; angle++) {
          final result = score(
            pose(
              yaw: yawAxis ? angle.toDouble() : 0,
              pitch: yawAxis ? 0 : angle.toDouble(),
            ),
          );
          expect(result.score, lessThanOrEqualTo(previous));
          previous = result.score;
        }
      }
    });
    test('同じ平行移動・yawの一周で結果が変わらない', () {
      final original = score(pose(x: 3, z: 4, yaw: 20, pitch: 5));
      final translated = score(
        pose(x: 103, z: -196, yaw: 380, pitch: 5),
        goal: pose(x: 100, z: -200),
      );
      expect(translated.score, original.score);
      expect(translated.distanceMeters, original.distanceMeters);
      expect(translated.yawDiffDegrees, original.yawDiffDegrees);
      expect(translated.pitchDiffDegrees, original.pitchDiffDegrees);
    });
    test('任意の姿勢の入替えで誤差と得点が変わらず、得点は0〜1000', () {
      final random = math.Random(63);
      ScoringPose nextPose() => pose(
        x: random.nextDouble() * 200 - 100,
        z: random.nextDouble() * 200 - 100,
        yaw: random.nextDouble() * 360,
        pitch: random.nextDouble() * 130 - 65,
      );
      for (var i = 0; i < 500; i++) {
        final a = nextPose();
        final b = nextPose();
        final ab = score(a, goal: b);
        final ba = score(b, goal: a);
        expect(ab.score, inInclusiveRange(0, 1000));
        expect(ab.score, ba.score);
        expect(ab.distanceMeters, ba.distanceMeters);
        expect(ab.yawDiffDegrees, closeTo(ba.yawDiffDegrees, 1e-12));
        expect(ab.pitchDiffDegrees, ba.pitchDiffDegrees);
      }
    });
  });

  group('版と数値境界', () {
    test('未知の版をv1として黙って採点しない', () {
      for (final version in ['', 'v0', 'v2']) {
        expect(
          () => scorer.score(
            scoringVersion: version,
            camera: pose(),
            goal: pose(),
          ),
          throwsA(
            isA<UnsupportedScoringVersionException>().having(
              (e) => e.version,
              'version',
              version,
            ),
          ),
        );
      }
    });
    for (final cameraSide in [true, false]) {
      for (final field in [
        'positionX',
        'positionZ',
        'yawDegrees',
        'pitchDegrees',
      ]) {
        test('${cameraSide ? 'camera' : 'goal'}.$fieldの非有限値を拒否する', () {
          for (final invalid in [
            double.nan,
            double.infinity,
            double.negativeInfinity,
          ]) {
            final input = ScoringPose(
              positionX: field == 'positionX' ? invalid : 0,
              positionZ: field == 'positionZ' ? invalid : 0,
              yawDegrees: field == 'yawDegrees' ? invalid : 0,
              pitchDegrees: field == 'pitchDegrees' ? invalid : 0,
            );
            expect(
              () => scorer.score(
                scoringVersion: ShotScorer.v1,
                camera: cameraSide ? input : pose(),
                goal: cameraSide ? pose() : input,
              ),
              throwsA(
                isA<InvalidScoringPoseException>().having(
                  (e) => e.field,
                  'field',
                  '${cameraSide ? 'camera' : 'goal'}.$field',
                ),
              ),
            );
          }
        });
      }
    }
    test('非常に大きい有限座標でも、二乗だけで距離を無限大にしない', () {
      final result = score(pose(x: 1e200), goal: pose(x: -1e200));
      expect(result.distanceMeters, 2e200);
      expect(result.score, 0);
    });
    test('非常に小さい距離を二乗のunderflowで0にしない', () {
      expect(score(pose(x: 1e-200)).distanceMeters, 1e-200);
    });
    test('差分自体がdoubleで表現できない場合は拒否する', () {
      expect(
        () => score(
          pose(x: double.maxFinite),
          goal: pose(x: -double.maxFinite),
        ),
        throwsA(isA<InvalidScoringPoseException>()),
      );
      expect(
        () => score(
          pose(pitch: double.maxFinite),
          goal: pose(pitch: -double.maxFinite),
        ),
        throwsA(isA<InvalidScoringPoseException>()),
      );
    });
    test('負の0は正の0と同じ結果になる', () {
      final result = score(pose(x: -0.0, z: -0.0, yaw: -0.0, pitch: -0.0));
      expect(result.score, 1000);
      expect(result.distanceMeters.isNegative, isFalse);
      expect(result.yawDiffDegrees.isNegative, isFalse);
      expect(result.pitchDiffDegrees.isNegative, isFalse);
    });
  });
}
