import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/assets/model.dart';
import 'package:app/model/play/model.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/model/position.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/ui/ranking/view_model.dart';
import 'package:app/ui/result/view_model.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:vector_math/vector_math.dart' as vec;
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/assets/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_scene/scene.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import '../../support/api_client.dart';
import '../../support/clue_photo_server.dart';
import '../../support/play.dart';

/// セッション管理のテストダブル。保存済みセッションはない状態から始める。
class _FakeSessionManager extends Fake implements FlutterAuthSessionManager {
  AuthSuccess? _authInfo;

  @override
  AuthSuccess? get authInfo => _authInfo;

  @override
  bool get isAuthenticated => _authInfo != null;

  @override
  Future<bool> initialize({
    Duration timeout = const Duration(seconds: 2),
  }) async => _authInfo != null;

  @override
  Future<void> updateSignedInUser(AuthSuccess? authInfo) async {
    _authInfo = authInfo;
  }
}

/// モデルの読み込みだけを省いたSceneAdapter。
class _FakeSceneAdapter extends SceneAdapter {
  @override
  void build() {
    loading = ResourceGroup();
  }

  @override
  Future<double> loadModel({Future<({double x, double z})>? startAt}) async {
    // 開始点（セッション作成）の失敗は、実装と同じく呼び出し元へ返す。
    await startAt;
    return 0;
  }

  @override
  void setStartPosition(double x, double z, {double? y}) {}
  @override
  void setPlayerRotation(vec.Matrix3 rotation) {}
}

