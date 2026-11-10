import 'dart:math';

import 'package:app/model/collision_grid.dart';

const double kRingCenterX = -4.2;
const double kRingCenterZ = 0.2;

/// 大屋根リング主通路デッキ（スカイウォーク帯）の半径範囲。
/// 3Dモデル実測に基づき、手すりに挟まれた実際の歩行通路（幅約19m）に設定。
/// 内縁手すり: R ≈ 307.5, 外縁手すり: R ≈ 326.5。
const double kRingInnerRadius = 307.5;
const double kRingOuterRadius = 326.5;
const double kRingDeckBaseRadius = 307.5;
const double kRingDeckOuterRadius = 326.5;
const double kRingDeckBaseY = 21.2;
const double kRingDeckOuterY = 21.6;

/// ウォータープラザ水盤の輪郭（ワールド座標＝登録値）。
/// 会期中の衛星写真（Esri World Imagery）から、乾いた水盤底の輪郭を
/// 登録値グリッドで読み取り、約20m間隔の地点ごとに北端（壁の水際）と
/// 南端（リング側の岸）を記録した表。水面の描画と水域判定はこの表を共用する。
/// 水盤は三日月形で、西端（X −268）は岸際の細い水際から始まり、
/// 幅30mほどの水路状を経て中央の水盤（幅60〜80m）へつながる。
/// 北端は西端 (−268, −136) から東端 (108, −254) へ下る直線状の壁。
/// 西側は水盤底が緑色に写るため、色の抽出では中央部と別々に拾って統合した。
/// 南端は大屋根リングに接する。リング寄りの帯は写真でリングの影になり
/// 水盤底が読み取れないため、南端はリング中心 (−4.2, 0.2) から
/// 半径300m（リング内周）の弧で補った。影の分まで水を奥へ入れないと、
/// 3D空間ではリングとの間に地面の余白が見える。
/// 東端の2地点だけは、水盤が閉じる岸の形に合わせて抽出値のままにした。
const List<({double x, double northZ, double southZ})> kWaterPlazaOutline = [
  (x: -268, northZ: -136, southZ: -143),
  (x: -258, northZ: -140, southZ: -160),
  (x: -246, northZ: -146, southZ: -177),
  (x: -238, northZ: -146, southZ: -188),
  (x: -228, northZ: -148, southZ: -200),
  (x: -220, northZ: -154, southZ: -208),
  (x: -212, northZ: -156, southZ: -216),
  (x: -204, northZ: -159, southZ: -224),
  (x: -196, northZ: -162, southZ: -231),
  (x: -188, northZ: -164, southZ: -237),
  (x: -178, northZ: -167, southZ: -244),
  (x: -168, northZ: -171, southZ: -251),
  (x: -160, northZ: -173, southZ: -256),
  (x: -154, northZ: -175, southZ: -260),
  (x: -140, northZ: -179, southZ: -267),
  (x: -120, northZ: -185, southZ: -277),
  (x: -100, northZ: -191, southZ: -284),
  (x: -80, northZ: -196, southZ: -290),
  (x: -60, northZ: -203, southZ: -295),
  (x: -40, northZ: -210, southZ: -298),
  (x: -20, northZ: -216, southZ: -299),
  (x: 0, northZ: -222, southZ: -300),
  (x: 20, northZ: -228, southZ: -299),
  (x: 40, northZ: -233, southZ: -297),
  (x: 60, northZ: -240, southZ: -293),
  (x: 80, northZ: -245, southZ: -288),
  (x: 90, northZ: -248, southZ: -285),
  (x: 100, northZ: -251, southZ: -257),
  (x: 108, northZ: -254, southZ: -256),
];

/// プレイヤー位置 (x, z) が水域内かどうか。
/// 輪郭表の隣り合う地点の間で北端・南端を線形補間して判定する。
bool isInWaterPlaza(double x, double z) {
  final outline = kWaterPlazaOutline;
  if (x < outline.first.x || x > outline.last.x) return false;
  for (var i = 0; i < outline.length - 1; i++) {
    final a = outline[i];
    final b = outline[i + 1];
    if (x <= b.x) {
      final t = (x - a.x) / (b.x - a.x);
      final north = a.northZ + (b.northZ - a.northZ) * t;
      final south = a.southZ + (b.southZ - a.southZ) * t;
      return z >= south && z <= north;
    }
  }
  return false;
}

class CollisionResolver {
  CollisionResolver({required this._grid});

