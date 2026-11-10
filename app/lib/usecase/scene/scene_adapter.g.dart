// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SceneAdapter)
final sceneAdapterProvider = SceneAdapterProvider._();

final class SceneAdapterProvider extends $NotifierProvider<SceneAdapter, void> {
  SceneAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sceneAdapterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sceneAdapterHash();

  @$internal
  @override
  SceneAdapter create() => SceneAdapter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sceneAdapterHash() => r'557b9266be50b105c3a69b735d8e0f893b67aa24';

abstract class _$SceneAdapter extends $Notifier<void> {
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
