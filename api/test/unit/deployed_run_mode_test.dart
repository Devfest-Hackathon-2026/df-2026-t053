import 'package:photohunt_server/src/infrastructure/config/asset_url_settings.dart';
import 'package:photohunt_server/src/infrastructure/config/replication_settings.dart'
    show ConfigurationException;
import 'package:photohunt_server/src/infrastructure/config/runtime_environment.dart';
import 'package:test/test.dart';

void main() {
  test('staging・production は配備された環境、development・test は開発', () {
    expect(isDeployedRunMode('production'), isTrue);
    expect(isDeployedRunMode('staging'), isTrue);
    expect(isDeployedRunMode('development'), isFalse);
    expect(isDeployedRunMode('test'), isFalse);
  });

  test('staging で ASSET_BASE_URL が未設定・http なら、localhost に切り替えず失敗する', () {
    for (final env in [
      <String, String>{},
      {'ASSET_BASE_URL': 'http://example.com/media/'},
    ]) {
      expect(
        () => AssetUrls.fromEnvironment(
          env,
          production: isDeployedRunMode('staging'),
        ),
        throwsA(isA<ConfigurationException>()),
      );
    }
  });
}
