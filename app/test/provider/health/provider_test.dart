import 'dart:io';

import 'package:app/model/health/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/health/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/api_client.dart';

void main() {
  for (final fails in [false, true]) {
    test('認証前のping ${fails ? '通信失敗' : '成功とreleaseId取得'}', () async {
      var logins = 0;
      final client = TestApiClient(
        getProfile: (_) async => throw StateError('呼ばない'),
        setNickname: (_) async => throw StateError('呼ばない'),
        refreshAuthentication: () async => throw StateError('呼ばない'),
        login: () async {
          logins++;
          throw StateError('呼ばない');
        },
        ping: (_) async {
          if (fails) throw const SocketException('非公開の値');
          return HealthResponse(
            releaseId: const String.fromEnvironment(
              'API_RELEASE_ID',
              defaultValue: 'test-release',
            ),
            time: DateTime.utc(2026),
          );
        },
      );
      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      final ping = container.read(healthProvider.notifier).ping();
      if (fails) {
        await expectLater(
          ping,
          throwsA(
            isA<HealthFailure>().having(
              (e) => e.kind,
              'kind',
              HealthFailureKind.unreachable,
            ),
          ),
        );
      } else {
        expect(
          (await ping).releaseId,
          const String.fromEnvironment(
            'API_RELEASE_ID',
            defaultValue: 'test-release',
          ),
        );
      }
      expect(logins, 0);
    });
  }
  test('指定したreleaseIdと違うAPIを区別する', () async {
    final client = TestApiClient(
      getProfile: (_) async => throw StateError('呼ばない'),
      setNickname: (_) async => throw StateError('呼ばない'),
      refreshAuthentication: () async {},
      ping: (_) async =>
          HealthResponse(releaseId: 'different', time: DateTime.utc(2026)),
    );
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(healthProvider.notifier).ping(),
      throwsA(
        isA<HealthFailure>().having(
          (e) => e.kind,
          'kind',
          HealthFailureKind.releaseMismatch,
        ),
      ),
    );
  }, skip: const String.fromEnvironment('API_RELEASE_ID').isEmpty);
}
