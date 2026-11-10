// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 出題版の手がかり写真を取得し、モード選択から結果表示まで参照を保持する。

@ProviderFor(CluePhotoNotifier)
final cluePhotoProvider = CluePhotoNotifierProvider._();

/// 出題版の手がかり写真を取得し、モード選択から結果表示まで参照を保持する。
final class CluePhotoNotifierProvider
    extends $NotifierProvider<CluePhotoNotifier, CluePhotoState> {
  /// 出題版の手がかり写真を取得し、モード選択から結果表示まで参照を保持する。
  CluePhotoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cluePhotoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cluePhotoNotifierHash();

  @$internal
  @override
  CluePhotoNotifier create() => CluePhotoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CluePhotoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CluePhotoState>(value),
    );
  }
}

String _$cluePhotoNotifierHash() => r'0bed706c3a0577fa9c8854581ce0f831018eb689';

/// 出題版の手がかり写真を取得し、モード選択から結果表示まで参照を保持する。

abstract class _$CluePhotoNotifier extends $Notifier<CluePhotoState> {
  CluePhotoState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CluePhotoState, CluePhotoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CluePhotoState, CluePhotoState>,
              CluePhotoState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
