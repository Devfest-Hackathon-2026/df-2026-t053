import 'dart:async';
import 'dart:io';

import 'package:app/model/auth/model.dart';
import 'package:app/model/play/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/provider/play/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_client/serverpod_client.dart';

import '../../support/api_client.dart';
import '../../support/play.dart';

class SignedInAuthNotifier extends AuthNotifier {
  SignedInAuthNotifier(this.userId);

  final UuidValue userId;

  @override
  AuthState build() => AuthState(status: .signedIn, authUserId: userId);

  void signOut() => state = const AuthState(status: .failed);
}

class PlayHarness {
  PlayHarness(this.container, this.tempDir);

  final ProviderContainer container;
  final Directory tempDir;
  final createRequests = <CreatePlaySessionRequest>[];
  final submitRequests = <SubmitShotRequest>[];
  final getRequests = <GetPlaySessionRequest>[];

  Future<Directory> Function()? directory;
  Future<PlaySession> Function(CreatePlaySessionRequest)? onCreate;
  Future<SubmitShotResponse> Function(SubmitShotRequest)? onSubmit;
  Future<PlaySession> Function(GetPlaySessionRequest)? onGet;

  PlayNotifier get notifier => container.read(playProvider.notifier);
  PlayState get state => container.read(playProvider);

  File get pendingFile => File('${tempDir.path}/play/pending_shot.json');

  Future<PlaySession> create({int? spawnPointId}) => notifier.createSession(
    revisionId: 1,
    mode: .free,
    spawnPointId: spawnPointId,
  );
}

Future<PlayHarness> setUpHarness({
  UuidValue? authUserId,
  Directory? existingDirectory,
}) async {
  final tempDir =
      existingDirectory ??
      await Directory.systemTemp.createTemp('play_provider_test');
  if (existingDirectory == null) {
    addTearDown(() => tempDir.delete(recursive: true));
  }
  late PlayHarness harness;
  final client = TestApiClient(
    getProfile: (_) async => throw StateError('未設定'),
    setNickname: (_) async => throw StateError('未設定'),
    refreshAuthentication: () async {},
    createPlaySession: (request) {
      harness.createRequests.add(request);
      final handler = harness.onCreate;
      return handler != null
          ? handler(request)
          : Future.value(fakePlaySession());
    },
    submitShot: (request) {
      harness.submitRequests.add(request);
      final handler = harness.onSubmit;
      return handler != null
          ? handler(request)
          : Future.value(fakeSubmitShotResponse());
    },
    getPlaySession: (request) {
      harness.getRequests.add(request);
      final handler = harness.onGet;
      return handler != null
          ? handler(request)
          : Future.value(fakePlaySession());
    },
  );
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(client),
      authProvider.overrideWith(
        () => SignedInAuthNotifier(authUserId ?? testAuthUserId),
      ),
      playSupportDirectoryProvider.overrideWithValue(
        () => harness.directory?.call() ?? Future.value(tempDir),
      ),
    ],
  );
  addTearDown(container.dispose);
  harness = PlayHarness(container, tempDir);
  return harness;
}

ApiException apiError(ApiErrorCode code, String reason) =>
    ApiException(code: code, reason: reason, message: 'テスト用エラー');

ShotInput shotInput() =>
    ShotInput(positionX: 100, positionZ: 50, yawDegrees: 90, pitchDegrees: 0);