  final CollisionGrid _grid;

  /// Resolves a move from [currentX]/[currentZ] to [nextX]/[nextZ] using
  /// axis-separated wall sliding. If [onRing] is true, movement is confined
  /// to the skywalk corridor, access ramps/escalators, and observatory decks,
  /// with floor height dynamically calculated based on position.
  ({double x, double z, double y}) resolve({
    required double currentX,
    required double currentZ,
    required double currentY,
    required double nextX,
    required double nextZ,
    required bool onRing,
  }) {
    double x = currentX;
    double z = currentZ;

    final dx = nextX - currentX;
    final dz = nextZ - currentZ;
    final distance = sqrt(dx * dx + dz * dz);
    const maxStep = 0.5;
    final steps = distance <= maxStep ? 1 : (distance / maxStep).ceil();
    final stepX = dx / steps;
    final stepZ = dz / steps;

    for (int i = 0; i < steps; i++) {
      final targetX = x + stepX;
      final targetZ = z + stepZ;

      if (onRing) {
        final resolved = _resolveRingStep(x, z, targetX, targetZ);
        x = resolved.x;
        z = resolved.z;
        continue;
      }

      final resolved = _resolveGroundStep(x, z, targetX, targetZ);
      x = resolved.x;
      z = resolved.z;
    }

    if (onRing) {
      final floorY = _ringFloorY(x, z);
      // 手すり（バー Y ≈ 24.9m）や木造梁を完全にクリアし、会場全体を見下ろせる目線高さ。
      return (x: x, z: z, y: floorY + 7.3);
    }

    return (x: x, z: z, y: currentY);
  }

  ({double x, double z}) _resolveGroundStep(
    double currentX,
    double currentZ,
    double nextX,
    double nextZ,
  ) {
    double x = nextX;
    double z = nextZ;

    if (!_isWalkable(x, z)) {
      final xOnly = _isWalkable(x, currentZ);
      final zOnly = _isWalkable(currentX, z);
      if (xOnly && !zOnly) {
        z = currentZ;
      } else if (zOnly && !xOnly) {
        x = currentX;
      } else if (xOnly && zOnly) {
        final dx = (nextX - currentX).abs();
        final dz = (nextZ - currentZ).abs();
        if (dx >= dz) {
          z = currentZ;
        } else {
          x = currentX;
        }
      } else {
        x = currentX;
        z = currentZ;
      }
    }

    return (x: x, z: z);
  }

  bool _isWalkable(double x, double z) {
    if (isInWaterPlaza(x, z)) return false;
    if (_grid.isBlocked(x, z)) return false;
    return true;
  }

  // --- Ring Navigation & Collision ---

  ({double x, double z}) _resolveRingStep(
    double currentX,
    double currentZ,
    double nextX,
    double nextZ,
  ) {
    if (_isRingWalkable(nextX, nextZ)) {
      return (x: nextX, z: nextZ);
    }

    // Try axis-separated wall sliding along the ring handrails / ramp walls
    final xOnly = _isRingWalkable(nextX, currentZ);
    final zOnly = _isRingWalkable(currentX, nextZ);

    if (xOnly && !zOnly) {
      return (x: nextX, z: currentZ);
    } else if (zOnly && !xOnly) {
      return (x: currentX, z: nextZ);
    } else if (xOnly && zOnly) {
      final dx = (nextX - currentX).abs();
      final dz = (nextZ - currentZ).abs();
      if (dx >= dz) {
        return (x: nextX, z: currentZ);
      } else {
        return (x: currentX, z: nextZ);
      }
    }

    // If already outside walkable area (e.g. teleported into handrail),
    // smoothly clamp to ring band.
    if (!_isRingWalkable(currentX, currentZ)) {
      return _clampToRingBand(nextX, nextZ);
    }

    return (x: currentX, z: currentZ);
  }

  /// プレイヤー位置 (x, z) がリング上の歩行可能通路内かどうか。
  /// スカイウォーク主通路帯、5箇所のアクセススロープ/エスカレーター、
  /// および展望台デッキを包含する。
  bool _isRingWalkable(double x, double z) {
    // 1. 各アクセススロープ・エスカレーター（地上からの登り口）
    if (_isInEastEscalator(x, z)) return true;
    if (_isInSoutheastRamp(x, z)) return true;
    if (_isInWestRamp(x, z)) return true;
    if (_isInNorthRamp(x, z)) return true;
    if (_isInNorthwestRamp(x, z)) return true;

    // 2. 主通路デッキ帯（手すりに挟まれたスカイウォーク）
    final r = _ringRadius(x, z);
    if (r >= kRingInnerRadius && r <= kRingOuterRadius) {
      return true;
    }

    return false;
  }

