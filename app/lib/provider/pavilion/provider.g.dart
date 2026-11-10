// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// パビリオンマスター一覧を API から取得する。

@ProviderFor(PavilionNotifier)
final pavilionProvider = PavilionNotifierProvider._();

/// パビリオンマスター一覧を API から取得する。
final class PavilionNotifierProvider
    extends $AsyncNotifierProvider<PavilionNotifier, List<Pavilion>> {
  /// パビリオンマスター一覧を API から取得する。
  PavilionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pavilionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pavilionNotifierHash();

  @$internal
  @override
  PavilionNotifier create() => PavilionNotifier();
}

String _$pavilionNotifierHash() => r'5992eb7955f113c3ef2098dfb26385ec7f02d6af';

/// パビリオンマスター一覧を API から取得する。

abstract class _$PavilionNotifier extends $AsyncNotifier<List<Pavilion>> {
  FutureOr<List<Pavilion>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Pavilion>>, List<Pavilion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Pavilion>>, List<Pavilion>>,
              AsyncValue<List<Pavilion>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
