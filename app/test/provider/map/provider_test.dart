import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/map/provider.dart';

void main() {
  final assetRef = AssetRef(
    url: 'https://example.invalid/map.png',
    sha256: '0' * 64,
    byteLength: 100,
    contentType: 'image/png',
  );

  test('challengeProvider の landmarks から緯度経度を持つピンを生成する', () {
    final revision = ChallengeRevision(
      id: 1,
      challengeId: 1,
      sceneProfile: 'expo2025',
      photo: assetRef,
      photoAlt: 'お手本',
      map: VenueMap(
        image: assetRef,
        bounds: MapBounds(minX: -60, minZ: -80, maxX: 60, maxZ: 40),
        landmarks: [
          Landmark(
            id: 1,
            name: '日本館',
            positionX: 0,
            positionZ: 0,
            latitude: 34.648305,
            longitude: 135.387793,
          ),
          Landmark(
            id: 2,
            name: '緯度経度なしランドマーク',
            positionX: 10,
            positionZ: 10,
            latitude: null,
            longitude: null,
          ),
        ],
      ),
      modes: const [],
      eyeHeightMeters: 1.6,
      shotVerticalFovDegrees: 50.0,
      credits: const [],
    );

    final container = ProviderContainer(
      overrides: [
        challengeProvider.overrideWith(() => _FakeChallengeNotifier(revision)),
      ],
    );
    addTearDown(container.dispose);

    final pins = container.read(mapPinsProvider);

    expect(pins.length, 1);
    expect(pins.first.id, 1);
    expect(pins.first.name, '日本館');
    expect(pins.first.uv, isNotNull);
    expect(pins.first.uv!.u, closeTo(0.868, 0.01));
    expect(pins.first.uv!.v, closeTo(0.759, 0.01));
  });

  test('出題版が未取得の場合は空リストを返す', () {
    final container = ProviderContainer(
      overrides: [
        challengeProvider.overrideWith(() => _FakeChallengeNotifier(null)),
      ],
    );
    addTearDown(container.dispose);

    final pins = container.read(mapPinsProvider);
    expect(pins, isEmpty);
  });
}

class _FakeChallengeNotifier extends ChallengeNotifier {
  _FakeChallengeNotifier(this._revision);
  final ChallengeRevision? _revision;

  @override
  ChallengeState build() {
    return ChallengeState(
      challengeId: _revision == null ? null : 1,
      revision: _revision,
    );
  }
}
