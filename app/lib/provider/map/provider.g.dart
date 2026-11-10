// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 会場マップ上に表示するピン一覧を提供する。
/// APIクライアント、出題版（ChallengeRevision.map.landmarks）、
/// およびパビリオンマスターと連携する。

@ProviderFor(mapPins)
final mapPinsProvider = MapPinsProvider._();

/// 会場マップ上に表示するピン一覧を提供する。
/// APIクライアント、出題版（ChallengeRevision.map.landmarks）、
/// およびパビリオンマスターと連携する。

final class MapPinsProvider
    extends
        $FunctionalProvider<
          List<MapPinData>,
          List<MapPinData>,
          List<MapPinData>
        >
    with $Provider<List<MapPinData>> {
  /// 会場マップ上に表示するピン一覧を提供する。
  /// APIクライアント、出題版（ChallengeRevision.map.landmarks）、
  /// およびパビリオンマスターと連携する。
  MapPinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapPinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapPinsHash();

  @$internal
  @override
  $ProviderElement<List<MapPinData>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<MapPinData> create(Ref ref) {
    return mapPins(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MapPinData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MapPinData>>(value),
    );
  }
}

String _$mapPinsHash() => r'5eaef6994c552f2b68dabca257250ebebf5c7418';
