// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// プロフィールRPCとSDK例外の変換を担当する。画面状態はViewModelへ置く。

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierProvider._();

/// プロフィールRPCとSDK例外の変換を担当する。画面状態はViewModelへ置く。
final class ProfileNotifierProvider
    extends $NotifierProvider<ProfileNotifier, Client> {
  /// プロフィールRPCとSDK例外の変換を担当する。画面状態はViewModelへ置く。
  ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Client>(value),
    );
  }
}

String _$profileNotifierHash() => r'd05a14ec825d83e443c74c3883baa7f56ffb1a6c';

/// プロフィールRPCとSDK例外の変換を担当する。画面状態はViewModelへ置く。

abstract class _$ProfileNotifier extends $Notifier<Client> {
  Client build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Client, Client>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Client, Client>,
              Client,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
