import 'dart:async';
import 'dart:io';

import 'package:app/model/auth/model.dart';
import 'package:app/model/guide/model.dart';
import 'package:app/model/position.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/guide/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scene/scene.dart' show Node, CameraComponent;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:vector_math/vector_math.dart' as vec;

import '../../support/api_client.dart';
import '../../support/play.dart';
import '../../provider/guide/support.dart';

class _Scene extends SceneAdapter {
  @override
  void build() {
    // セッション採用時に同期配置する、GPUを持たない実ノード。
    player = Node(name: 'guide-test-player');
    cameraComponent = CameraComponent();
    player.addComponent(cameraComponent);
  }
}

class _LoadedExploration extends ExplorationViewModel {
  @override
  ExplorationState build() => super.build().copyWith(isLoading: false);
}

class _Auth extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: .signedIn, authUserId: testAuthUserId);
  void changeAccount() =>
      state = AuthState(status: .signedIn, authUserId: otherId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final action in ['end', 'newPlay', 'account']) {
    for (final withAudio in [false, true]) {
      test('実プレイのガイド要求と停止 action=$action audio=$withAudio', () async {
        final directory = await Directory.systemTemp.createTemp('play_guide');
        addTearDown(() => directory.delete(recursive: true));
        final stream = StreamController<NearbyGuideEvent>.broadcast(sync: true);
        addTearDown(stream.close);
        final requests = <ExplainNearbyRequest>[];
        final player = FakeGuidePlayer();
        final client = TestApiClient(
          getProfile: (_) async => throw StateError('呼ばない'),
          setNickname: (_) async => throw StateError('呼ばない'),
          refreshAuthentication: () async {},
          createPlaySession: (r) async => fakePlaySession(mode: r.mode),
          explainNearby: (r) {
            requests.add(r);
            return stream.stream;
          },
        );
        final container = ProviderContainer(
          overrides: [
            apiClientProvider.overrideWithValue(client),
            authProvider.overrideWith(_Auth.new),
            sceneAdapterProvider.overrideWith(_Scene.new),
            explorationViewModelProvider.overrideWith(_LoadedExploration.new),
            guideAudioPlayerFactoryProvider.overrideWithValue(() => player),
            guideTemporaryDirectoryProvider.overrideWithValue(
              () async => directory,
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(explorationViewModelProvider, (_, _) {});
        container.listen(guidePanelViewModelProvider, (_, _) {});
        await container
            .read(playProvider.notifier)
            .createSession(revisionId: 1, mode: .near);
        final exploration = container.read(
          explorationViewModelProvider.notifier,
        );
        exploration.startPlay(mode: .near);
        final controller = container.read(playControllerProvider.notifier);
        controller.applyStartDirection(1.0);
        controller.computeMove(
          current: const Position(x: 37, y: 42),
          cameraForward: vec.Vector3(0, 0, -1),
          cameraUp: vec.Vector3(0, 1, 0),
          deltaSeconds: 0,
        );
        container.read(guidePanelViewModelProvider.notifier).generate();
        await eventually(() => requests.isNotEmpty);
        final request = requests.single;
        expect(request.playSessionId, testPlaySessionId);
        expect(request.positionX, 37);
        expect(request.positionZ, 42);
        expect(request.yawDegrees, closeTo(57.2957795, 0.000001));
        expect(request.locale, 'ja-JP');
        expect(identical(container.read(apiClientProvider), client), isTrue);
        if (withAudio) {
          stream.add(textEvent());
          stream.add(chunk());
          await stream.close();
          await eventually(() => container.read(guideProvider).phase == .ready);
          await container.read(guideProvider.notifier).togglePlayback();
          expect(container.read(guideProvider).phase, GuidePhase.playing);
          final path = player.path;
          if (path == null) throw StateError('Missing audio path');
          expect(await File(path).exists(), isTrue);
        } else {
          expect(stream.hasListener, isTrue);
        }
        switch (action) {
          case 'end':
            exploration.endPlay();
          case 'newPlay':
            await container
                .read(playProvider.notifier)
                .createSession(revisionId: 1, mode: .free);
            exploration.startPlay(mode: .free);
          case 'account':
            final auth = container.read(authProvider.notifier);
            if (auth is _Auth) auth.changeAccount();
        }
        await eventually(() => container.read(guideProvider).phase == .idle);
        await eventually(() => !stream.hasListener);
        if (withAudio) {
          await eventually(() => player.disposed);
          await container.read(guideProvider.notifier).close();
          final path = player.path;
          if (path == null) throw StateError('Missing audio path');
          expect(await File(path).exists(), isFalse);
        } else {
          stream.add(textEvent(text: '遅い旧応答'));
          await Future<void>.delayed(Duration.zero);
          expect(container.read(guideProvider).text, isNull);
        }
        expect(identical(container.read(apiClientProvider), client), isTrue);
        expect(requests, hasLength(1));
      });
    }
  }
}
