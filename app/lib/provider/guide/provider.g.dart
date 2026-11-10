// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 認証の接続側と同じ生成Clientを使う。購読のcancel／正常終了により、
/// Serverpod SDKが他のstreamの有無を確認して不要な接続だけを閉じる。
/// closeStreamingMethodConnectionsは他の購読まで終了するため呼ばない。

@ProviderFor(guideApiClient)
final guideApiClientProvider = GuideApiClientProvider._();

/// 認証の接続側と同じ生成Clientを使う。購読のcancel／正常終了により、
/// Serverpod SDKが他のstreamの有無を確認して不要な接続だけを閉じる。
/// closeStreamingMethodConnectionsは他の購読まで終了するため呼ばない。

final class GuideApiClientProvider
    extends $FunctionalProvider<GuideApiClient, GuideApiClient, GuideApiClient>
    with $Provider<GuideApiClient> {
  /// 認証の接続側と同じ生成Clientを使う。購読のcancel／正常終了により、
  /// Serverpod SDKが他のstreamの有無を確認して不要な接続だけを閉じる。
  /// closeStreamingMethodConnectionsは他の購読まで終了するため呼ばない。
  GuideApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideApiClientHash();

  @$internal
  @override
  $ProviderElement<GuideApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GuideApiClient create(Ref ref) {
    return guideApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideApiClient>(value),
    );
  }
}

String _$guideApiClientHash() => r'1a32bca42254e676565e53c63f2cf9f124b8d9e0';

@ProviderFor(guideAudioPlayerFactory)
final guideAudioPlayerFactoryProvider = GuideAudioPlayerFactoryProvider._();

final class GuideAudioPlayerFactoryProvider
    extends
        $FunctionalProvider<
          AudioPlayer Function(),
          AudioPlayer Function(),
          AudioPlayer Function()
        >
    with $Provider<AudioPlayer Function()> {
  GuideAudioPlayerFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideAudioPlayerFactoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideAudioPlayerFactoryHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioPlayer Function() create(Ref ref) {
    return guideAudioPlayerFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayer Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer Function()>(value),
    );
  }
}

String _$guideAudioPlayerFactoryHash() =>
    r'38f196d75ed1e9240e50de0baf7b0e4b293def2e';

@ProviderFor(guideTemporaryDirectory)
final guideTemporaryDirectoryProvider = GuideTemporaryDirectoryProvider._();

final class GuideTemporaryDirectoryProvider
    extends
        $FunctionalProvider<
          Future<Directory> Function(),
          Future<Directory> Function(),
          Future<Directory> Function()
        >
    with $Provider<Future<Directory> Function()> {
  GuideTemporaryDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideTemporaryDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideTemporaryDirectoryHash();

  @$internal
  @override
  $ProviderElement<Future<Directory> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Directory> Function() create(Ref ref) {
    return guideTemporaryDirectory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Directory> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<Directory> Function()>(value),
    );
  }
}

String _$guideTemporaryDirectoryHash() =>
    r'2ad8f3b7af7987cb9807c413231484e01da45985';

@ProviderFor(guideDeadline)
final guideDeadlineProvider = GuideDeadlineProvider._();

final class GuideDeadlineProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  GuideDeadlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideDeadlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideDeadlineHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return guideDeadline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$guideDeadlineHash() => r'c30b06bb811b158aa3313229e49504c038d49cca';

/// 通信・検証・一時音声の寿命を担当。表示文言は探索ViewModelで決める。

@ProviderFor(GuideNotifier)
final guideProvider = GuideNotifierProvider._();

/// 通信・検証・一時音声の寿命を担当。表示文言は探索ViewModelで決める。
final class GuideNotifierProvider
    extends $NotifierProvider<GuideNotifier, GuideState> {
  /// 通信・検証・一時音声の寿命を担当。表示文言は探索ViewModelで決める。
  GuideNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideNotifierHash();

  @$internal
  @override
  GuideNotifier create() => GuideNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideState>(value),
    );
  }
}

String _$guideNotifierHash() => r'2ef13974796009bd45644aefa6cbffe704b7546b';

/// 通信・検証・一時音声の寿命を担当。表示文言は探索ViewModelで決める。

abstract class _$GuideNotifier extends $Notifier<GuideState> {
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
