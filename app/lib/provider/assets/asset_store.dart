import 'package:app/model/scene_asset.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'asset_store.g.dart';

class AssetStore {
  const AssetStore();

  SceneAsset resolve() => SceneCatalog.draco;

  List<SceneAsset> get catalog => SceneCatalog.all;

  bool verifyIntegrity(SceneAsset asset) => true;
}

@riverpod
AssetStore assetStore(Ref ref) {
  return const AssetStore();
}
