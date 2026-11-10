// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。

@ProviderFor(RankingNotifier)
final rankingProvider = RankingNotifierFamily._();

/// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。
final class RankingNotifierProvider
    extends $NotifierProvider<RankingNotifier, Client> {
  /// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。
  RankingNotifierProvider._({
    required RankingNotifierFamily super.from,
    required (int, PlayMode) super.argument,
  }) : super(
         retry: null,
         name: r'rankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rankingNotifierHash();

  @override
  String toString() {
    return r'rankingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  RankingNotifier create() => RankingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Client>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RankingNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rankingNotifierHash() => r'e90abd7ea82aa6f503ea8cc78a2b006c86c54bad';

/// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。

final class RankingNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          RankingNotifier,
          Client,
          Client,
          Client,
          (int, PlayMode)
        > {
  RankingNotifierFamily._()
    : super(
        retry: null,
        name: r'rankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。

  RankingNotifierProvider call(int revisionId, PlayMode mode) =>
      RankingNotifierProvider._(argument: (revisionId, mode), from: this);

  @override
  String toString() => r'rankingProvider';
}

/// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。

abstract class _$RankingNotifier extends $Notifier<Client> {
  late final _$args = ref.$arg as (int, PlayMode);
  int get revisionId => _$args.$1;
  PlayMode get mode => _$args.$2;

  Client build(int revisionId, PlayMode mode);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Client, Client>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Client, Client>,
              Client,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
