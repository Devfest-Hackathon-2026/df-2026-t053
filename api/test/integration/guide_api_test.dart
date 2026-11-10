import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/serial_persistence_gate.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/passthrough_executor.dart';
import 'package:photohunt_server/src/infrastructure/database/replication/replication_confirmer.dart';
import 'package:photohunt_server/src/presentation/middleware/guide_stream.dart';
import 'package:photohunt_server/src/presentation/middleware/persistence_middleware.dart';
import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/infrastructure/audio/wav.dart';
import 'package:photohunt_server/src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:photohunt_server/src/presentation/di/guide_dependencies.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Auth(final String token) implements ClientAuthKeyProvider {
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
  int count = 0;
  Completer<void>? hold;
  @override
  Future<void> confirm({required Duration timeout}) async {
    count++;
    await hold?.future;
  }
}

void main() {
  const uuid = Uuid();
  late Serverpod pod;
  late int revisionId;
  final confirmer = _Confirmer();
  late SerialPersistenceGate gate;
  const fake = {'GUIDES_ENABLED': 'true', 'GUIDE_BACKEND': 'fake'};
  Future<Client> user() async {
    final client = Client('http://localhost:8180/');
    addTearDown(client.close);
    client.authKeyProvider = _Auth((await client.anonymousIdp.login()).token);
    return client;
  }

  Future<PlaySession> start(Client client) => client.play.createPlaySession(
    CreatePlaySessionRequest(
      revisionId: revisionId,
      mode: .near,
      requestId: uuid.v4obj(),
    ),
  );
  ExplainNearbyRequest request(
    UuidValue playId, {
    double x = 10,
    double z = -15,
    // sample-plaza の構造物（0, -30）は、+Z 北の座標で南西（約 213.7°）にある（#213）。
    double yaw = 210,
    String locale = 'ja-JP',
  }) => ExplainNearbyRequest(
    playSessionId: playId,
    positionX: x,
    positionZ: z,
    yawDegrees: yaw,
    locale: locale,
  );
  Future<void> rejected(
    Client client,
    ExplainNearbyRequest r,
    String reason,
  ) async {
    var events = 0;
    await expectLater(
      client.guide.explainNearby(r).map((e) {
        events++;
        return e;
      }).toList(),
      throwsA(isA<ApiException>().having((e) => e.reason, 'reason', reason)),
    );
    expect(events, 0);
  }

  void sql(String query, List<Object?> args) {
    final db = sqlite3.open('data/test.sqlite');
    try {
      db.execute(query, args);
    } finally {
      db.close();
    }
  }

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('data/test.sqlite$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(['--mode', 'test', '--apply-migrations']);
    configureGuides(pod, environment: fake);
    gate = SerialPersistenceGate(
      executor: const PassthroughExecutor(),
      confirmer: confirmer,
    );
    configureGuideStreaming(pod, gate: gate, maintenance: null);
    pod.server.addMiddleware(
      persistenceGateMiddleware(
        gate: gate,
        requestDeadline: const Duration(seconds: 30),
        maxRequestSize: pod.config.maxRequestSize,
      ),
    );
    await pod.start();
    final store = SqliteSeedStore.open('data/test.sqlite');
    try {
      final result =
          await LoadSeedRevision(
            store: store,
            media: const _Media(),
            clock: DateTime.now,
          ).execute(
            readSeedBundle(
              dir: 'test/fixtures/seeds/sample-plaza/r1',
              pavilionsPath: 'test/fixtures/seeds/pavilions.yaml',
            ),
            publish: true,
          );
      if (result is! LoadSeedLoaded) throw StateError('seed failed');
      revisionId = result.revisionId;
    } finally {
      store.close();
    }
  });
  tearDownAll(() => pod.shutdown(exitProcess: false));
  test('生成clientのWebSocketで本文→連番chunk→正常終了、有効なWAV', () async {
    final client = await user();
    final play = await start(client);
    final events = await client.guide.explainNearby(request(play.id)).toList();
    expect(events.first, isA<GuideText>());
    expect(events.whereType<GuideText>(), hasLength(1));
    expect(events.map((e) => e.guideId).toSet(), hasLength(1));
    final chunks = events.whereType<GuideAudioChunk>().toList();
    expect(chunks, hasLength(2));
    expect(chunks.map((e) => e.sequence), [0, 1]);
    expect(chunks.map((e) => e.last), [false, true]);
    final bytes = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      expect(chunk.contentType, 'audio/wav');
      expect(chunk.data.lengthInBytes, inInclusiveRange(1, 32768));
      bytes.add(
        chunk.data.buffer.asUint8List(
          chunk.data.offsetInBytes,
          chunk.data.lengthInBytes,
        ),
      );
    }
    final wav = bytes.takeBytes();
    expect(toWav(wav, mimeType: 'audio/wav'), wav);
    await rejected(client, request(play.id), ApiErrorReasons.guideRateLimited);
  });
  test('事前検査の各reasonはイベントより前に届く', () async {
    final owner = await user();
    final play = await start(owner);
    final other = await user();
    await rejected(other, request(play.id), ApiErrorReasons.notSessionOwner);
    await rejected(
      await user(),
      request(uuid.v4obj()),
      ApiErrorReasons.playSessionNotFound,
    );
    await rejected(
      owner,
      request(play.id, locale: 'en-US'),
      ApiErrorReasons.unsupportedLocale,
    );
    for (final (x, z, yaw, reason) in [
      (30.0, -15.0, 330.0, ApiErrorReasons.invalidCamera),
      (0.0, -30.0, 330.0, ApiErrorReasons.invalidCamera),
      (10.0, -15.0, 360.0, ApiErrorReasons.invalidCamera),
    ]) {
      final client = await user();
      final own = await start(client);
      await rejected(client, request(own.id, x: x, z: z, yaw: yaw), reason);
    }
    final expiredUser = await user();
    final expired = await start(expiredUser);
    sql('UPDATE play_session SET expires_at=0 WHERE id=?', [
      expired.id.toBytes(),
    ]);
    await rejected(
      expiredUser,
      request(expired.id),
      ApiErrorReasons.sessionExpired,
    );
    configureGuides(pod, environment: {'GUIDES_ENABLED': 'false'});
    try {
      await rejected(owner, request(play.id), ApiErrorReasons.guideDisabled);
    } finally {
      configureGuides(pod, environment: fake);
    }
  });
  test('近くの候補がなければ、最寄りの構造物を方向と距離帯つきで説明する（#226）', () async {
    final client = await user();
    final play = await start(client);
    // 東を向くと、構造物（0, -30）は右後方（相対 123.7°、約 18 m）にあり、近くの候補にならない。
    final events = await client.guide
        .explainNearby(request(play.id, yaw: 90))
        .toList();
    final text = events.first as GuideText;
    expect(text.structures, ['サンプルの大屋根']);
    expect(text.text, '【fake】右手の方向の少し離れた所に、サンプルの大屋根があります。');
    expect(
      events.last,
      isA<GuideAudioChunk>().having((e) => e.last, 'last', true),
    );
  });
  test('事前検査で失敗した直後でも、正しい姿勢で開き直せる（#223）', () async {
    final client = await user();
    final play = await start(client);
    await rejected(
      client,
      request(play.id, yaw: 360),
      ApiErrorReasons.invalidCamera,
    );
    // 失敗で閉じた WebSocket と競合しないよう、同じ認証の別 client で開き直す。
    final retry = Client('http://localhost:8180/')
      ..authKeyProvider = client.authKeyProvider;
    addTearDown(retry.close);
    final events = await retry.guide.explainNearby(request(play.id)).toList();
    expect(events.first, isA<GuideText>());
    // 検査を通った要求は待ち時間を使う。
    await rejected(retry, request(play.id), ApiErrorReasons.guideRateLimited);
  });
  test('completedはSESSION_COMPLETED', () async {
    final client = await user();
    final play = await start(client);
    sql(
      '''INSERT INTO shot(request_id, play_session_id, x,y,z,yaw_deg,pitch_deg,fov_deg,
      distance_m,yaw_diff_deg,pitch_diff_deg,score,rank_at_submission,best_score_at_submission,
      nickname_at_submission,best_achieve_time_at_submission,created_at)
      VALUES(?,?,0,1.6,-45,0,8,50,0,0,0,1000,1,1000,'旅人',0,0)''',
      [uuid.v4obj().toBytes(), play.id.toBytes()],
    );
    await rejected(client, request(play.id), ApiErrorReasons.sessionCompleted);
  });
  test('固定文では本文とTEXT_FALLBACKだけ', () async {
    for (final behavior in ['empty', 'unavailable']) {
      configureGuides(
        pod,
        environment: {...fake, 'GUIDE_FAKE_BEHAVIOR': behavior},
      );
      final client = await user();
      final play = await start(client);
      final events = await client.guide
          .explainNearby(request(play.id))
          .toList();
      expect(events, hasLength(2));
      expect(
        events.first,
        isA<GuideText>().having((e) => e.aiGenerated, 'ai', false),
      );
      expect(
        events.last,
        isA<GuideAudioUnavailable>().having(
          (e) => e.reason,
          'reason',
          GuideAudioUnavailableReason.TEXT_FALLBACK,
        ),
      );
    }
    configureGuides(pod, environment: fake);
  });
  test('WSS認証と資料取得は同期を確認し、TTS待ちの間にHTTPのDB要求が進む', () async {
    configureGuides(pod, environment: {...fake, 'GUIDE_FAKE_DELAY_MS': '1000'});
    addTearDown(() => configureGuides(pod, environment: fake));
    final client = await user();
    final play = await start(client);
    final before = confirmer.count;
    final stream = StreamIterator(client.guide.explainNearby(request(play.id)));
    addTearDown(stream.cancel);
    expect(await stream.moveNext(), isTrue);
    expect(stream.current, isA<GuideText>());
    expect(confirmer.count - before, 2);
    final profile = await client.profile
        .getMyProfile(GetMyProfileRequest())
        .timeout(const Duration(milliseconds: 500));
    expect(profile.nickname, isNotEmpty);
    expect(await stream.moveNext(), isTrue);
  });
  test('認証後の複製確認が停止しても全体期限で通信を終了し、DB境界は完了まで保持する', () async {
    final client = await user();
    final play = await start(client);
    configureGuideStreaming(
      pod,
      gate: gate,
      maintenance: null,
      lifetime: const Duration(milliseconds: 150),
    );
    final blocked = Completer<void>();
    confirmer.hold = blocked;
    final watch = Stopwatch()..start();
    try {
      await expectLater(
        client.guide.explainNearby(request(play.id)).toList(),
        throwsA(isA<Exception>()),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      expect(blocked.isCompleted, isFalse);
    } finally {
      confirmer.hold = null;
      blocked.complete();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      configureGuideStreaming(pod, gate: gate, maintenance: null);
    }
  });
  test('未認証のstreamは拒否される', () async {
    final client = Client('http://localhost:8180/');
    addTearDown(client.close);
    await expectLater(
      client.guide.explainNearby(request(uuid.v4obj())).toList(),
      throwsA(isA<ServerpodClientException>()),
    );
  });
}
