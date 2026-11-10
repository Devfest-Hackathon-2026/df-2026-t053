import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart'
    show normalizeYaw, normalizeSigned;

import '../exceptions.dart';
import '../models/selected_structure.dart';
import '../models/structure.dart';

/// DB・通信に依存せず、版に固定した資料から説明する構造物を選ぶ（docs/specs.md「構造物の選定」）。
///
/// 第1段は、近く（[maxDistanceMeters] 以内）で向いている方（相対角度 [maxRelativeDegrees] 以内）
/// の構造物を最大3件。第1段が空なら第2段として、距離の上限・角度の制限なしで最寄りの1件を選ぶ。
/// 会場のどこでも解説できるようにするため（#226）。資料ありの構造物が版に1件もなければ
/// [NoGuideTargetException]。
class const NearbyStructureSelector() {
  static const maxDistanceMeters = 30.0;
  static const maxRelativeDegrees = 60.0;
  static const frontDegrees = 15.0;
  static const behindDegrees = 135.0;
  static const directionlessDistanceMeters = 0.5;
  static const maxNearbyCount = 3;

  List<SelectedStructure> select({
    required int revisionId,
    required double positionX,
    required double positionZ,
    required double yawDegrees,
    required Iterable<Structure> structures,
  }) {
    if (!positionX.isFinite || !positionZ.isFinite || !yawDegrees.isFinite) {
      throw const InvalidGuidePoseException();
    }
    final yaw = normalizeYaw(yawDegrees);
    final candidates = <({SelectedStructure selected, double angle})>[];
    for (final structure in structures) {
      if (structure.revisionId != revisionId ||
          structure.facts.trim().isEmpty ||
          structure.fallbackText.trim().isEmpty ||
          structure.sources.isEmpty) {
        continue;
      }
      final dx = structure.posX - positionX;
      final dz = structure.posZ - positionZ;
      final distance = math.sqrt(dx * dx + dz * dz);
      if (!distance.isFinite) continue;
      final directionless = distance < directionlessDistanceMeters;
      // 実行時の座標は +X 東・+Z 北（描画・seed と同じ）。北 0°・東 90° の時計回り（#213）。
      final bearing = normalizeYaw(math.atan2(dx, dz) * 180 / math.pi);
      final relative = directionless ? 0.0 : normalizeSigned(bearing - yaw);
      final StructureDirection direction = directionless
          ? .none
          : relative.abs() <= frontDegrees
          ? .front
          : relative.abs() > behindDegrees
          ? .behind
          : relative < 0
          ? .left
          : .right;
      candidates.add((
        selected: SelectedStructure(
          id: structure.id,
          name: structure.name,
          facts: structure.facts,
          fallbackText: structure.fallbackText,
          sources: structure.sources,
          distanceMeters: distance,
          direction: direction,
        ),
        angle: relative.abs(),
      ));
    }
    if (candidates.isEmpty) throw const NoGuideTargetException();
    candidates.sort((a, b) {
      final distance = a.selected.distanceMeters.compareTo(
        b.selected.distanceMeters,
      );
      if (distance != 0) return distance;
      final angle = a.angle.compareTo(b.angle);
      return angle != 0 ? angle : a.selected.id.compareTo(b.selected.id);
    });
    final nearby = candidates.where(
      (c) =>
          c.selected.distanceMeters <= maxDistanceMeters &&
          c.angle <= maxRelativeDegrees,
    );
    final chosen = nearby.isNotEmpty
        ? nearby.take(maxNearbyCount)
        : candidates.take(1);
    return List.unmodifiable(chosen.map((c) => c.selected));
  }
}
