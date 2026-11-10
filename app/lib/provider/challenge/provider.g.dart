// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 公開出題の取得と版の保持を担当する。SDK例外を画面で扱える失敗へ変換する。

@ProviderFor(ChallengeNotifier)
final challengeProvider = ChallengeNotifierProvider._();

/// 公開出題の取得と版の保持を担当する。SDK例外を画面で扱える失敗へ変換する。
final class ChallengeNotifierProvider
    extends $NotifierProvider<ChallengeNotifier, ChallengeState> {
  /// 公開出題の取得と版の保持を担当する。SDK例外を画面で扱える失敗へ変換する。
  ChallengeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeNotifierHash();

  @$internal
  @override
  ChallengeNotifier create() => ChallengeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeState>(value),
    );
  }
}

String _$challengeNotifierHash() => r'b1f6fcf38f7a533a75b39940e77aa97bce4b0511';

/// 公開出題の取得と版の保持を担当する。SDK例外を画面で扱える失敗へ変換する。

abstract class _$ChallengeNotifier extends $Notifier<ChallengeState> {
  ChallengeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChallengeState, ChallengeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChallengeState, ChallengeState>,
              ChallengeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
