import '../exceptions.dart';
import '../models/asset.dart';

/// 素材の公開 URL を作る（docs/specs.md「素材URLと取得上限」）。
///
/// URL は環境設定された素材バケットの origin と `media/{sha256}/{file}` 形式だけを使う。
abstract interface class AssetUrlResolver() {
  /// [asset] の公開 URL。オブジェクト名が内容アドレスの形でなければ
  /// [CorruptedDataException]（DB の値がドメインの前提を満たさない）。
  String urlFor(Asset asset);
}
