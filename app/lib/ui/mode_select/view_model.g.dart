// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ModeSelectViewModel)
final modeSelectViewModelProvider = ModeSelectViewModelProvider._();

final class ModeSelectViewModelProvider
    extends $NotifierProvider<ModeSelectViewModel, ModeSelectState> {
  ModeSelectViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modeSelectViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modeSelectViewModelHash();

  @$internal
  @override
  ModeSelectViewModel create() => ModeSelectViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModeSelectState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModeSelectState>(value),
    );
  }
}

String _$modeSelectViewModelHash() =>
    r'd0b1746769c6029379f1b9b3a0cb9034a96f723c';

abstract class _$ModeSelectViewModel extends $Notifier<ModeSelectState> {
  ModeSelectState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ModeSelectState, ModeSelectState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModeSelectState, ModeSelectState>,
              ModeSelectState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。

@ProviderFor(ModeRecordViewModel)
final modeRecordViewModelProvider = ModeRecordViewModelFamily._();

/// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。
final class ModeRecordViewModelProvider
    extends $AsyncNotifierProvider<ModeRecordViewModel, String> {
  /// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。
  ModeRecordViewModelProvider._({
    required ModeRecordViewModelFamily super.from,
    required PlayMode super.argument,
  }) : super(
         retry: _noRecordRetry,
         name: r'modeRecordViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$modeRecordViewModelHash();

  @override
  String toString() {
    return r'modeRecordViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ModeRecordViewModel create() => ModeRecordViewModel();

  @override
  bool operator ==(Object other) {
    return other is ModeRecordViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$modeRecordViewModelHash() =>
    r'aaa8462f7458247b42d89e2a8cc484f855550ced';

/// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。

final class ModeRecordViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ModeRecordViewModel,
          AsyncValue<String>,
          String,
          FutureOr<String>,
          PlayMode
        > {
  ModeRecordViewModelFamily._()
    : super(
        retry: _noRecordRetry,
        name: r'modeRecordViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。

  ModeRecordViewModelProvider call(PlayMode mode) =>
      ModeRecordViewModelProvider._(argument: mode, from: this);

  @override
  String toString() => r'modeRecordViewModelProvider';
}

/// モードカードの自己記録。初回・出題/本人変更・撮影結果更新・手動更新で取得する。

abstract class _$ModeRecordViewModel extends $AsyncNotifier<String> {
  late final _$args = ref.$arg as PlayMode;
  PlayMode get mode => _$args;

  FutureOr<String> build(PlayMode mode);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
