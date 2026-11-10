// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExplorationViewModel)
final explorationViewModelProvider = ExplorationViewModelProvider._();

final class ExplorationViewModelProvider
    extends $NotifierProvider<ExplorationViewModel, ExplorationState> {
  ExplorationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorationViewModelHash();

  @$internal
  @override
  ExplorationViewModel create() => ExplorationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExplorationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExplorationState>(value),
    );
  }
}

String _$explorationViewModelHash() =>
    r'c051b305343f6c6b46c3cf5afed66d30f234a16a';

abstract class _$ExplorationViewModel extends $Notifier<ExplorationState> {
  ExplorationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExplorationState, ExplorationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExplorationState, ExplorationState>,
              ExplorationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 解説の表示判断。通信・ネイティブ音声は機能別Providerに委譲する。

@ProviderFor(GuidePanelViewModel)
final guidePanelViewModelProvider = GuidePanelViewModelProvider._();

/// 解説の表示判断。通信・ネイティブ音声は機能別Providerに委譲する。
final class GuidePanelViewModelProvider
    extends $NotifierProvider<GuidePanelViewModel, GuideState> {
  /// 解説の表示判断。通信・ネイティブ音声は機能別Providerに委譲する。
  GuidePanelViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guidePanelViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guidePanelViewModelHash();

  @$internal
  @override
  GuidePanelViewModel create() => GuidePanelViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideState>(value),
    );
  }
}

String _$guidePanelViewModelHash() =>
    r'6707e7bf090b258058a751f526db4e5a70385bce';

/// 解説の表示判断。通信・ネイティブ音声は機能別Providerに委譲する。

abstract class _$GuidePanelViewModel extends $Notifier<GuideState> {
  GuideState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GuideState, GuideState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GuideState, GuideState>,
              GuideState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
