import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart'
    show normalizeYaw, yawDiff;

import '../exceptions.dart';

/// 採点に使う内部の値。公開DTO・DB・モデル素材の型には依存しない。
/// Yと画角は採点式の対象外なので受け取らない。
class const ScoringPose({
  required final double positionX,
  required final double positionZ,
  required final double yawDegrees,
  required final double pitchDegrees,
});

class const ShotScore({
  required final int score,
  required final double distanceMeters,
  required final double yawDiffDegrees,
  required final double pitchDiffDegrees,
});

/// docs/specs.md「撮影・採点・再送」の採点式。
/// 認可・操作範囲・再送・保存は呼出し側で扱い、ここでは計算だけを行う。
class const ShotScorer() {
  static const v1 = 'v1';

  ShotScore score({
    required String scoringVersion,
    required ScoringPose camera,
    required ScoringPose goal,
  }) {
    if (scoringVersion != v1) {
      throw UnsupportedScoringVersionException(scoringVersion);
    }
    _validate(camera, 'camera');
    _validate(goal, 'goal');

    final distance = _distance(
      camera.positionX - goal.positionX,
      camera.positionZ - goal.positionZ,
    );
    final yaw = yawDiff(
      normalizeYaw(camera.yawDegrees),
      normalizeYaw(goal.yawDegrees),
    );
    final pitch = (camera.pitchDegrees - goal.pitchDegrees).abs();
    if (!pitch.isFinite) {
      throw const InvalidScoringPoseException('pitchDiffDegrees');
    }

    final positionScore = math.exp(-distance / 10.0);
    final angleScore = math.exp(
      -(yaw * yaw + pitch * pitch) / (2 * 30.0 * 30.0),
    );
    final rounded = (1000 * positionScore * (0.5 + 0.5 * angleScore) + 0.5)
        .floor();
    return ShotScore(
      score: math.min(1000, math.max(0, rounded)),
      distanceMeters: distance,
      yawDiffDegrees: yaw,
      pitchDiffDegrees: pitch,
    );
  }

  void _validate(ScoringPose pose, String prefix) {
    for (final entry in {
      'positionX': pose.positionX,
      'positionZ': pose.positionZ,
      'yawDegrees': pose.yawDegrees,
      'pitchDegrees': pose.pitchDegrees,
    }.entries) {
      if (!entry.value.isFinite) {
        throw InvalidScoringPoseException('$prefix.${entry.key}');
      }
    }
  }

  /// 通常値は仕様式の演算順を守る。二乗のoverflow・underflow時だけ補完する。
  double _distance(double dx, double dz) {
    final direct = math.sqrt(dx * dx + dz * dz);
    if (direct.isFinite && (direct != 0 || (dx == 0 && dz == 0))) {
      return direct;
    }
    final longest = math.max(dx.abs(), dz.abs());
    final shortest = math.min(dx.abs(), dz.abs());
    if (!longest.isFinite) {
      throw const InvalidScoringPoseException('distanceMeters');
    }
    if (longest == 0) return 0;
    final ratio = shortest / longest;
    final distance = longest * math.sqrt(1 + ratio * ratio);
    if (!distance.isFinite) {
      throw const InvalidScoringPoseException('distanceMeters');
    }
    return distance;
  }
}
