import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/application/seed/load_seed_revision.dart';
import 'package:photohunt_server/src/application/seed/seed_ports.dart';
import 'package:photohunt_server/src/generated/protocol.dart'
    show PlaySessionRow, SpawnPointRow, UserProfileRow;
import 'package:photohunt_server/src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'package:photohunt_server/src/infrastructure/seed/seed_reader.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// Authorization ヘッダーに JWT を載せるだけの最小の provider。
class _BearerProvider() implements ClientAuthKeyProvider {
  String? token;

  @override
  Future<String?> get authHeaderValue async =>
      token == null ? null : wrapAsBearerAuthHeaderValue(token!);
}

/// 素材置き場の代わり（この試験では素材の配置は確かめない）。
class const _NoopMedia() implements SeedMediaStore {
  @override
  Future<bool> putIfAbsent(
    String objectPath,
    Uint8List bytes,
    String contentType,
  ) async => true;
}

Matcher _apiFailure(ApiErrorCode code, String reason) => throwsA(
  isA<ApiException>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.reason, 'reason', reason),
);

const _sampleDir = 'test/fixtures/seeds/sample-plaza/r1';
const _pavilions = 'test/fixtures/seeds/pavilions.yaml';
const _dbPath = 'data/test.sqlite';
const _uuid = Uuid();

