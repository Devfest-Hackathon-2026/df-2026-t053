import 'package:app/model/map/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/pavilion/provider.dart';
import 'package:photohunt_client/photohunt_client.dart' show Client;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// 会場マップ上に表示するピン一覧を提供する。
/// APIクライアント、出題版（ChallengeRevision.map.landmarks）、
/// およびパビリオンマスターと連携する。
@riverpod
List<MapPinData> mapPins(Ref ref) {
  final Client _ = ref.watch(apiClientProvider);
  final challengeState = ref.watch(challengeProvider);
  final pavilionAsync = ref.watch(pavilionProvider);

  final landmarkPins = [
    for (final l in challengeState.revision?.map.landmarks ?? const <Landmark>[])
      if (l.latitude != null && l.longitude != null)
        MapPinData(
          id: l.id,
          name: l.name,
          latitude: l.latitude,
          longitude: l.longitude,
        ),
  ];

  final pavilionPins = switch (pavilionAsync) {
    AsyncData(:final value) => [
        for (final p in value)
          if (p.latitude != null && p.longitude != null)
            MapPinData(
              id: p.id + _pavilionIdOffset,
              sourceKey: p.sourceKey,
              name: p.name,
              latitude: p.latitude,
              longitude: p.longitude,
            ),
      ],
    _ => <MapPinData>[],
  };

  return [...landmarkPins, ...pavilionPins];
}

/// `Landmark.id` と `Pavilion.id` の名前空間が重複しないようにするオフセット。
const int _pavilionIdOffset = 1000000;