void main() {
  test('開始の連打は1回の作成へ合流し、成功後の再開は新しいrequestIdを使う', () async {
    final harness = await setUpHarness();
    final completer = Completer<PlaySession>();
    harness.onCreate = (_) => completer.future;
    final first = harness.create();
    final second = harness.create();
    completer.complete(fakePlaySession());
    final sessions = await Future.wait([first, second]);
    expect(sessions[0].id, testPlaySessionId);
    expect(sessions[1].id, testPlaySessionId);
    expect(harness.createRequests, hasLength(1));
    expect(harness.createRequests.single.revisionId, 1);
    expect(harness.createRequests.single.mode, PlayMode.free);
    expect(harness.state.phase, PlayPhase.active);

    harness.onCreate = null;
    await harness.create();
    expect(harness.createRequests, hasLength(2));
    expect(
      harness.createRequests[1].requestId,
      isNot(harness.createRequests[0].requestId),
    );
  });

  test('入口 ID は要求に載せ、作成中の別 ID は requestIdReused', () async {
    final harness = await setUpHarness();
    final completer = Completer<PlaySession>();
    harness.onCreate = (request) => completer.future.then(
      (_) =>
          fakePlaySession().copyWith(spawnPointId: request.spawnPointId ?? 1),
    );
    final first = harness.create(spawnPointId: 7);
    await expectLater(
      harness.create(spawnPointId: 8),
      throwsA(
        isA<PlayFailure>().having(
          (failure) => failure.kind,
          'kind',
          PlayFailureKind.requestIdReused,
        ),
      ),
    );
    completer.complete(fakePlaySession());
    expect((await first).spawnPointId, 7);
    expect(harness.createRequests.single.spawnPointId, 7);
  });

  test('開始のunavailable再試行は同じrequestIdで送る', () async {
    final harness = await setUpHarness();
    var calls = 0;
    harness.onCreate = (request) async {
      calls++;
      if (calls == 1) {
        throw apiError(.unavailable, 'TEMPORARILY_UNAVAILABLE');
      }
      return fakePlaySession().copyWith(
        spawnPointId: request.spawnPointId ?? 1,
      );
    };
    final session = await harness.create(spawnPointId: 7);
    expect(session.id, testPlaySessionId);
    expect(session.spawnPointId, 7);
    expect(harness.createRequests, hasLength(2));
    expect(
      harness.createRequests[0].requestId,
      harness.createRequests[1].requestId,
    );
    expect(harness.createRequests[0].spawnPointId, 7);
    expect(harness.createRequests[1].spawnPointId, 7);
  });

  test('開始のREVISION_NOT_PLAYABLEは失敗として返す', () async {
    final harness = await setUpHarness();
    harness.onCreate = (_) async =>
        throw apiError(.failedPrecondition, 'REVISION_NOT_PLAYABLE');
    await expectLater(
      harness.create(),
      throwsA(
        isA<PlayFailure>().having(
          (e) => e.kind,
          'kind',
          PlayFailureKind.revisionNotPlayable,
        ),
      ),
    );
    expect(harness.state.phase, PlayPhase.idle);
  });

  test('撮影は端末記録を保存してから送り、結果確認後に記録を消す', () async {
    final harness = await setUpHarness();
    await harness.create();
    var fileExistedAtSend = false;
    harness.onSubmit = (_) async {
      fileExistedAtSend = await harness.pendingFile.exists();
      return fakeSubmitShotResponse();
    };
    final result = await harness.notifier.submitShot(shotInput());
    expect(fileExistedAtSend, isTrue);
    expect(result?.shot.score, 500);
    expect(harness.state.phase, PlayPhase.completed);
    expect(await harness.pendingFile.exists(), isFalse);
    final request = harness.submitRequests.single;
    expect(request.playSessionId, testPlaySessionId);
    expect(request.camera.positionX, 100);
    expect(request.camera.yawDegrees, 90);
  });

  test('撮影の応答消失は結果不明にし、同じ姿勢とrequestIdで再送する', () async {
    final harness = await setUpHarness();
    await harness.create();
    var calls = 0;
    harness.onSubmit = (_) async {
      calls++;
      if (calls == 1) {
        throw const SocketException('切断');
      }
      return fakeSubmitShotResponse();
    };
    final first = await harness.notifier.submitShot(shotInput());
    expect(first, isNull);
    expect(harness.state.phase, PlayPhase.submitUnknown);
    expect(await harness.pendingFile.exists(), isTrue);

    final resent = await harness.notifier.resendShot();
    expect(resent?.shot.score, 500);
    expect(harness.state.phase, PlayPhase.completed);
    expect(harness.submitRequests, hasLength(2));
    expect(
      harness.submitRequests[0].requestId,
      harness.submitRequests[1].requestId,
    );
    expect(
      harness.submitRequests[1].camera.positionX,
      harness.submitRequests[0].camera.positionX,
    );
    expect(await harness.pendingFile.exists(), isFalse);
  });

  test('別IDで撮影済みなら照会して保存済み結果を返す', () async {
    final harness = await setUpHarness();
    await harness.create();
    harness.onSubmit = (_) async =>
        throw apiError(.alreadyExists, 'SHOT_ALREADY_SUBMITTED');
    harness.onGet = (_) async => fakeCompletedSession();
    final result = await harness.notifier.submitShot(shotInput());
    expect(result?.shot.score, 500);
    expect(harness.state.phase, PlayPhase.completed);
    expect(harness.getRequests, hasLength(1));
  });

  test('撮影のSESSION_EXPIREDは記録を消して期限切れにする', () async {
    final harness = await setUpHarness();
    await harness.create();
    harness.onSubmit = (_) async =>
        throw apiError(.failedPrecondition, 'SESSION_EXPIRED');
    await expectLater(
      harness.notifier.submitShot(shotInput()),
      throwsA(
        isA<PlayFailure>().having(
          (e) => e.kind,
          'kind',
          PlayFailureKind.sessionExpired,
        ),
      ),
    );
    expect(harness.state.phase, PlayPhase.sessionExpired);
    expect(await harness.pendingFile.exists(), isFalse);
  });

  test('入力拒否が確定したら未撮影を確認して探索へ戻れる状態にする', () async {
    final harness = await setUpHarness();
    await harness.create();
    harness.onSubmit = (_) async =>
        throw apiError(.invalidArgument, 'INVALID_CAMERA');
    harness.onGet = (_) async => fakePlaySession();
    await expectLater(
      harness.notifier.submitShot(shotInput()),
      throwsA(
        isA<PlayFailure>().having(
          (e) => e.kind,
          'kind',
          PlayFailureKind.invalidCamera,
        ),
      ),
    );
    expect(harness.state.phase, PlayPhase.active);
    expect(await harness.pendingFile.exists(), isFalse);
  });

  test('入力拒否の確認ができない場合は結果不明として記録を保持する', () async {
    final harness = await setUpHarness();
    await harness.create();
    harness.onSubmit = (_) async =>
        throw apiError(.invalidArgument, 'INVALID_CAMERA');
    harness.onGet = (_) async => throw const SocketException('切断');
    final result = await harness.notifier.submitShot(shotInput());
    expect(result, isNull);
    expect(harness.state.phase, PlayPhase.submitUnknown);
    expect(await harness.pendingFile.exists(), isTrue);
  });

  test('結果の照会はcompletedなら結果を返し、期限切れなら期限切れにする', () async {
    final harness = await setUpHarness();
    await harness.create();
    harness.onSubmit = (_) async => throw const SocketException('切断');
    await harness.notifier.submitShot(shotInput());
    expect(harness.state.phase, PlayPhase.submitUnknown);

    harness.onGet = (_) async => fakeCompletedSession();
    final result = await harness.notifier.checkShotResult();
    expect(result?.shot.score, 500);
    expect(harness.state.phase, PlayPhase.completed);

    // 期限切れの照会。
    final expired = await setUpHarness();
    await expired.create();
    expired.onSubmit = (_) async => throw const SocketException('切断');
    await expired.notifier.submitShot(shotInput());
    expired.onGet = (_) async => fakePlaySession(
      expireTime: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    );
    final expiredResult = await expired.notifier.checkShotResult();
    expect(expiredResult, isNull);
    expect(expired.state.phase, PlayPhase.sessionExpired);
  });

  test('起動時の復旧はcompletedの保存結果を表示し記録を消す', () async {
    final harness = await setUpHarness();
    await savePendingShot(
      harness.tempDir,
      PendingShot(
        authUserId: testAuthUserId.toString(),
        playSessionId: testPlaySessionId.toString(),
        revisionId: 1,
        shot: shotInput(),
        requestId: '00000000-0000-4000-8000-0000000000aa',
      ),
    );
    harness.onGet = (_) async => fakeCompletedSession();
    await harness.notifier.restorePending();
    expect(harness.state.phase, PlayPhase.completed);
    expect(harness.state.result?.shot.score, 500);
    expect(await harness.pendingFile.exists(), isFalse);
  });

  test('起動時の復旧は他アカウントの記録を照会しない', () async {
    final harness = await setUpHarness();
    await savePendingShot(
      harness.tempDir,
      PendingShot(
        authUserId: '00000000-0000-4000-8000-000000000099',
        playSessionId: testPlaySessionId.toString(),
        revisionId: 1,
        shot: shotInput(),
        requestId: '00000000-0000-4000-8000-0000000000aa',
      ),
    );
    await harness.notifier.restorePending();
    expect(harness.state.phase, PlayPhase.pendingAuthMismatch);
    expect(harness.getRequests, isEmpty);
    expect(await harness.pendingFile.exists(), isTrue);
  });

  test('起動時の復旧は期限切れを案内し、明示破棄で記録を消す', () async {
    final harness = await setUpHarness();
    await savePendingShot(
      harness.tempDir,
      PendingShot(
        authUserId: testAuthUserId.toString(),
        playSessionId: testPlaySessionId.toString(),
        revisionId: 1,
        shot: shotInput(),
        requestId: '00000000-0000-4000-8000-0000000000aa',
      ),
    );
    harness.onGet = (_) async => fakePlaySession(
      expireTime: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    );
    await harness.notifier.restorePending();
    expect(harness.state.phase, PlayPhase.sessionExpired);
    expect(await harness.pendingFile.exists(), isTrue);

    await harness.notifier.discardPending();
    expect(harness.state.phase, PlayPhase.idle);
    expect(await harness.pendingFile.exists(), isFalse);
  });

  test('起動時の復旧はactiveかつ期限内なら再送できる状態にする', () async {
    final harness = await setUpHarness();
    await savePendingShot(
      harness.tempDir,
      PendingShot(
        authUserId: testAuthUserId.toString(),
        playSessionId: testPlaySessionId.toString(),
        revisionId: 1,
        shot: shotInput(),
        requestId: '00000000-0000-4000-8000-0000000000aa',
      ),
    );
    harness.onGet = (_) async => fakePlaySession();
    await harness.notifier.restorePending();
    expect(harness.state.phase, PlayPhase.submitUnknown);
    expect(harness.state.session?.id, testPlaySessionId);
    expect(
      harness.state.pendingShot?.requestId,
      '00000000-0000-4000-8000-0000000000aa',
    );
  });
  test('開始応答不明の手動再試行でも条件とrequestIdを保持する', () async {
    final h = await setUpHarness();
    h.onCreate = (_) async => throw const SocketException('切断');
    await expectLater(h.create(), throwsA(isA<PlayFailure>()));
    await expectLater(
      h.notifier.createSession(revisionId: 2, mode: .near),
      throwsA(
        isA<PlayFailure>().having(
          (e) => e.kind,
          'kind',
          PlayFailureKind.requestIdReused,
        ),
      ),
    );
    h.onCreate = (_) async => fakePlaySession();
    await h.create();
    expect(h.createRequests[0].requestId, h.createRequests[1].requestId);
  });

  test('unknown modeはRPC前に拒否する', () async {
    final h = await setUpHarness();
    await expectLater(
      h.notifier.createSession(revisionId: 1, mode: .unknown),
      throwsA(isA<PlayFailure>()),
    );
    expect(h.createRequests, isEmpty);
  });

  test('端末保存中の連打でも最初の姿勢だけを一度送る', () async {
    final h = await setUpHarness();
    await h.create();
    final storage = Completer<Directory>();
    h.directory = () => storage.future;
    final first = h.notifier.submitShot(shotInput());
    final second = h.notifier.submitShot(shotInput().copyWith(positionX: 999));
    expect(h.state.phase, PlayPhase.submitting);
    expect(h.submitRequests, isEmpty);
    storage.complete(h.tempDir);
    await Future.wait([first, second]);
    expect(h.submitRequests.single.camera.positionX, 100);
  });

  test('保存中に終了した古い撮影は送信しないが記録は保持する', () async {
    final h = await setUpHarness();
    await h.create();
    final storage = Completer<Directory>();
    h.directory = () => storage.future;
    final shot = h.notifier.submitShot(shotInput());
    h.notifier.clearSession();
    storage.complete(h.tempDir);
    await shot;
    expect(h.submitRequests, isEmpty);
    expect(h.state.phase, PlayPhase.submitUnknown);
    expect(await h.pendingFile.exists(), isTrue);
  });

  test('遅い開始応答は終了後のセッションを復活させない', () async {
    final h = await setUpHarness();
    final response = Completer<PlaySession>();
    h.onCreate = (_) => response.future;
    final create = h.create();
    final rejected = expectLater(create, throwsA(isA<PlayFailure>()));
    h.notifier.clearSession();
    response.complete(fakePlaySession());
    await rejected;
    expect(h.state.session, isNull);
    expect(h.state.phase, PlayPhase.idle);
  });
  test('保留撮影の所有者を失ったら照会も再送もしない', () async {
    final h = await setUpHarness();
    await h.create();
    h.onSubmit = (_) async => throw const SocketException('切断');
    await h.notifier.submitShot(shotInput());
    final auth = h.container.read(authProvider.notifier);
    if (auth is SignedInAuthNotifier) auth.signOut();
    await expectLater(h.notifier.resendShot(), throwsA(isA<PlayFailure>()));
    await expectLater(
      h.notifier.checkShotResult(),
      throwsA(isA<PlayFailure>()),
    );
    expect(h.submitRequests, hasLength(1));
    expect(h.getRequests, isEmpty);
    expect(h.state.phase, PlayPhase.pendingAuthMismatch);
  });

  test('復旧先がnotFoundでも記録を消さず新しい撮影を始めない', () async {
    final h = await setUpHarness();
    await h.create();
    h.onSubmit = (_) async => throw const SocketException('切断');
    await h.notifier.submitShot(shotInput());
    h.onGet = (_) async => throw apiError(.notFound, 'PLAY_SESSION_NOT_FOUND');
    await h.notifier.restorePending();
    expect(h.state.phase, PlayPhase.submitUnknown);
    expect(await h.pendingFile.exists(), isTrue);
    await expectLater(h.create(), throwsA(isA<PlayFailure>()));
  });
  test('起動照会が不通でも再送後に版とmodeを確定して結果を復旧する', () async {
    final h = await setUpHarness();
    await savePendingShot(
      h.tempDir,
      PendingShot(
        authUserId: testAuthUserId.toString(),
        playSessionId: testPlaySessionId.toString(),
        revisionId: 1,
        shot: shotInput(),
        requestId: '00000000-0000-4000-8000-0000000000aa',
      ),
    );
    h.onGet = (_) async => throw const SocketException('切断');
    await h.notifier.restorePending();
    expect(h.state.session, isNull);
    h.onGet = (_) async => fakeCompletedSession().copyWith(mode: .near);
    final result = await h.notifier.resendShot();
    expect(result?.shot.score, 500);
    expect(h.state.session?.mode, PlayMode.near);
    expect(h.state.session?.revisionId, 1);
    expect(await h.pendingFile.exists(), isFalse);
  });
  testWidgets('入力拒否後の照会は10秒で結果不明へ戻り、遅い成功でも記録を消さない', (tester) async {
    final h = await tester.runAsync(() => setUpHarness());
    if (h == null) throw StateError('テスト準備が完了しません');
    await h.create();
    final response = Completer<PlaySession>();
    h.onSubmit = (_) async =>
        throw apiError(.invalidArgument, 'INVALID_CAMERA');
    h.onGet = (_) => response.future;
    final sending = h.notifier.submitShot(shotInput());
    for (var i = 0; i < 100 && h.getRequests.isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 2)),
      );
      await tester.pump();
    }
    expect(h.getRequests, hasLength(1));
    await tester.pump(const Duration(seconds: 9));
    expect(h.state.phase, PlayPhase.submitting);
    await tester.pump(const Duration(seconds: 1));
    expect(await sending, isNull);
    expect(h.state.phase, PlayPhase.submitUnknown);
    expect(await tester.runAsync(h.pendingFile.exists), isTrue);
    response.complete(fakeCompletedSession());
    await tester.pump();
    expect(h.state.phase, PlayPhase.submitUnknown);
    expect(h.state.result, isNull);
    expect(await tester.runAsync(h.pendingFile.exists), isTrue);
  });

  for (final completed in [false, true]) {
    test('復旧したunknown modeを探索・結果として採用しない completed=$completed', () async {
      final h = await setUpHarness();
      await savePendingShot(
        h.tempDir,
        PendingShot(
          authUserId: testAuthUserId.toString(),
          playSessionId: testPlaySessionId.toString(),
          revisionId: 1,
          shot: shotInput(),
          requestId: '00000000-0000-4000-8000-0000000000aa',
        ),
      );
      h.onGet = (_) async =>
          (completed ? fakeCompletedSession() : fakePlaySession()).copyWith(
            mode: .unknown,
          );
      await h.notifier.restorePending();
      expect(h.state.phase, PlayPhase.submitUnknown);
      expect(h.state.session, isNull);
      expect(h.state.result, isNull);
      expect(await h.pendingFile.exists(), isTrue);
    });
  }
  for (final mode in [PlayMode.free, PlayMode.near]) {
    test('別コンテナでプロセス終了後の記録を復旧し、同じ撮影を再送する $mode', () async {
      final first = await setUpHarness();
      first.onCreate = (_) async => fakePlaySession(mode: mode);
      await first.notifier.createSession(revisionId: 1, mode: mode);
      first.onSubmit = (_) async => throw const SocketException('応答を失う');
      await first.notifier.submitShot(shotInput());
      final original = first.submitRequests.single;
      first.container.dispose();
      final restored = await setUpHarness(existingDirectory: first.tempDir);
      restored.onGet = (_) async => fakePlaySession(mode: mode);
      await restored.notifier.restorePending();
      expect(restored.state.phase, PlayPhase.submitUnknown);
      expect(restored.state.session?.mode, mode);
      await restored.notifier.resendShot();
      final resent = restored.submitRequests.single;
      expect(resent.playSessionId, original.playSessionId);
      expect(resent.requestId, original.requestId);
      expect(resent.camera.toJson(), original.camera.toJson());
      expect(restored.createRequests, isEmpty);
      expect(restored.state.phase, PlayPhase.completed);
      expect(await restored.pendingFile.exists(), isFalse);
    });
  }
}