/// 実サーバーを test モードで起動し、#26 の seed で公開した出題に、生成 client から
/// プレイを開始・取得する。
///
/// 各テストは新しい利用者（匿名ログイン）を作り、レート制限や再送が互いに影響しない。
void main() {
  late Serverpod pod;
  final sample = readSeedBundle(dir: _sampleDir, pavilionsPath: _pavilions);
  final now = DateTime.utc(2026, 11, 9);
  late int revisionId;
  late int freeSpawnCount;
  late List<int> freeSpawnIds;
  late int freeEntranceId;
  late Set<int> nearSpawnIds;

  /// 新しい利用者の client。プロフィールは、匿名ログイン（#25）が作る。
  int? lastProfileId;

  Future<Client> newUser() async {
    final auth = _BearerProvider();
    final client = Client('http://localhost:8180/')..authKeyProvider = auth;
    addTearDown(client.close);
    final success = await client.anonymousIdp.login();
    auth.token = success.token;
    final profile = await pod.withSession(
      (s) => UserProfileRow.db.findFirstRow(
        s,
        where: (t) => t.authUserId.equals(success.authUserId),
      ),
    );
    expect(profile, isNotNull, reason: '匿名ログインがプロフィールを作る');
    lastProfileId = profile!.id;
    return client;
  }

  Future<T> withSeedStore<T>(Future<T> Function(SqliteSeedStore s) body) async {
    final store = SqliteSeedStore.open(_dbPath);
    try {
      return await body(store);
    } finally {
      store.close();
    }
  }

  CreatePlaySessionRequest request({
    PlayMode mode = .free,
    UuidValue? requestId,
    int? revision,
    int? entrance,
  }) => CreatePlaySessionRequest(
    revisionId: revision ?? revisionId,
    mode: mode,
    requestId: requestId ?? _uuid.v4obj(),
    spawnPointId: mode == .free ? entrance ?? freeEntranceId : null,
  );

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$_dbPath$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(['--mode', 'test', '--apply-migrations']);
    await pod.start();

    final result = await withSeedStore(
      (store) => LoadSeedRevision(
        store: store,
        media: const _NoopMedia(),
        clock: () => now,
      ).execute(sample, publish: true),
    );
    revisionId = (result as LoadSeedLoaded).revisionId;
    freeSpawnCount = sample.input.modes
        .firstWhere((m) => m.mode == PlayMode.free)
        .spawns
        .length;
    final db = sqlite3.open(_dbPath, mode: OpenMode.readOnly);
    nearSpawnIds = {
      for (final r in db.select(
        'SELECT s.id FROM spawn_point s JOIN mode_config m ON m.id = s.mode_config_id '
        "WHERE m.revision_id = ? AND m.mode = 'near'",
        [revisionId],
      ))
        r['id'] as int,
    };
    freeSpawnIds = [
      for (final row in db.select(
        'SELECT s.id FROM spawn_point s JOIN mode_config m ON m.id = s.mode_config_id '
        "WHERE m.revision_id = ? AND m.mode = 'free' ORDER BY s.sort_order",
        [revisionId],
      ))
        row['id'] as int,
    ];
    freeEntranceId = freeSpawnIds.first;
    db.close();
  });

  tearDownAll(() async {
    await pod.shutdown(exitProcess: false);
  });

  test('未ログインでは拒否する', () async {
    final anonymous = Client('http://localhost:8180/');
    addTearDown(anonymous.close);
    final unauthorized = throwsA(isA<ServerpodClientUnauthorized>());
    await expectLater(
      anonymous.play.createPlaySession(request()),
      unauthorized,
    );
    await expectLater(
      anonymous.play.getPlaySession(
        GetPlaySessionRequest(playSessionId: _uuid.v4obj()),
      ),
      unauthorized,
    );
  });

  test('開始すると開始点と 2 時間後の期限が返り、getPlaySession で同じ内容を取得できる', () async {
    final client = await newUser();
    final created = await client.play.createPlaySession(request());

    expect(created.state, PlaySessionState.active);
    expect(created.revisionId, revisionId);
    expect(created.mode, PlayMode.free);
    expect(
      created.expireTime.difference(created.createTime),
      const Duration(hours: 2),
    );
    // 未撮影では、撮影・正解・順位を一切返さない。
    expect(created.shot, isNull);
    expect(created.reveal, isNull);
    expect(created.myRankingEntry, isNull);
    // 開始点は seed の free の候補のどれか。
    final freeSpawns = sample.input.modes
        .firstWhere((m) => m.mode == PlayMode.free)
        .spawns;
    expect(
      freeSpawns.any(
        (s) =>
            s.positionX == created.spawn.positionX &&
            s.positionZ == created.spawn.positionZ &&
            s.yawDegrees == created.spawn.yawDegrees,
      ),
      isTrue,
    );

    final fetched = await client.play.getPlaySession(
      GetPlaySessionRequest(playSessionId: created.id),
    );
    expect(fetched.toJson(), created.toJson());
  });

  test('near は常に同じ唯一の開始点', () async {
    final client = await newUser();
    final results = [
      for (var i = 0; i < 3; i++)
        await client.play.createPlaySession(request(mode: .near)),
    ];
    expect(nearSpawnIds, hasLength(1));
    final spawn = sample.input.modes
        .firstWhere((m) => m.mode == PlayMode.near)
        .spawns
        .single;
    for (final r in results) {
      expect(r.spawn.positionX, spawn.positionX);
      expect(r.spawn.positionZ, spawn.positionZ);
      expect(r.spawn.yawDegrees, spawn.yawDegrees);
    }
  });

  test('free は指定した入口から始まる', () async {
    expect(freeSpawnCount, greaterThan(1));
    final client = await newUser();
    for (final id in freeSpawnIds) {
      final session = await client.play.createPlaySession(
        request(entrance: id),
      );
      expect(session.spawnPointId, id);
    }
  });

  test('同じ requestId で再送すると同じ id と開始点を返し、行を増やさない', () async {
    final client = await newUser();
    final requestId = _uuid.v4obj();
    final first = await client.play.createPlaySession(
      request(requestId: requestId),
    );
    for (var i = 0; i < 3; i++) {
      final again = await client.play.createPlaySession(
        request(requestId: requestId),
      );
      expect(again.id, first.id);
      expect(again.toJson(), first.toJson());
    }
    final count = await pod.withSession(
      (s) => PlaySessionRow.db.count(
        s,
        where: (t) => t.requestId.equals(requestId),
      ),
    );
    expect(count, 1);
  });

  test('同じ requestId で mode か revisionId を変えると REQUEST_ID_REUSED', () async {
    final client = await newUser();
    final requestId = _uuid.v4obj();
    await client.play.createPlaySession(request(requestId: requestId));
    await expectLater(
      client.play.createPlaySession(request(requestId: requestId, mode: .near)),
      _apiFailure(.invalidArgument, ApiErrorReasons.requestIdReused),
    );
    await expectLater(
      client.play.createPlaySession(
        request(requestId: requestId, revision: revisionId + 1),
      ),
      _apiFailure(.invalidArgument, ApiErrorReasons.requestIdReused),
    );
  });

  test(
    'mode が unknown・版 id が 0 以下・requestId が UUID v4 でないと INVALID_REQUEST',
    () async {
      final client = await newUser();
      await expectLater(
        client.play.createPlaySession(request(mode: .unknown)),
        _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
      );
      await expectLater(
        client.play.createPlaySession(request(revision: 0)),
        _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
      );
      await expectLater(
        client.play.createPlaySession(
          request(
            requestId: UuidValue.fromString(
              '00000000-0000-0000-0000-000000000000',
            ),
          ),
        ),
        _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
      );
      await expectLater(
        client.play.createPlaySession(request(requestId: _uuid.v7obj())),
        _apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest),
      );
    },
  );

  test('ない版・未公開の下書き版は REVISION_NOT_FOUND', () async {
    final client = await newUser();
    await expectLater(
      client.play.createPlaySession(request(revision: 99999)),
      _apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
    // 別の出題の下書き（公開しない）。下書きの存在を REVISION_NOT_PLAYABLE で知らせない。
    final raw = readSeedRevisionInput(_sampleDir);
    final input = seedRevisionFromInput(
      raw.copyWith(challenge: raw.challenge.copyWith(slug: 'draft-for-play')),
    );
    final draft = await withSeedStore(
      (store) =>
          LoadSeedRevision(
            store: store,
            media: const _NoopMedia(),
            clock: () => now,
          ).execute(
            SeedBundle(
              input: input,
              pavilions: sample.pavilions,
              photo: sample.photo,
              map: sample.map,
              digest: seedDigest(
                input,
                photoSha256: sample.photo.sha256,
                mapSha256: sample.map.sha256,
              ),
            ),
          ),
    );
    await expectLater(
      client.play.createPlaySession(
        request(revision: (draft as LoadSeedLoaded).revisionId),
      ),
      _apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
  });

  test('公開を外すと新規開始は REVISION_NOT_PLAYABLE、作成済みは同じ requestId で返る', () async {
    final client = await newUser();
    final requestId = _uuid.v4obj();
    final first = await client.play.createPlaySession(
      request(requestId: requestId),
    );

    await withSeedStore((store) => store.unpublish(slug: 'sample-plaza'));
    addTearDown(
      () => withSeedStore(
        (store) => store.publish(slug: 'sample-plaza', revisionNo: 1, now: now),
      ),
    );

    await expectLater(
      client.play.createPlaySession(request()),
      _apiFailure(.failedPrecondition, ApiErrorReasons.revisionNotPlayable),
    );
    final again = await client.play.createPlaySession(
      request(requestId: requestId),
    );
    expect(again.id, first.id);
    // 公開が外れても、開始済みのプレイは取得できる。
    final fetched = await client.play.getPlaySession(
      GetPlaySessionRequest(playSessionId: first.id),
    );
    expect(fetched.id, first.id);
  });

  test(
    '1 分に 11 回目の新規開始は SESSION_RATE_LIMITED と retryAfterSeconds。再送は数えない',
    () async {
      final client = await newUser();
      final userProfileId = lastProfileId!;
      final firstId = _uuid.v4obj();
      await client.play.createPlaySession(request(requestId: firstId));
      for (var i = 0; i < 9; i++) {
        await client.play.createPlaySession(request());
      }
      // 10 回消費した。再送は、制限中でも通り、回数を増やさない。
      await client.play.createPlaySession(request(requestId: firstId));

      await expectLater(
        client.play.createPlaySession(request()),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.resourceExhausted)
              .having(
                (e) => e.reason,
                'reason',
                ApiErrorReasons.sessionRateLimited,
              )
              .having(
                (e) => e.retryAfterSeconds,
                'retryAfterSeconds',
                allOf(isNotNull, inInclusiveRange(1, 60)),
              ),
        ),
      );
      // 拒否された開始は保存されない。この利用者の行は、新規 10 件のまま（再送は増やさない）。
      final saved = await pod.withSession(
        (session) => PlaySessionRow.db.count(
          session,
          where: (t) => t.userProfileId.equals(userProfileId),
        ),
      );
      expect(saved, 10);
    },
  );

  test('他人の playSessionId は NOT_SESSION_OWNER で、相手の情報を含まない', () async {
    final owner = await newUser();
    final other = await newUser();
    final created = await owner.play.createPlaySession(request());

    await expectLater(
      other.play.getPlaySession(
        GetPlaySessionRequest(playSessionId: created.id),
      ),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.permissionDenied)
            .having((e) => e.reason, 'reason', ApiErrorReasons.notSessionOwner)
            // 相手の版・開始点・日時が、エラーに含まれない。
            .having(
              (e) => e.toString(),
              'message',
              allOf(
                isNot(contains(created.id.toString())),
                isNot(contains('${created.spawn.positionX}')),
                isNot(contains(created.createTime.toIso8601String())),
              ),
            ),
      ),
    );
  });

  test('ないプレイは PLAY_SESSION_NOT_FOUND', () async {
    final client = await newUser();
    await expectLater(
      client.play.getPlaySession(
        GetPlaySessionRequest(playSessionId: _uuid.v4obj()),
      ),
      _apiFailure(.notFound, ApiErrorReasons.playSessionNotFound),
    );
  });

  test('保存した開始点は、版・モードに属する点だけ', () async {
    final client = await newUser();
    final created = await client.play.createPlaySession(request());
    final row = await pod.withSession(
      (s) => PlaySessionRow.db.findById(s, created.id),
    );
    final spawn = await pod.withSession(
      (s) => SpawnPointRow.db.findById(s, row!.spawnPointId),
    );
    final db = sqlite3.open(_dbPath, mode: OpenMode.readOnly);
    final owner = db.select(
      'SELECT m.revision_id AS revision_id, m.mode AS mode FROM mode_config m WHERE m.id = ?',
      [spawn!.modeConfigId],
    ).single;
    db.close();
    expect(owner['revision_id'], revisionId);
    expect(owner['mode'], 'free');
  });
}
