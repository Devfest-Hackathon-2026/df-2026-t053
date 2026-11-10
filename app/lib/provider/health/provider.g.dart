// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 認証不要の疎通確認。業務APIの準備完了を保証するものではない。

@ProviderFor(HealthNotifier)
final healthProvider = HealthNotifierProvider._();

/// 認証不要の疎通確認。業務APIの準備完了を保証するものではない。
final class HealthNotifierProvider
    extends $NotifierProvider<HealthNotifier, void> {
  /// 認証不要の疎通確認。業務APIの準備完了を保証するものではない。
  HealthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthNotifierHash();

  @$internal
  @override
  HealthNotifier create() => HealthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$healthNotifierHash() => r'b01f4b56dc2e6f71216e1d626eb71865ece4a2ca';

/// 認証不要の疎通確認。業務APIの準備完了を保証するものではない。

abstract class _$HealthNotifier extends $Notifier<void> {
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
