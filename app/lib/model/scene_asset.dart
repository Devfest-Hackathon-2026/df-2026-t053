import 'package:freezed_annotation/freezed_annotation.dart';

part 'scene_asset.freezed.dart';

@freezed
abstract class SceneAsset with _$SceneAsset {
  const factory SceneAsset({
    required String assetPath,
    required String title,
    required String sizeLabel,
    required String technique,
  }) = _SceneAsset;
}

class SceneCatalog {
  static const draco = SceneAsset(
    assetPath: 'assets/models/tiles/manifest.json',
    title: 'EXPO 2025 会場 3D モデル（区画読み込み）',
    sizeLabel: '17.1 MB（33区画・2段階）',
    technique: '200m区画・近景は加工元の形状、遠景は0.5m格子で簡略化・JPEG 64px',
  );

  static const all = [draco];
}
