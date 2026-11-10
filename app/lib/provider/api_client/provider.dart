import 'package:photohunt_client/photohunt_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// run:localが渡す接続先。指定がなければローカルのiOSシミュレーター用。
@riverpod
String apiBaseUrl(Ref ref) => const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/',
);

/// 機能に依存しない生成Client。認証の接続側もこのProviderを使用する。
/// このProviderが生成したClientの寿命はProviderが所有する。
@riverpod
Client apiClient(Ref ref) {
  final client = Client(ref.watch(apiBaseUrlProvider));
  ref.onDispose(client.close);
  return client;
}
