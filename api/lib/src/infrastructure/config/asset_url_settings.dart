import '../../domain/exceptions.dart';
import '../../domain/models/asset.dart';
import '../../domain/ports/asset_url_resolver.dart';
import 'replication_settings.dart';
import 'runtime_environment.dart';

/// development / test で `ASSET_BASE_URL` が未設定のときの値（ローカルの fake-gcs-server）。
const kLocalAssetBaseUrl = 'http://localhost:4443/photohunt-media-local/';

/// オブジェクト名の形。seed（#26）が `media/{sha256}/{photo|map}.{拡張子}` で置く。
final RegExp _objectPathPattern = RegExp(
  r'^media/([0-9a-f]{64})/[A-Za-z0-9][A-Za-z0-9._-]*$',
);

/// `ASSET_BASE_URL` から素材の公開 URL を作る（docs/specs.md「素材URLと取得上限」）。
///
/// - 本番（production）は https だけ。http はローカルの GCS エミュレーター
///   （`STORAGE_EMULATOR_HOST`）を使うときだけ許す。エミュレーターの設定は Cloud Run で
///   拒否する（[rejectEmulatorOnCloudRun]）ので、Cloud Run では必ず https になる。
/// - 認証情報・クエリ・フラグメントを含む値は拒否する。
/// - 起動時に検証し、誤りなら起動を失敗させる。
class AssetUrls._(
  /// 末尾が `/` の基底 URL。
  final Uri baseUrl,
) implements AssetUrlResolver {
  /// 環境変数から作る。[production] が false（development / test）なら、未設定のとき
  /// [kLocalAssetBaseUrl] を使い、http を許す。
  factory fromEnvironment(Map<String, String> env, {required bool production}) {
    rejectEmulatorOnCloudRun(env);
    final raw = env['ASSET_BASE_URL'] ?? '';
    if (raw.isEmpty && production) {
      throw const ConfigurationException('ASSET_BASE_URL が未設定');
    }
    final emulator = isLocalEmulator(env);
    return AssetUrls.parse(
      raw.isEmpty ? kLocalAssetBaseUrl : raw,
      allowHttp: !production || emulator,
    );
  }

  /// [value] を検証して作る。
  factory parse(String value, {required bool allowHttp}) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      // 値は認証情報を含み得るので、エラーメッセージ（起動ログ）に出さない。
      throw const ConfigurationException('ASSET_BASE_URL が URL として読めない');
    }
    if (uri.scheme != 'https' && !(allowHttp && uri.scheme == 'http')) {
      throw ConfigurationException(
        allowHttp
            ? 'ASSET_BASE_URL は http か https にする（スキーム: ${uri.scheme}）'
            : 'ASSET_BASE_URL は https にする（http はローカルのエミュレーターだけ。'
                  'スキーム: ${uri.scheme}）',
      );
    }
    if (uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment) {
      throw const ConfigurationException(
        'ASSET_BASE_URL に認証情報・クエリ・フラグメントを含めない',
      );
    }
    final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return AssetUrls._(uri.replace(path: path));
  }

  @override
  String urlFor(Asset asset) {
    final match = _objectPathPattern.firstMatch(asset.objectPath);
    if (match == null || match.group(1) != asset.sha256) {
      throw CorruptedDataException(
        entity: 'asset',
        field: 'object_path',
        message: 'asset ${asset.id} のオブジェクト名が media/{sha256}/{file} の形ではない',
      );
    }
    return baseUrl.resolve(asset.objectPath).toString();
  }
}
