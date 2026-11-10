import 'dart:io';

import 'package:app/model/auth/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import '../../support/api_client.dart';
import '../../support/play.dart';

/// セッション管理のテストダブル。保存済みセッションの有無を切り替える。
class FakeSessionManager extends Fake implements FlutterAuthSessionManager {
  FakeSessionManager({AuthSuccess? stored}) : _authInfo = stored;

  AuthSuccess? _authInfo;
  Object? initializeError;
  int updateCalls = 0;

  @override
  AuthSuccess? get authInfo => _authInfo;

  @override
  bool get isAuthenticated => _authInfo != null;

  @override
  Future<bool> initialize({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final error = initializeError;
    if (error != null) {
      throw error;
    }
    return _authInfo != null;
  }

  @override
  Future<void> updateSignedInUser(AuthSuccess? authInfo) async {
    updateCalls++;
    _authInfo = authInfo;
  }
}

AuthSuccess _success() => AuthSuccess(
  authStrategy: 'jwt',
  token: 'test-token',
  authUserId: testAuthUserId,
  scopeNames: const {},
);

void main() {
  ProviderContainer containerWith({
    required TestApiClient client,
    required FakeSessionManager manager,
  }) {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        authSessionManagerProvider.overrideWithValue(manager),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  TestApiClient clientWith({
    required Future<AuthSuccess> Function() login,
  }) => TestApiClient(
    getProfile: (_) async => throw StateError('未設定'),
    setNickname: (_) async => throw StateError('未設定'),
    refreshAuthentication: () async {},
    login: login,
  );

  test('保存済みセッションがあれば匿名ログインしない', () async {
    var loginCalls = 0;
    final container = containerWith(
      client: clientWith(
        login: () async {
          loginCalls++;
          return _success();
        },
      ),
      manager: FakeSessionManager(stored: _success()),
    );
    await container.read(authProvider.notifier).ensureSignedIn();
    expect(loginCalls, 0);
    expect(container.read(authProvider).status, AuthStatus.signedIn);
    expect(container.read(authProvider).authUserId, testAuthUserId);
  });

  test('保存済みセッションがなければ匿名ログインして保管する', () async {
    var loginCalls = 0;
    final manager = FakeSessionManager();
    final container = containerWith(
      client: clientWith(
        login: () async {
          loginCalls++;
          return _success();
        },
      ),
      manager: manager,
    );
    await container.read(authProvider.notifier).ensureSignedIn();
    expect(loginCalls, 1);
    expect(manager.updateCalls, 1);
    expect(container.read(authProvider).status, AuthStatus.signedIn);
    expect(container.read(authProvider).authUserId, testAuthUserId);
  });

  test('復旧自体が通信失敗したら、匿名アカウントを作り直さず失敗にする', () async {
    var loginCalls = 0;
    final manager = FakeSessionManager(stored: _success())
      ..initializeError = const SocketException('切断');
    final container = containerWith(
      client: clientWith(
        login: () async {
          loginCalls++;
          return _success();
        },
      ),
      manager: manager,
    );
    await expectLater(
      container.read(authProvider.notifier).ensureSignedIn(),
      throwsA(
        isA<AuthFailure>().having((e) => e.kind, 'kind', AuthFailureKind.unavailable),
      ),
    );
    expect(loginCalls, 0);
    expect(container.read(authProvider).status, AuthStatus.failed);
  });

  test('匿名ログインが通信失敗したら失敗にする', () async {
    var loginCalls = 0;
    final container = containerWith(
      client: clientWith(
        login: () async {
          loginCalls++;
          throw const SocketException('切断');
        },
      ),
      manager: FakeSessionManager(),
    );
    await expectLater(
      container.read(authProvider.notifier).ensureSignedIn(),
      throwsA(
        isA<AuthFailure>().having((e) => e.kind, 'kind', AuthFailureKind.unavailable),
      ),
    );
    expect(loginCalls, 1);
    expect(container.read(authProvider).status, AuthStatus.failed);
  });
}
