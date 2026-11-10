// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assetStore)
final assetStoreProvider = AssetStoreProvider._();

final class AssetStoreProvider
    extends $FunctionalProvider<AssetStore, AssetStore, AssetStore>
    with $Provider<AssetStore> {
  AssetStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetStoreHash();

  @$internal
  @override
  $ProviderElement<AssetStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetStore create(Ref ref) {
    return assetStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetStore>(value),
    );
  }
}

String _$assetStoreHash() => r'c436eba00ea580c95c4da011b15d32b9d2550be1';