class _LoadedExploration extends ExplorationViewModel {
  @override
  ExplorationState build() => super.build().copyWith(isLoading: false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<ProviderContainer> setUpContainer({
    required TestApiClient client,
    required Directory tempDir,
    AssetCacheSettings? assets,
    SecurityContext? trust,
  }) async {
    if (trust != null) {
      final previous = HttpOverrides.current;
      HttpOverrides.global = LocalhostTrust(trust);
      addTearDown(() => HttpOverrides.global = previous);
    }
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        authSessionManagerProvider.overrideWithValue(_FakeSessionManager()),
        sceneAdapterProvider.overrideWith(_FakeSceneAdapter.new),
        explorationViewModelProvider.overrideWith(_LoadedExploration.new),
        playSupportDirectoryProvider.overrideWithValue(() async => tempDir),
        assetCacheDirectoryProvider.overrideWith((ref) async => tempDir),
        if (assets != null)
          assetCacheSettingsProvider.overrideWith((ref) => assets),
      ],
    );
    addTearDown(container.dispose);
    container.listen(modeSelectViewModelProvider, (_, _) {});
    return container;
  }

  Future<void> waitBoot(ProviderContainer container) async {
    for (var i = 0; i < 200; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (container.read(modeSelectViewModelProvider).boot != .booting) return;
    }
    fail('起動準備が完了しませんでした');
  }

  final eastGate = SpawnEntrance(id: 1, label: '東ゲート');

  /// 入口選択のあと、準備中が終わるまで待つ。
  Future<void> waitAfterEntrance(ProviderContainer container) async {
    container
        .read(modeSelectViewModelProvider.notifier)
        .chooseEntrance(
          container.read(modeSelectViewModelProvider).entrances.single,
        );
    for (var i = 0; i < 200; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final flow = container.read(modeSelectViewModelProvider).flow;
      if (flow != .chooseSpot && flow != .preparing) return;
    }
    fail('入口選択後の開始が完了しませんでした');
  }

  Future<({ServedCluePhoto served, AssetRef photo})> hostPhoto() async {
    final served = await serveCluePhoto();
    addTearDown(served.close);
    final photo = served.add(await solidPng(const ui.Color(0xff224466)));
    return (served: served, photo: photo);
  }

  test('起動で認証・プロフィール・出題を取得し、開始でセッションを作る', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final hosted = await hostPhoto();
    final createRequests = <CreatePlaySessionRequest>[];
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async => Profile(nickname: '旅人1234', anonymous: true),
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async =>
          fakeRevision(photo: hosted.photo, entrances: [eastGate]),
      createPlaySession: (request) async {
        createRequests.add(request);
        return fakePlaySession(mode: request.mode);
      },
    );
    final container = await setUpContainer(
      client: client,
      tempDir: tempDir,
      assets: hosted.served.settings,
      trust: hosted.served.trust,
    );
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    expect(
      container.read(modeSelectViewModelProvider).boot,
      ModeSelectBoot.ready,
    );
    expect(container.read(modeSelectViewModelProvider).nickname, '旅人1234');
    expect(container.read(challengeProvider).revision?.id, 1);

    await vm.startPlay(.near);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.done,
    );
    expect(createRequests, hasLength(1));
    expect(createRequests.single.spawnPointId, isNull);

    await vm.startPlay(.free);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.chooseSpot,
    );
    expect(createRequests, hasLength(1));
    await waitAfterEntrance(container);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.done,
    );
    expect(createRequests, hasLength(2));
    expect(createRequests.last.revisionId, 1);
    expect(createRequests.last.mode, PlayMode.free);
    expect(createRequests.last.spawnPointId, eastGate.id);
    expect(container.read(playProvider).phase, PlayPhase.active);
  });

  test('入口パネルを閉じても進行中のセッションは残る', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final hosted = await hostPhoto();
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async => Profile(nickname: '旅人1234', anonymous: true),
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async =>
          fakeRevision(photo: hosted.photo, entrances: [eastGate]),
      createPlaySession: (request) async => fakePlaySession(mode: request.mode),
    );
    final container = await setUpContainer(
      client: client,
      tempDir: tempDir,
      assets: hosted.served.settings,
      trust: hosted.served.trust,
    );
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    await vm.startPlay(.near);
    final kept = container.read(playProvider).session;
    if (kept == null) fail('セッションがありません');
    await vm.startPlay(.free);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.chooseSpot,
    );
    vm.closeEntranceChoice();
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.none,
    );
    expect(container.read(playProvider).session?.id, kept.id);
    expect(container.read(playProvider).phase, PlayPhase.active);
  });

  test('自由探索で入口がなければセッションを作らない', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final createRequests = <CreatePlaySessionRequest>[];
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async => Profile(nickname: '旅人1234', anonymous: true),
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async => fakeRevision(),
      createPlaySession: (request) async {
        createRequests.add(request);
        return fakePlaySession(mode: request.mode);
      },
    );
    final container = await setUpContainer(client: client, tempDir: tempDir);
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    await vm.startPlay(.free);
    final state = container.read(modeSelectViewModelProvider);
    expect(state.flow, ModeSelectFlow.none);
    expect(state.notice, '入口を確認できませんでした。');
    expect(createRequests, isEmpty);
  });

  test('写真を確認できないときはセッションを作らず探索へ進まない', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final createRequests = <CreatePlaySessionRequest>[];
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async => Profile(nickname: '旅人1234', anonymous: true),
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async => fakeRevision(entrances: [eastGate]),
      createPlaySession: (request) async {
        createRequests.add(request);
        return fakePlaySession(mode: request.mode);
      },
    );
    final container = await setUpContainer(client: client, tempDir: tempDir);
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    await vm.startPlay(.free);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.chooseSpot,
    );
    await waitAfterEntrance(container);
    final state = container.read(modeSelectViewModelProvider);
    expect(state.flow, ModeSelectFlow.none);
    expect(state.notice, '写真を確認できませんでした。');
    expect(createRequests, isEmpty);
    expect(container.read(playProvider).session, isNull);
  });

  test('起動失敗でfailedになり、再試行でreadyになる', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    var profileFails = true;
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async {
        if (profileFails) {
          throw const SocketException('切断');
        }
        return Profile(nickname: '旅人1234', anonymous: true);
      },
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async => fakeRevision(),
    );
    final container = await setUpContainer(client: client, tempDir: tempDir);
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    expect(
      container.read(modeSelectViewModelProvider).boot,
      ModeSelectBoot.failed,
    );

    profileFails = false;
    vm.retryBoot();
    await waitBoot(container);
    expect(
      container.read(modeSelectViewModelProvider).boot,
      ModeSelectBoot.ready,
    );
  });

  test('開始時に版が更新されていたら最新版を取り直して選択へ戻る', () async {
    final tempDir = await Directory.systemTemp.createTemp('mode_select_test');
    addTearDown(() => tempDir.delete(recursive: true));
    final hosted = await hostPhoto();
    var revisionCalls = 0;
    final client = TestApiClient(
      ping: (_) async =>
          HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
      getProfile: (_) async => Profile(nickname: '旅人1234', anonymous: true),
      setNickname: (_) async => throw StateError('未設定'),
      refreshAuthentication: () async {},
      login: () async => AuthSuccess(
        authStrategy: 'jwt',
        token: 'test-token',
        authUserId: testAuthUserId,
        scopeNames: const {},
      ),
      listChallenges: (_) async => ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '万博', currentRevisionId: 1)],
      ),
      getChallenge: (_) async =>
          Challenge(id: 1, title: '万博', currentRevisionId: 1),
      getChallengeRevision: (_) async {
        revisionCalls++;
        return fakeRevision(photo: hosted.photo, entrances: [eastGate]);
      },
      createPlaySession: (_) async => throw ApiException(
        code: .failedPrecondition,
        reason: 'REVISION_NOT_PLAYABLE',
        message: '版が開始できません',
      ),
    );
    final container = await setUpContainer(
      client: client,
      tempDir: tempDir,
      assets: hosted.served.settings,
      trust: hosted.served.trust,
    );
    final vm = container.read(modeSelectViewModelProvider.notifier);
    container.read(modeSelectViewModelProvider);
    await waitBoot(container);
    expect(
      container.read(modeSelectViewModelProvider).boot,
      ModeSelectBoot.ready,
    );
    expect(revisionCalls, 1);

    await vm.startPlay(.free);
    expect(
      container.read(modeSelectViewModelProvider).flow,
      ModeSelectFlow.chooseSpot,
    );
    await waitAfterEntrance(container);
    await waitBoot(container);
    final state = container.read(modeSelectViewModelProvider);
    expect(state.flow, ModeSelectFlow.none);
    expect(state.notice, contains('出題が更新されました'));
    expect(revisionCalls, 2);
  });
  test('health失敗を認証失敗と分け、APIへ届くまでログインしない', () async {
    final tempDir = await Directory.systemTemp.createTemp('health_boot_test');
    addTearDown(() => tempDir.delete(recursive: true));
    var healthy = false;
    var logins = 0;
    final client = TestApiClient(
      ping: (_) async {
        if (!healthy) throw const SocketException('切断');
        return HealthResponse(releaseId: 'test', time: DateTime.utc(2026));
      },
      login: () async {
        logins++;
        return AuthSuccess(
          authStrategy: 'jwt',
          token: 'test',
          authUserId: testAuthUserId,
          scopeNames: {},
        );
      },
      getProfile: (_) async => Profile(nickname: '旅人', anonymous: true),
      setNickname: (_) async => throw StateError('呼ばない'),
      refreshAuthentication: () async {},
      listChallenges: (_) async => ListChallengesResponse(challenges: []),
    );
    final container = await setUpContainer(client: client, tempDir: tempDir);
    await waitBoot(container);
    expect(
      container.read(modeSelectViewModelProvider).notice,
      contains('APIに届きません'),
    );
    expect(logins, 0);
    healthy = true;
    container.read(modeSelectViewModelProvider.notifier).retryBoot();
    await waitBoot(container);
    expect(logins, 1);
    expect(container.read(modeSelectViewModelProvider).notice, '公開中の出題がありません。');
    await container.read(modeSelectViewModelProvider.notifier).startPlay(.free);
    expect(container.read(playProvider).session, isNull);
  });
  for (final mode in ExplorationMode.values) {
    test('起動→開始→撮影→結果→最新ランキング→再挑戦→終了 $mode', () async {
      final directory = await Directory.systemTemp.createTemp('play_flow');
      addTearDown(() => directory.delete(recursive: true));
      final hosted = await hostPhoto();
      final starts = <CreatePlaySessionRequest>[];
      final rankingRequests = <ListRankingEntriesRequest>[];
      final client = TestApiClient(
        ping: (_) async =>
            HealthResponse(releaseId: 'test', time: DateTime.utc(2026)),
        login: () async => AuthSuccess(
          authStrategy: 'jwt',
          token: 'test',
          authUserId: testAuthUserId,
          scopeNames: {},
        ),
        getProfile: (_) async => Profile(nickname: '旅人', anonymous: true),
        setNickname: (_) async => throw StateError('呼ばない'),
        refreshAuthentication: () async {},
        listChallenges: (_) async => ListChallengesResponse(
          challenges: [Challenge(id: 1, title: '出題', currentRevisionId: 1)],
        ),
        getChallenge: (_) async =>
            Challenge(id: 1, title: '出題', currentRevisionId: 1),
        getChallengeRevision: (_) async =>
            fakeRevision(photo: hosted.photo, entrances: [eastGate]),
        createPlaySession: (r) async {
          starts.add(r);
          return fakePlaySession(mode: r.mode)
              .copyWith(spawnPointId: r.spawnPointId ?? 1);
        },
        submitShot: (_) async => fakeSubmitShotResponse(),
        listRanking: (r) async {
          rankingRequests.add(r);
          return ListRankingEntriesResponse(
            entries: [fakeRankingEntry().copyWith(rank: 7, nickname: '変更後の名前')],
          );
        },
        myRanking: (_) async =>
            fakeRankingEntry().copyWith(rank: 7, nickname: '変更後の名前'),
      );
      final container = await setUpContainer(
        client: client,
        tempDir: directory,
        assets: hosted.served.settings,
        trust: hosted.served.trust,
      );
      await waitBoot(container);
      expect(
        container.read(modeSelectViewModelProvider).boot,
        ModeSelectBoot.ready,
      );
      final select = container.read(modeSelectViewModelProvider.notifier);
      await select.startPlay(mode);
      if (mode == .free) {
        expect(
          container.read(modeSelectViewModelProvider).flow,
          ModeSelectFlow.chooseSpot,
        );
        await waitAfterEntrance(container);
      }
      expect(
        container.read(modeSelectViewModelProvider).flow,
        ModeSelectFlow.done,
      );
      container.listen(explorationViewModelProvider, (_, _) {});
      final exploration = container.read(explorationViewModelProvider.notifier);
      exploration.startPlay(mode: mode);
      container
          .read(playControllerProvider.notifier)
          .computeMove(
            current: const Position(x: 100, y: 50),
            cameraForward: vec.Vector3(0, 0, -1),
            cameraUp: vec.Vector3(0, 1, 0),
            deltaSeconds: 0,
          );
      await exploration.submitShot();
      final completed = container.read(explorationViewModelProvider);
      final result = completed.result;
      final session = completed.session;
      if (result == null || session == null) {
        throw StateError('結果またはセッションがありません');
      }
      expect(completed.showResult, isTrue);
      expect(container.read(resultViewModelProvider(mode, result)).score, 500);
      final ranking = rankingViewModelProvider(
        revisionId: session.revisionId,
        initialMode: mode,
      );
      container.listen(ranking, (_, _) {});
      for (var i = 0; i < 100 && container.read(ranking).isLoading; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      expect(container.read(ranking).myEntry?.rank, 7);
      expect(rankingRequests.single.revisionId, session.revisionId);
      expect(rankingRequests.single.mode, session.mode);
      expect(result.myRankingEntry.rank, 2);
      expect(container.read(resultViewModelProvider(mode, result)).rank, 2);
      await exploration.retryPlay();
      expect(starts, hasLength(2));
      expect(starts[0].requestId, isNot(starts[1].requestId));
      if (mode == .free) {
        expect(starts[0].spawnPointId, eastGate.id);
        expect(starts[1].spawnPointId, eastGate.id);
      } else {
        expect(starts[0].spawnPointId, isNull);
        expect(starts[1].spawnPointId, isNull);
      }
      expect(container.read(explorationViewModelProvider).showResult, isFalse);
      exploration.endPlay();
      expect(container.read(playProvider).phase, PlayPhase.idle);
      expect(container.read(explorationViewModelProvider).result, isNull);
    });
  }
}
