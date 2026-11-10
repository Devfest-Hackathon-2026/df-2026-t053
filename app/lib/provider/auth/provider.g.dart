// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SDKのセッション管理を生成Clientへ接続する。トークンの保管・更新は
/// SDK（secure storage）が担当し、アプリ側へトークン文字列を持たない。

@ProviderFor(authSessionManager)
final authSessionManagerProvider = AuthSessionManagerProvider._();

/// SDKのセッション管理を生成Clientへ接続する。トークンの保管・更新は
/// SDK（secure storage）が担当し、アプリ側へトークン文字列を持たない。

final class AuthSessionManagerProvider
    extends
        $FunctionalProvider<
          FlutterAuthSessionManager,
          FlutterAuthSessionManager,
          FlutterAuthSessionManager
        >
    with $Provider<FlutterAuthSessionManager> {
  /// SDKのセッション管理を生成Clientへ接続する。トークンの保管・更新は
  /// SDK（secure storage）が担当し、アプリ側へトークン文字列を持たない。
  AuthSessionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionManagerHash();

  @$internal
  @override
  $ProviderElement<FlutterAuthSessionManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterAuthSessionManager create(Ref ref) {
    return authSessionManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterAuthSessionManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterAuthSessionManager>(value),
    );
  }
}

String _$authSessionManagerHash() =>
    r'31aac7491103cb89f7c3b5734a2531a2db7b77fc';

/// 匿名認証の復旧と初回作成を担当する。一時的な通信失敗では保存済みの
/// セッションを保持し、匿名アカウントを作り直さない。

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// 匿名認証の復旧と初回作成を担当する。一時的な通信失敗では保存済みの
/// セッションを保持し、匿名アカウントを作り直さない。
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// 匿名認証の復旧と初回作成を担当する。一時的な通信失敗では保存済みの
  /// セッションを保持し、匿名アカウントを作り直さない。
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'f081f50943f8d87dd8cd8b6e010e51fde499316b';

/// 匿名認証の復旧と初回作成を担当する。一時的な通信失敗では保存済みの
/// セッションを保持し、匿名アカウントを作り直さない。

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
