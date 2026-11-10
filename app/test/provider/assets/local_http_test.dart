import 'package:app/model/assets/model.dart';
import 'package:app/provider/assets/validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

void main() {
  final hash = 'a' * 64;
  AssetRef asset(String base) => AssetRef(
    url: '$base/media/$hash/photo.png',
    sha256: hash,
    byteLength: 100,
    contentType: 'image/png',
  );
  for (final host in [
    'localhost',
    '127.0.0.1',
    '[::1]',
    '10.0.2.2',
    '192.168.1.10',
    '172.16.1.2',
    '172.31.255.254',
  ]) {
    test('明示したdebugのローカルHTTPだけ許可: $host', () {
      final base = 'http://$host:4443/bucket';
      final settings = AssetCacheSettings(baseUrl: Uri.parse(base));
      expect(
        () => validateAssetReference(
          asset(base),
          settings,
          allowLocalHttp: false,
        ),
        throwsA(const AssetFailure(.invalidReference)),
      );
      expect(
        validateAssetReference(asset(base), settings, allowLocalHttp: true),
        Uri.parse(asset(base).url),
      );
      expect(
        () => validateAssetReference(
          asset('$base-other'),
          settings,
          allowLocalHttp: true,
        ),
        throwsA(const AssetFailure(.invalidReference)),
      );
    });
  }
  for (final host in [
    'example.com',
    'localhost.example.com',
    '8.8.8.8',
    '172.15.1.2',
    '172.32.1.2',
    '192.169.1.1',
    '169.254.169.254',
    '0.0.0.0',
  ]) {
    test('明示しても外部HTTP・metadata・未指定アドレスを拒否: $host', () {
      final base = 'http://$host:4443/bucket';
      expect(
        () => validateAssetReference(
          asset(base),
          AssetCacheSettings(baseUrl: Uri.parse(base)),
          allowLocalHttp: true,
        ),
        throwsA(const AssetFailure(.invalidReference)),
      );
    });
  }
  test('ローカル許可でも別origin・クエリ・ハッシュ違いを拒否', () {
    const base = 'http://localhost:4443/bucket';
    final valid = asset(base);
    final settings = AssetCacheSettings(baseUrl: Uri.parse(base));
    for (final bad in [
      asset('http://localhost:4444/bucket'),
      asset('http://127.0.0.1:4443/bucket'),
      valid.copyWith(url: '${valid.url}?key=value'),
      valid.copyWith(
        url: valid.url.replaceFirst('/photo.png', '/../photo.png'),
      ),
      valid.copyWith(sha256: 'b' * 64),
    ]) {
      expect(
        () => validateAssetReference(bad, settings, allowLocalHttp: true),
        throwsA(const AssetFailure(.invalidReference)),
      );
    }
  });
}
