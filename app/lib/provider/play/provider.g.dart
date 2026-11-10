// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 保留中の撮影の保存先。テストでは一時フォルダへ差し替える。

@ProviderFor(playSupportDirectory)
final playSupportDirectoryProvider = PlaySupportDirectoryProvider._();

/// 保留中の撮影の保存先。テストでは一時フォルダへ差し替える。

final class PlaySupportDirectoryProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  /// 保留中の撮影の保存先。テストでは一時フォルダへ差し替える。
  PlaySupportDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playSupportDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playSupportDirectoryHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return playSupportDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$playSupportDirectoryHash() =>
    r'0333cc27c121ec49275254597e1dd8894d8f7173';

/// プレイの開始・撮影・結果照会と、保留中の撮影の端末記録を担当する。
/// SDK例外を画面で扱える失敗へ変換する。

@ProviderFor(PlayNotifier)
final playProvider = PlayNotifierProvider._();

/// プレイの開始・撮影・結果照会と、保留中の撮影の端末記録を担当する。
/// SDK例外を画面で扱える失敗へ変換する。
final class PlayNotifierProvider
    extends $NotifierProvider<PlayNotifier, PlayState> {
  /// プレイの開始・撮影・結果照会と、保留中の撮影の端末記録を担当する。
  /// SDK例外を画面で扱える失敗へ変換する。
  PlayNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playNotifierHash();

  @$internal
  @override
  PlayNotifier create() => PlayNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayState>(value),
    );
  }
}

String _$playNotifierHash() => r'203c8bc38044b9ad62992042d77e76e492ca3271';

/// プレイの開始・撮影・結果照会と、保留中の撮影の端末記録を担当する。
/// SDK例外を画面で扱える失敗へ変換する。

abstract class _$PlayNotifier extends $Notifier<PlayState> {
  PlayState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlayState, PlayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayState, PlayState>,
              PlayState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
