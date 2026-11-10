import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/domain/ports/persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/passthrough_executor.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/replication_confirmer.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/serial_persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:photohunt_server/src/presentation/middleware/persistence_middleware.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Bearer(final String token) implements ClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async =>
      wrapAsBearerAuthHeaderValue(token);
}

class const _Media() implements SeedMediaStore {
  @override
  Future<bool> putIfAbsent(String path, Uint8List bytes, String type) async =>
      true;
}

class _Confirmer() implements ReplicationConfirmer {
  Completer<void>? entered;
  Completer<void>? release;
  bool fail = false;
  @override
  Future<void> confirm({required Duration timeout}) async {
    final signal = entered;
    if (signal != null && !signal.isCompleted) signal.complete();
    if (release case final pending?) await pending.future;
    if (fail) throw const ReplicationUnavailableException('test');
  }
}

Matcher failure(ApiErrorCode code, String reason) => throwsA(
  isA<ApiException>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.reason, 'reason', reason),
);

void main() {
  const dbPath = 'data/test.sqlite';
  const uuid = Uuid();
  late Serverpod pod;
  late int revisionId;
  late int freeEntranceId;
  final confirmer = _Confirmer();
  final sample = readSeedBundle(
    dir: 'test/fixtures/seeds/sample-plaza/r1',
    pavilionsPath: 'test/fixtures/seeds/pavilions.yaml',
  );

  Future<Client> user() async {
    final client = Client('http://localhost:8180/');
    addTearDown(client.close);
    client.authKeyProvider = _Bearer((await client.anonymousIdp.login()).token);
    return client;
  }

  Future<PlaySession> start(Client client, {PlayMode mode = .free}) =>
      client.play.createPlaySession(
        CreatePlaySessionRequest(
          revisionId: revisionId,
          mode: mode,
          requestId: uuid.v4obj(),
          spawnPointId: mode == .free ? freeEntranceId : null,
        ),
      );
  SubmitShotRequest shot(
    PlaySession play, {
    double x = 0,
    double z = -45,
    double yaw = 0,
    double pitch = 8,
    UuidValue? id,
  }) => SubmitShotRequest(
    playSessionId: play.id,
    requestId: id ?? uuid.v4obj(),
    camera: ShotInput(
      positionX: x,
      positionZ: z,
      yawDegrees: yaw,
      pitchDegrees: pitch,
    ),
  );
  void sql(String query, [List<Object?> args = const []]) {
    final db = sqlite3.open(dbPath);
    try {
      db.execute(query, args);
    } finally {
      db.close();
    }
  }

  int count(String table) {
    final db = sqlite3.open(dbPath, mode: .readOnly);
    try {
      final value = db.select('SELECT COUNT(*) AS n FROM $table').single['n'];
      if (value is! int) throw StateError('count is not an integer');
      return value;
    } finally {
      db.close();
    }
  }

  void expire(PlaySession play) => sql(
    'UPDATE play_session SET expires_at = 0 WHERE id = ?',
    [play.id.toBytes()],
  );

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$dbPath$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(['--mode', 'test', '--apply-migrations']);
    pod.server.addMiddleware(
      persistenceGateMiddleware(
        gate: SerialPersistenceGate(
          executor: const PassthroughExecutor(),
          confirmer: confirmer,
        ),
        requestDeadline: const Duration(seconds: 30),
        maxRequestSize: pod.config.maxRequestSize,
      ),
    );
    await pod.start();
    final store = SqliteSeedStore.open(dbPath);
    try {
      final loaded = await LoadSeedRevision(
        store: store,
        media: const _Media(),
        clock: DateTime.now,
      ).execute(sample, publish: true);
      if (loaded is! LoadSeedLoaded) throw StateError('seed was not loaded');
      revisionId = loaded.revisionId;
    } finally {
      store.close();
    }
    final db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    freeEntranceId =
        db.select(
              'SELECT s.id FROM spawn_point s JOIN mode_config m ON m.id = s.mode_config_id '
              "WHERE m.revision_id = ? AND m.mode = 'free' ORDER BY s.sort_order LIMIT 1",
              [revisionId],
            ).single['id']
            as int;
    db.close();
  });
  tearDownAll(() => pod.shutdown(exitProcess: false));

  test('両モードで撮影・Y/FOV補完・正解と結果の再取得・ランキング一致', () async {
    for (final mode in [PlayMode.free, PlayMode.near]) {
      final client = await user();
      final play = await start(client, mode: mode);
      final result = await client.play.submitShot(shot(play));
      expect(result.shot.score, 1000);
      expect(result.shot.camera.positionY, play.spawn.positionY + 1.6);
      expect(result.shot.camera.verticalFovDegrees, 50);
      expect(result.reveal.goalCamera.positionZ, -45);
      expect(result.reveal.story, isNotEmpty);
      expect(result.reveal.highlight, isNotEmpty);
      final fetched = await client.play.getPlaySession(
        GetPlaySessionRequest(playSessionId: play.id),
      );
      expect(fetched.state, PlaySessionState.completed);
      expect(fetched.shot?.toJson(), result.shot.toJson());
      expect(fetched.reveal?.toJson(), result.reveal.toJson());
      expect(fetched.myRankingEntry?.toJson(), result.myRankingEntry.toJson());
      final rank = await client.ranking.getMyRankingEntry(
        GetMyRankingEntryRequest(revisionId: revisionId, mode: mode),
      );
      expect(rank.toJson(), result.myRankingEntry.toJson());
    }
  });
  test('再送は期限後・名前変更・公開停止後も同じスナップショット、負のゼロも同一', () async {
    final client = await user();
    final play = await start(client);
    final request = shot(play, x: -0.0, yaw: -0.0);
    final first = await client.play.submitShot(request);
    expire(play);
    await client.profile.updateNickname(
      UpdateNicknameRequest(nickname: '変更した名前'),
    );
    sql('UPDATE challenge SET current_revision_id = NULL');
    addTearDown(
      () => sql('UPDATE challenge SET current_revision_id = ?', [revisionId]),
    );
    final again = await client.play.submitShot(
      shot(play, id: request.requestId),
    );
    expect(again.toJson(), first.toJson());
    await expectLater(
      client.play.submitShot(shot(play, x: 1, id: request.requestId)),
      failure(.invalidArgument, ApiErrorReasons.requestIdReused),
    );
    await expectLater(
      client.play.submitShot(shot(play)),
      failure(.alreadyExists, ApiErrorReasons.shotAlreadySubmitted),
    );
  });
  test('未撮影の期限切れと所有者・認証を検査する', () async {
    final client = await user();
    final play = await start(client);
    final other = await user();
    await expectLater(
      other.play.submitShot(shot(play)),
      failure(.permissionDenied, ApiErrorReasons.notSessionOwner),
    );
    final anonymous = Client('http://localhost:8180/');
    addTearDown(anonymous.close);
    await expectLater(
      anonymous.play.submitShot(shot(play)),
      throwsA(isA<ServerpodClientUnauthorized>()),
    );
    expire(play);
    await expectLater(
      client.play.submitShot(shot(play)),
      failure(.failedPrecondition, ApiErrorReasons.sessionExpired),
    );
  });
  test('範囲外・穴・yaw/pitch不正を保存せず、fieldViolationsを返す', () async {
    final client = await user();
    final play = await start(client, mode: .near);
    final before = count('shot');
    for (final request in [
      shot(play, x: 30),
      shot(play, z: -30),
      shot(play, yaw: 360),
      shot(play, pitch: 65.1),
    ]) {
      await expectLater(
        client.play.submitShot(request),
        throwsA(
          isA<ApiException>()
              .having((e) => e.reason, 'reason', ApiErrorReasons.invalidCamera)
              .having((e) => e.fieldViolations, 'fields', isNotEmpty),
        ),
      );
    }
    expect(count('shot'), before);
  });
  test('並行の異なる要求は1件だけ保存し、同じ要求の並行再送は同じ結果', () async {
    final client = await user();
    final play = await start(client);
    final before = count('shot');
    Future<Object> capture(SubmitShotRequest request) async {
      try {
        return await client.play.submitShot(request);
      } on ApiException catch (e) {
        return e;
      }
    }

    final results = await Future.wait([
      capture(shot(play)),
      capture(shot(play, x: 2)),
    ]);
    expect(results.whereType<SubmitShotResponse>(), hasLength(1));
    expect(
      results.whereType<ApiException>().single.reason,
      ApiErrorReasons.shotAlreadySubmitted,
    );
    expect(count('shot'), before + 1);
    final next = await start(client);
    final request = shot(next);
    final same = await Future.wait([
      client.play.submitShot(request),
      client.play.submitShot(request),
    ]);
    expect(same[0].toJson(), same[1].toJson());
  });
  test('改善だけ自己ベストを更新し、同点・悪化でも初回の達成時刻と順位が残る', () async {
    final client = await user();
    final first = await client.play.submitShot(shot(await start(client), x: 2));
    expect(first.shot.score, 819);
    final other = await user();
    final otherShot = await other.play.submitShot(
      shot(await start(other), x: 1),
    );
    final improved = await client.play.submitShot(shot(await start(client)));
    expect(improved.myRankingEntry.score, 1000);
    expect(
      improved.myRankingEntry.rank,
      lessThan(otherShot.myRankingEntry.rank + 1),
    );
    for (final x in [0.0, 5.0]) {
      final later = await client.play.submitShot(
        shot(await start(client), x: x),
      );
      expect(later.myRankingEntry.toJson(), improved.myRankingEntry.toJson());
    }
  });
  test('自己ベストの更新に失敗すると撮影もロールバックする', () async {
    final client = await user();
    final play = await start(client);
    final before = count('shot');
    sql(
      "CREATE TRIGGER test_best_fail BEFORE INSERT ON best_score BEGIN SELECT RAISE(ABORT, 'test'); END",
    );
    try {
      await expectLater(
        client.play.submitShot(shot(play)),
        failure(.internal, ApiErrorReasons.internal),
      );
      expect(count('shot'), before);
    } finally {
      sql('DROP TRIGGER test_best_fail');
    }
    expect((await client.play.submitShot(shot(play))).shot.score, 1000);
  });
  test('複製確認前には成功せず、確認失敗はTEMPORARILY_UNAVAILABLE', () async {
    final client = await user();
    final play = await start(client);
    final request = shot(play);
    final entered = Completer<void>();
    final release = Completer<void>();
    confirmer.entered = entered;
    confirmer.release = release;
    var responded = false;
    final pending = client.play.submitShot(request).then((value) {
      responded = true;
      return value;
    });
    await entered.future;
    expect(responded, isFalse);
    release.complete();
    final first = await pending;
    confirmer.entered = null;
    confirmer.release = null;
    confirmer.fail = true;
    try {
      await expectLater(
        client.play.submitShot(request),
        failure(.unavailable, ApiErrorReasons.temporarilyUnavailable),
      );
    } finally {
      confirmer.fail = false;
    }
    expect((await client.play.submitShot(request)).toJson(), first.toJson());
  });
}
