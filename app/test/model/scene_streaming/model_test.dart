import 'dart:convert';
import 'dart:io';

import 'package:app/model/scene_asset.dart';
import 'package:app/model/scene_streaming/model.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:app/usecase/scene/scene_tile_streamer.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// 同梱する区画manifestと、生成された区画モデルの整合を確かめる。
void main() {
  final file = File(SceneCatalog.draco.assetPath);
  final Map<String, Object?> json = switch (jsonDecode(
    file.readAsStringSync(),
  )) {
    final Map<String, Object?> map => map,
    _ => throw const FormatException('manifestがJSONオブジェクトではありません'),
  };
  final manifest = SceneTileManifest.fromJson(json);

  test('アプリが対応する版で、区画が重複なく並ぶ', () {
    expect(manifest.version, kSceneTileManifestVersion);
    expect(manifest.tiles, isNotEmpty);
    final ids = manifest.tiles.map((tile) => tile.id).toSet();
    expect(ids, hasLength(manifest.tiles.length));
  });

  test('高精細区画の三角形数の合計が加工元（面積ゼロを除く）と一致し、簡略区画は少ない', () {
    final detail = manifest.tiles.fold(
      0,
      (total, tile) => total + tile.detailTriangles,
    );
    final coarse = manifest.tiles.fold(
      0,
      (total, tile) => total + tile.coarseTriangles,
    );
    final source = json['sourceTriangles'];
    final degenerate = json['degenerateTriangles'];
    expect(source, isA<int>());
    expect(degenerate, isA<int>());
    if (source is int && degenerate is int) {
      expect(detail, source - degenerate);
    }
    expect(coarse, lessThan(detail));
    for (final tile in manifest.tiles) {
      expect(tile.coarseTriangles, lessThanOrEqualTo(tile.detailTriangles));
    }
  });

  test('区画の範囲が有効で、参照するモデルが同梱対象にある', () {
    for (final tile in manifest.tiles) {
      expect(tile.minX, lessThanOrEqualTo(tile.maxX), reason: tile.id);
      expect(tile.minZ, lessThanOrEqualTo(tile.maxZ), reason: tile.id);
      for (final path in [tile.detailPath, tile.coarsePath]) {
        expect(path, startsWith('assets/models/tiles/'), reason: tile.id);
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }
  });

  test('初期位置の近くに高精細で読み込む区画がある', () {
    // ストリーマーと同じ距離（区画範囲までのユークリッド距離）で判定する。
    final near = manifest.tiles.where(
      (tile) =>
          sceneTileDistance(tile, kStartPositionX, kStartPositionZ) <=
          kSceneStreamingSettings.detailDistanceMeters,
    );
    expect(near, isNotEmpty);
  });

  test('manifestが同梱しない加工元GLBから生成されたものである', () {
    final source = File('assets_src/models/merged_model_draco.glb');
    expect(json['source'], 'merged_model_draco.glb');
    expect(
      json['sourceSha256'],
      sha256.convert(source.readAsBytesSync()).toString(),
      reason: '加工元が変わったら app/tool/scene_tiles で区画を再生成する',
    );
  });
}