  // 1. 東ゲートエスカレーター (Prim 7)
  // X: [260.0, 305.0], Z: [76.0, 89.0]
  bool _isInEastEscalator(double x, double z) {
    return x >= 260.0 && x <= 305.0 && z >= 76.0 && z <= 89.0;
  }

  // 2. 南東スロープ (Prim 0)
  // X: [185.0, 215.0], Z: [-224.0, -198.0]
  bool _isInSoutheastRamp(double x, double z) {
    if (x >= 185.0 && x <= 215.0 && z >= -224.0 && z <= -198.0) {
      final r = _ringRadius(x, z);
      return r >= 275.0 && r <= 318.0;
    }
    return false;
  }

  // 3. 西スロープ (Prim 6)
  // X: [-305.0, -265.0], Z: [-87.0, -73.0]
  bool _isInWestRamp(double x, double z) {
    if (x >= -305.0 && x <= -265.0 && z >= -87.0 && z <= -73.0) {
      final r = _ringRadius(x, z);
      return r >= 275.0 && r <= 318.0;
    }
    return false;
  }

  // 4. 北スロープ (Prim 15)
  // X: [49.0, 59.0], Z: [270.0, 316.0]
  bool _isInNorthRamp(double x, double z) {
    return x >= 49.0 && x <= 59.0 && z >= 270.0 && z <= 316.0;
  }

  // 5. 北西スロープ (Prim 22)
  // X: [-272.0, -240.0], Z: [136.0, 156.0]
  bool _isInNorthwestRamp(double x, double z) {
    if (x >= -272.0 && x <= -240.0 && z >= 136.0 && z <= 156.0) {
      final r = _ringRadius(x, z);
      return r >= 275.0 && r <= 318.0;
    }
    return false;
  }

  /// リング上の床面高さ（Y座標）の算出。
  double _ringFloorY(double x, double z) {
    // 東ゲート側エスカレーター傾斜
    // 3Dモデル実測: X in [260, 266] (地上側踊り場 Y=9.5),
    // X in [266, 284] (傾斜部 30度), X in [284, 305] (最上部フロア Y=21.2)
    if (_isInEastEscalator(x, z)) {
      if (x <= 266.0) return 9.5;
      if (x >= 284.0) return kRingDeckBaseY;
      final t = (x - 266.0) / (284.0 - 266.0);
      return 9.5 + t * (kRingDeckBaseY - 9.5);
    }

    // スロープ（南東、西、北、北西）
    if (_isInSoutheastRamp(x, z) ||
        _isInWestRamp(x, z) ||
        _isInNorthRamp(x, z) ||
        _isInNorthwestRamp(x, z)) {
      final r = _ringRadius(x, z);
      if (r <= 276.0) return 9.5;
      if (r >= 307.0) return kRingDeckBaseY;
      final t = (r - 276.0) / (307.0 - 276.0);
      return 9.5 + t * (kRingDeckBaseY - 9.5);
    }

    // 主通路デッキ
    final r = _ringRadius(x, z);
    final t = ((r - kRingDeckBaseRadius) /
            (kRingDeckOuterRadius - kRingDeckBaseRadius))
        .clamp(0.0, 1.0);
    return kRingDeckBaseY + t * (kRingDeckOuterY - kRingDeckBaseY);
  }

  ({double x, double z}) _clampToRingBand(double x, double z) {
    final dx = x - kRingCenterX;
    final dz = z - kRingCenterZ;
    final r = sqrt(dx * dx + dz * dz);
    if (r == 0) return (x: kRingInnerRadius, z: 0.0);
    if (r >= kRingInnerRadius && r <= kRingOuterRadius) {
      return (x: x, z: z);
    }
    final targetR = r < kRingInnerRadius ? kRingInnerRadius : kRingOuterRadius;
    final scale = targetR / r;
    return (x: kRingCenterX + dx * scale, z: kRingCenterZ + dz * scale);
  }

  double _ringRadius(double x, double z) {
    final dx = x - kRingCenterX;
    final dz = z - kRingCenterZ;
    return sqrt(dx * dx + dz * dz);
  }
}
