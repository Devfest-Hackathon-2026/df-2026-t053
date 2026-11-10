import 'dart:convert';
import 'dart:io';

import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/health/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

void main() {
  test('実生成ClientのpingとSDK認証ヘッダーをローカルHTTPで確認する', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final headers = <String?>[];
    final subscription = server.listen((request) async {
      headers.add(request.headers.value(HttpHeaders.authorizationHeader));
      await request.drain<void>();
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'releaseId': 'local-test',
          'time': '2026-11-09T00:00:00.000Z',
        }),
      );
      await request.response.close();
    });
    addTearDown(subscription.cancel);
    final container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWithValue(
          'http://127.0.0.1:${server.port}/',
        ),
      ],
    );
    addTearDown(container.dispose);
    final keep = container.listen(healthProvider, (_, _) {});
    addTearDown(keep.close);
    expect(
      (await container.read(healthProvider.notifier).ping()).releaseId,
      'local-test',
    );
    final client = container.read(apiClientProvider);
    final manager = FlutterAuthSessionManager(storage: MemoryAuthStorage());
    client.authSessionManager = manager;
    await manager.updateSignedInUser(
      AuthSuccess(
        authStrategy: 'session',
        token: 'local-test-token',
        authUserId: UuidValue.fromString(
          '00000000-0000-4000-8000-000000000001',
        ),
        scopeNames: {},
      ),
    );
    await container.read(healthProvider.notifier).ping();
    expect(headers, [null, 'Bearer local-test-token']);
    expect(identical(client, container.read(apiClientProvider)), isTrue);
  });
}
