import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/model/map/model.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/map/provider.dart';
import 'package:app/ui/exploration/components/exploration_panels.dart';
import 'package:app/ui/exploration/components/map_pin_widget.dart';

void main() {
  testWidgets('ExplorationMapPanel does not overflow on small landscape screen', (tester) async {
    tester.view.physicalSize = const Size(800, 380);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationMapPanel(onClose: () {}),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExplorationMapPanel does not overflow on small portrait screen', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationMapPanel(onClose: () {}),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExplorationMapPanel does not overflow on extreme small screen (600x300)', (tester) async {
    tester.view.physicalSize = const Size(600, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationMapPanel(onClose: () {}),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExplorationMapPanel displays pins from mapPinsProvider and allows tap', (tester) async {
    final testPin = MapPinData(
      id: 1,
      name: 'テストパビリオン',
      latitude: 34.6508,
      longitude: 135.3837,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapPinsProvider.overrideWithValue([testPin]),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationMapPanel(onClose: () {}),
          ),
        ),
      ),
    );

    // ピンが表示されていることを検証
    expect(find.byType(MapPinWidget), findsOneWidget);
    expect(find.text('テストパビリオン'), findsOneWidget);

    // ピンをタップして詳細カードが表示されることを確認
    await tester.tap(find.byType(MapPinWidget));
    await tester.pumpAndSettle();

    expect(find.text('テストパビリオン'), findsNWidgets(2)); // ピン上とカード上の2箇所
  });

  testWidgets('ExplorationMapPanel extracts lat/lon pins from API challengeProvider landmarks', (tester) async {
    final assetRef = AssetRef(
      url: 'https://example.invalid/map.png',
      sha256: '0' * 64,
      byteLength: 100,
      contentType: 'image/png',
    );

    final apiRevision = ChallengeRevision(
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
            id: 101,
            name: 'Better Co-Being(宮田裕章氏)',
            positionX: 0,
            positionZ: 0,
            latitude: 34.649045,
            longitude: 135.383671,
          ),
          Landmark(
            id: 102,
            name: 'ブラジル館',
            positionX: 5,
            positionZ: -10,
            latitude: 34.648451,
            longitude: 135.384749,
          ),
        ],
      ),
      modes: const [],
      eyeHeightMeters: 1.6,
      shotVerticalFovDegrees: 50.0,
      credits: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeProvider.overrideWith(() => _FakeChallengeNotifier(apiRevision)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ExplorationMapPanel(onClose: () {}),
          ),
        ),
      ),
    );

    // APIから返されたランドマークがピンとして地図に描画されることを検証
    expect(find.text('Better Co-Being(宮田裕章氏)'), findsOneWidget);
    expect(find.text('ブラジル館'), findsOneWidget);
    expect(find.byType(MapPinWidget), findsNWidgets(2));
  });
}

class _FakeChallengeNotifier extends ChallengeNotifier {
  _FakeChallengeNotifier(this._revision);
  final ChallengeRevision _revision;

  @override
  ChallengeState build() {
    return ChallengeState(
      challengeId: 1,
      revision: _revision,
    );
  }
}


