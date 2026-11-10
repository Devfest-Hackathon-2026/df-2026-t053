import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';
part 'model.g.dart';

/// 区画の描画に使う詳細度。近景は加工元と同じ形状、遠景は簡略モデル。
enum SceneTileLod { coarse, detail }

/// 区画の読み込み距離。値はm単位で、プレイヤー位置から区画範囲までの水平距離と比べる。
@freezed
abstract class SceneStreamingSettings with _$SceneStreamingSettings {
  const factory SceneStreamingSettings({
    /// この距離以内の区画を、少なくとも簡略モデルで読み込む。
    @Default(2200) double drawDistanceMeters,

    /// この距離以内の区画を、高精細モデルへ切り替える。
    @Default(200) double detailDistanceMeters,

    /// 境界付近の往復で読み込みと解放を繰り返さないための余裕。
    /// 読み込んだ区画は、各距離にこの値を足した距離まで維持する。
    @Default(40) double hysteresisMeters,

    /// 同時に読み込む区画の上限。近い区画から順に読み込む。
    @Default(2) int maxConcurrentLoads,

    /// この距離を超えて移動するまで、必要な区画を計算し直さない。
    @Default(5) double updateStepMeters,

    /// 読み込みに失敗した区画を再試行するまでの待ち時間。
    @Default(Duration(seconds: 3)) Duration retryDelay,
  }) = _SceneStreamingSettings;
}

/// 加工コマンド（app/tool/scene_tiles）が生成する区画一覧。
@freezed
abstract class SceneTileManifest with _$SceneTileManifest {
  const factory SceneTileManifest({
    required int version,
    required double tileSizeMeters,
    required List<SceneTile> tiles,
  }) = _SceneTileManifest;

  factory SceneTileManifest.fromJson(Map<String, Object?> json) =>
      _$SceneTileManifestFromJson(json);
}

/// 1区画の範囲（アプリの座標、m）と、詳細度ごとのモデルの参照先。
@freezed
abstract class SceneTile with _$SceneTile {
  const factory SceneTile({
    required String id,
    required double minX,
    required double maxX,
    required double minZ,
    required double maxZ,
    required String detailPath,
    required String coarsePath,
    required int detailTriangles,
    required int coarseTriangles,
  }) = _SceneTile;

  factory SceneTile.fromJson(Map<String, Object?> json) =>
      _$SceneTileFromJson(json);
}
