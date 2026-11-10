import 'dart:developer';

import 'package:app/model/health/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// 認証不要の疎通確認。業務APIの準備完了を保証するものではない。
@riverpod
class HealthNotifier extends _$HealthNotifier {
  @override
  void build() {
    ref.watch(apiClientProvider);
  }

  Future<HealthResponse> ping() async {
    final client = ref.read(apiClientProvider);
    try {
      final response = await client.health
          .ping(HealthRequest())
          .timeout(const Duration(seconds: 10));
      const expected = String.fromEnvironment('API_RELEASE_ID');
      if (expected.isNotEmpty && response.releaseId != expected) {
        throw const HealthFailure(.releaseMismatch);
      }
      return response;
    } catch (error, stackTrace) {
      log('API疎通を確認できませんでした', error: error.runtimeType, stackTrace: stackTrace);
      if (error is HealthFailure) rethrow;
      throw const HealthFailure(.unreachable);
    }
  }
}
