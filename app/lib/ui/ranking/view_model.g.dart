// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RankingViewModel)
final rankingViewModelProvider = RankingViewModelFamily._();

final class RankingViewModelProvider
    extends $NotifierProvider<RankingViewModel, RankingState> {
  RankingViewModelProvider._({
    required RankingViewModelFamily super.from,
    required ({int? revisionId, ExplorationMode initialMode}) super.argument,
  }) : super(
         retry: null,
         name: r'rankingViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rankingViewModelHash();

  @override
  String toString() {
    return r'rankingViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  RankingViewModel create() => RankingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RankingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RankingState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RankingViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rankingViewModelHash() => r'18ebff28e8ae6faa34af3f4c3b38d71cc9ee6c10';

final class RankingViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RankingViewModel,
          RankingState,
          RankingState,
          RankingState,
          ({int? revisionId, ExplorationMode initialMode})
        > {
  RankingViewModelFamily._()
    : super(
        retry: null,
        name: r'rankingViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RankingViewModelProvider call({
    int? revisionId,
    ExplorationMode initialMode = ExplorationMode.free,
  }) => RankingViewModelProvider._(
    argument: (revisionId: revisionId, initialMode: initialMode),
    from: this,
  );

  @override
  String toString() => r'rankingViewModelProvider';
}

abstract class _$RankingViewModel extends $Notifier<RankingState> {
  late final _$args =
      ref.$arg as ({int? revisionId, ExplorationMode initialMode});
  int? get revisionId => _$args.revisionId;
  ExplorationMode get initialMode => _$args.initialMode;

  RankingState build({
    int? revisionId,
    ExplorationMode initialMode = ExplorationMode.free,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RankingState, RankingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RankingState, RankingState>,
              RankingState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () =>
          build(revisionId: _$args.revisionId, initialMode: _$args.initialMode),
    );
  }
}
