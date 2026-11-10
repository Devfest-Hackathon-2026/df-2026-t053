import 'dart:async';
import 'dart:developer';

import 'package:app/model/auth/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

part 'provider.g.dart';

/// SDKのセッション管理を生成Clientへ接続する。トークンの保管・更新は
/// SDK（secure storage）が担当し、アプリ側へトークン文字列を持たない。
@riverpod
FlutterAuthSessionManager authSessionManager(Ref ref) {
  final client = ref.watch(apiClientProvider);
  final manager = FlutterAuthSessionManager();
  client.authSessionManager = manager;
  return manager;
}

/// 匿名認証の復旧と初回作成を担当する。一時的な通信失敗では保存済みの
/// セッションを保持し、匿名アカウントを作り直さない。
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // 接続先が変われば新しいClientとセッション管理で復旧し直す。
    _generation++;
    _ensuring = null;
    ref.watch(apiClientProvider);
    ref.watch(authSessionManagerProvider);
    return const AuthState();
  }

  Future<void>? _ensuring;
  int _generation = 0;

  /// 保存済み認証を復旧し、保存がなければ匿名アカウントを作成する。
  /// 既に認証済みなら何もしない。同時に呼ばれた場合は処理を共有する。
  Future<void> ensureSignedIn() {
    if (state.status == .signedIn) {
      return Future.value();
    }
    final ensuring = _ensuring;
    if (ensuring != null) return ensuring;
    final generation = _generation;
    final future = _ensureSignedIn(generation).whenComplete(() {
      if (generation == _generation) _ensuring = null;
    });
    _ensuring = future;
    return future;
  }

  Future<void> _ensureSignedIn(int generation) async {
    final client = ref.read(apiClientProvider);
    final manager = ref.read(authSessionManagerProvider);
    state = state.copyWith(status: .restoring);
    try {
      // 保存済みセッションの復旧と検証。通信失敗ではセッションを破棄せず、
      // isAuthenticated が残るため、そのまま認証済みとして扱う。
      await manager.initialize();
      if (!ref.mounted || generation != _generation) {
        return;
      }
      if (manager.isAuthenticated) {
        final authInfo = manager.authInfo;
        if (authInfo == null) throw const AuthFailure(.unavailable);
        state = AuthState(status: .signedIn, authUserId: authInfo.authUserId);
        return;
      }
      // 保存済みセッションがない場合だけ匿名アカウントを作成する。
      final success = await client.anonymousIdp.login();
      if (!ref.mounted || generation != _generation) return;
      await manager.updateSignedInUser(success);
      if (!ref.mounted || generation != _generation) {
        return;
      }
      state = AuthState(status: .signedIn, authUserId: success.authUserId);
    } catch (error, stackTrace) {
      // SDK例外には応答本文が入ることがあるため、種類とstackだけ記録する。
      log(
        '認証の復旧または作成に失敗しました',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      if (!ref.mounted || generation != _generation) {
        return;
      }
      state = state.copyWith(status: .failed);
      throw const AuthFailure(.unavailable);
    }
  }
}
