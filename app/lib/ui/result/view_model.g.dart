// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ResultViewModel)
final resultViewModelProvider = ResultViewModelFamily._();

final class ResultViewModelProvider
    extends $NotifierProvider<ResultViewModel, ResultState> {
  ResultViewModelProvider._({
    required ResultViewModelFamily super.from,
    required (ExplorationMode, SubmitShotResponse) super.argument,
  }) : super(
         retry: null,
         name: r'resultViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resultViewModelHash();

  @override
  String toString() {
    return r'resultViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ResultViewModel create() => ResultViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResultState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResultState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ResultViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resultViewModelHash() => r'de3b58fc55e222d28bbeed11f02db469c9a8d8b5';

final class ResultViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ResultViewModel,
          ResultState,
          ResultState,
          ResultState,
          (ExplorationMode, SubmitShotResponse)
        > {
  ResultViewModelFamily._()
    : super(
        retry: null,
        name: r'resultViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResultViewModelProvider call(
    ExplorationMode mode,
    SubmitShotResponse result,
  ) => ResultViewModelProvider._(argument: (mode, result), from: this);

  @override
  String toString() => r'resultViewModelProvider';
}

abstract class _$ResultViewModel extends $Notifier<ResultState> {
  late final _$args = ref.$arg as (ExplorationMode, SubmitShotResponse);
  ExplorationMode get mode => _$args.$1;
  SubmitShotResponse get result => _$args.$2;

  ResultState build(ExplorationMode mode, SubmitShotResponse result);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ResultState, ResultState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ResultState, ResultState>,
              ResultState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(ResultComparisonViewModel)
final resultComparisonViewModelProvider = ResultComparisonViewModelFamily._();

final class ResultComparisonViewModelProvider
    extends
        $AsyncNotifierProvider<
          ResultComparisonViewModel,
          ResultComparisonImages
        > {
  ResultComparisonViewModelProvider._({
    required ResultComparisonViewModelFamily super.from,
    required (SubmitShotResponse, int, int) super.argument,
  }) : super(
         retry: _noComparisonRetry,
         name: r'resultComparisonViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resultComparisonViewModelHash();

  @override
  String toString() {
    return r'resultComparisonViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ResultComparisonViewModel create() => ResultComparisonViewModel();

  @override
  bool operator ==(Object other) {
    return other is ResultComparisonViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resultComparisonViewModelHash() =>
    r'a5b13b7f0da7a8ceb842262803fe369ebfb81c4a';

final class ResultComparisonViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ResultComparisonViewModel,
          AsyncValue<ResultComparisonImages>,
          ResultComparisonImages,
          FutureOr<ResultComparisonImages>,
          (SubmitShotResponse, int, int)
        > {
  ResultComparisonViewModelFamily._()
    : super(
        retry: _noComparisonRetry,
        name: r'resultComparisonViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResultComparisonViewModelProvider call(
    SubmitShotResponse result,
    int width,
    int height,
  ) => ResultComparisonViewModelProvider._(
    argument: (result, width, height),
    from: this,
  );

  @override
  String toString() => r'resultComparisonViewModelProvider';
}

abstract class _$ResultComparisonViewModel
    extends $AsyncNotifier<ResultComparisonImages> {
  late final _$args = ref.$arg as (SubmitShotResponse, int, int);
  SubmitShotResponse get result => _$args.$1;
  int get width => _$args.$2;
  int get height => _$args.$3;

  FutureOr<ResultComparisonImages> build(
    SubmitShotResponse result,
    int width,
    int height,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ResultComparisonImages>, ResultComparisonImages>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ResultComparisonImages>,
                ResultComparisonImages
              >,
              AsyncValue<ResultComparisonImages>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}
