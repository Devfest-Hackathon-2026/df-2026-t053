import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/asset.dart';
import 'package:photohunt_server/src/infrastructure/config/asset_url_settings.dart';
import 'package:photohunt_server/src/infrastructure/config/replication_settings.dart';
import 'package:test/test.dart';

final _sha = 'a' * 64;

Asset _asset(String objectPath, {String? sha256}) => Asset(
  id: 1,
  sha256: sha256 ?? _sha,
  objectPath: objectPath,
  contentType: 'image/png',
  byteLength: 10,
  createdAt: DateTime.utc(2026),
);

void main() {
  group('起動時の検証', () {
    AssetUrls prod(Map<String, String> env) =>
        AssetUrls.fromEnvironment(env, production: true);

    test('本番は https を受け付ける', () {
      final urls = prod({
        'ASSET_BASE_URL': 'https://storage.googleapis.com/photohunt-media',
      });
      expect(
        urls.baseUrl.toString(),
        'https://storage.googleapis.com/photohunt-media/',
      );
    });

    test('本番で https でなければ起動しない', () {
      expect(
        () => prod({'ASSET_BASE_URL': 'http://storage.googleapis.com/b/'}),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('本番で未設定なら起動しない', () {
      expect(() => prod({}), throwsA(isA<ConfigurationException>()));
    });

    test('本番でも、ローカルの GCS エミュレーターを使うときだけ http を許す', () {
      final urls = prod({
        'ASSET_BASE_URL': 'http://localhost:4443/photohunt-media-local/',
        'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
      });
      expect(urls.baseUrl.scheme, 'http');
    });

    test('Cloud Run ではエミュレーターの設定ごと拒否する（http は通らない）', () {
      expect(
        () => prod({
          'ASSET_BASE_URL': 'http://localhost:4443/b/',
          'STORAGE_EMULATOR_HOST': 'http://gcs:4443',
          'K_SERVICE': 'photohunt-api',
        }),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('development・test は未設定ならローカルの値を使う', () {
      final urls = AssetUrls.fromEnvironment({}, production: false);
      expect(urls.baseUrl.toString(), kLocalAssetBaseUrl);
    });

    for (final bad in const [
      'https://user:pass@example.com/b/',
      'https://example.com/b/?x=1',
      'https://example.com/b/#f',
      'ftp://example.com/b/',
      'not a url',
      '/relative/path/',
    ]) {
      test('拒否する: $bad', () {
        expect(
          () => prod({'ASSET_BASE_URL': bad}),
          throwsA(isA<ConfigurationException>()),
        );
      });
    }
  });

  group('エラーメッセージに値を出さない（認証情報の漏えい防止）', () {
    for (final bad in const [
      'https://user:secret-pass@example.com/b/',
      'https://example.com/b/?token=secret-pass',
      'https://example.com/b/#secret-pass',
      'http://user:secret-pass@example.com/b/',
      'ftp://user:secret-pass@example.com/b/',
      'user:secret-pass',
    ]) {
      test('拒否しても secret-pass を含めない: $bad', () {
        for (final allowHttp in [false, true]) {
          try {
            AssetUrls.parse(bad, allowHttp: allowHttp);
          } on ConfigurationException catch (e) {
            expect(e.toString(), isNot(contains('secret-pass')));
            continue;
          }
          // http を許す設定では、認証情報のない http は通る。ここで通るのは対象外。
          expect(
            allowHttp && !bad.contains('@') && bad.startsWith('http'),
            isTrue,
          );
        }
      });
    }
  });

  group('URL の組み立て', () {
    final urls = AssetUrls.parse(
      'https://storage.googleapis.com/photohunt-media',
      allowHttp: false,
    );

    test('基底 URL と media/{sha256}/{file} をつなぐ', () {
      expect(
        urls.urlFor(_asset('media/$_sha/photo.png')),
        'https://storage.googleapis.com/photohunt-media/media/$_sha/photo.png',
      );
    });

    for (final path in [
      'media/${'b' * 64}/photo.png', // sha256 が違う
      'photo.png',
      'media/$_sha/../secret.png',
      'media/$_sha/a/b.png',
      'media/$_sha/photo.png?x=1',
      '/media/$_sha/photo.png',
    ]) {
      test('内容アドレスの形でないオブジェクト名は壊れたデータ: $path', () {
        expect(
          () => urls.urlFor(_asset(path)),
          throwsA(isA<CorruptedDataException>()),
        );
      });
    }
  });
}
