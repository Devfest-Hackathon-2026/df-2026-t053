import 'package:photohunt_shared/photohunt_shared.dart';

/// seed 入力 1 版（`content/seeds/<slug>/r<n>/revision.yaml` を読んだもの）。
///
/// 読み取り形式（YAML）の型は infrastructure の生成モデルで、ここへ変換して渡す。
class const SeedRevision({
  required final String slug,
  required final String title,
  required final int revisionNo,
  required final String sceneProfile,
  required final String scoringVersion,
  required final String photoAlt,
  required final double eyeHeightMeters,
  required final double shotVerticalFovDegrees,

  /// 正解姿勢。公開 DTO に出さない。
  required final SeedGoal goal,
  required final String story,
  required final String highlight,
  required final SeedAssetFile photo,
  required final SeedAssetFile map,
  required final MapBounds bounds,
  required final List<SeedMode> modes,
  required final List<SeedLandmark> landmarks,
  required final List<Credit> credits,
  required final List<SeedStructure> structures,
});

/// 撮影の正解姿勢。位置は視点（足元の Y に eyeHeightMeters を足した値）。
class const SeedGoal({
  required final double x,
  required final double y,
  required final double z,
  required final double yawDegrees,
  required final double pitchDegrees,
});

/// 素材ファイル。[file] は版のディレクトリからの相対パス。
class const SeedAssetFile({
  required final String file,
  required final String contentType,
});

/// 開始点。label がある自由探索の点だけを、選べる入口として公開する。
class const SeedSpawn({
  required final double positionX,
  required final double positionY,
  required final double positionZ,
  required final double yawDegrees,
  required final String? label,
});

/// モードごとの歩行領域と開始点。
class const SeedMode({
  required final PlayMode mode,
  required final WalkableArea walkable,
  required final List<SeedSpawn> spawns,
});

/// 会場図上の地点。[pavilionKey] は pavilion マスターの sourceKey。
class const SeedLandmark({
  required final String pavilionKey,
  required final String displayName,
  required final double positionX,
  required final double positionZ,
  required final double? latitude,
  required final double? longitude,
});

/// ガイド用の構造物資料。
class const SeedStructure({
  required final String name,
  required final String? pavilionKey,
  required final double positionX,
  required final double positionZ,
  required final String facts,
  required final String fallbackText,
  required final List<GuideSource> sources,
});

/// pavilion マスター 1 件（`content/seeds/pavilions.yaml`）。
class const SeedPavilion({
  required final String sourceKey,
  required final String name,
  required final double? latitude,
  required final double? longitude,
});
