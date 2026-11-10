// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_projection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MapProjectionUseCase)
final mapProjectionUseCaseProvider = MapProjectionUseCaseProvider._();

final class MapProjectionUseCaseProvider
    extends $NotifierProvider<MapProjectionUseCase, void> {
  MapProjectionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapProjectionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapProjectionUseCaseHash();

  @$internal
  @override
  MapProjectionUseCase create() => MapProjectionUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$mapProjectionUseCaseHash() =>
    r'991af3ace769ff9c360f2cc88a87ef59ce781748';

abstract class _$MapProjectionUseCase extends $Notifier<void> {
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
