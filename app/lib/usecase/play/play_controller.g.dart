// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PlayControllerの確定姿勢と接続済みセッションからガイド要求を組み立てる。

@ProviderFor(guideRequestSnapshot)
final guideRequestSnapshotProvider = GuideRequestSnapshotProvider._();

/// PlayControllerの確定姿勢と接続済みセッションからガイド要求を組み立てる。

final class GuideRequestSnapshotProvider
    extends
        $FunctionalProvider<
          ExplainNearbyRequest Function(),
          ExplainNearbyRequest Function(),
          ExplainNearbyRequest Function()
        >
    with $Provider<ExplainNearbyRequest Function()> {
  /// PlayControllerの確定姿勢と接続済みセッションからガイド要求を組み立てる。
  GuideRequestSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideRequestSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideRequestSnapshotHash();

  @$internal
  @override
  $ProviderElement<ExplainNearbyRequest Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExplainNearbyRequest Function() create(Ref ref) {
    return guideRequestSnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplainNearbyRequest Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplainNearbyRequest Function()>(
        value,
      ),
    );
  }
}

String _$guideRequestSnapshotHash() =>
    r'0e03eaa83528d8a77c2032834eb1ee8fcadd0c43';

@ProviderFor(PlayController)
final playControllerProvider = PlayControllerProvider._();

final class PlayControllerProvider
    extends $NotifierProvider<PlayController, void> {
  PlayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playControllerHash();

  @$internal
  @override
  PlayController create() => PlayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$playControllerHash() => r'a4b5ad0363e0433c0e3de59b86bf773ee89c3242';

abstract class _$PlayController extends $Notifier<void> {
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
