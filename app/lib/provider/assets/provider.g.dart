// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assetCacheSettings)
final assetCacheSettingsProvider = AssetCacheSettingsProvider._();

final class AssetCacheSettingsProvider
    extends
        $FunctionalProvider<
          AssetCacheSettings,
          AssetCacheSettings,
          AssetCacheSettings
        >
    with $Provider<AssetCacheSettings> {
  AssetCacheSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetCacheSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetCacheSettingsHash();

  @$internal
  @override
  $ProviderElement<AssetCacheSettings> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssetCacheSettings create(Ref ref) {
    return assetCacheSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetCacheSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetCacheSettings>(value),
    );
  }
}

String _$assetCacheSettingsHash() =>
    r'1a8231f78f6a53d75f09cef68da8b6a357af5192';

@ProviderFor(assetCacheDirectory)
final assetCacheDirectoryProvider = AssetCacheDirectoryProvider._();

final class AssetCacheDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Directory>,
          Directory,
          FutureOr<Directory>
        >
    with $FutureModifier<Directory>, $FutureProvider<Directory> {
  AssetCacheDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetCacheDirectoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetCacheDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Directory> create(Ref ref) {
    return assetCacheDirectory(ref);
  }
}

String _$assetCacheDirectoryHash() =>
    r'b5868fae95a7939a058067564c7ab2bbe1ac662c';

/// アプリ全体で取得と参照を共有する。モデル素材・RPC・画面状態は扱わない。

@ProviderFor(AssetsNotifier)
final assetsProvider = AssetsNotifierProvider._();

/// アプリ全体で取得と参照を共有する。モデル素材・RPC・画面状態は扱わない。
final class AssetsNotifierProvider
    extends $NotifierProvider<AssetsNotifier, void> {
  /// アプリ全体で取得と参照を共有する。モデル素材・RPC・画面状態は扱わない。
  AssetsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetsNotifierHash();

  @$internal
  @override
  AssetsNotifier create() => AssetsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$assetsNotifierHash() => r'1b0028f931dfa6d0d4768500288266e521fbebf2';

/// アプリ全体で取得と参照を共有する。モデル素材・RPC・画面状態は扱わない。

abstract class _$AssetsNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
