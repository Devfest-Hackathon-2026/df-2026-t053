import 'package:photohunt_server/src/application/dto/play_result.dart';
import 'package:photohunt_server/src/application/usecase/get_play_session.dart';
import 'package:photohunt_server/src/application/usecase/start_play.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/models.dart';
import 'package:photohunt_server/src/domain/ports/spawn_chooser.dart';
import 'package:photohunt_server/src/domain/ports/start_rate_limiter.dart';
import 'package:photohunt_server/src/domain/repositories/challenge_repository.dart';
import 'package:photohunt_server/src/domain/repositories/play_session_repository.dart';
import 'package:photohunt_server/src/domain/repositories/shot_repository.dart';
import 'package:photohunt_server/src/domain/repositories/user_profile_repository.dart';
// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _t0 = DateTime.utc(2026, 11, 9, 12);

class _Challenges({
  /// 現在の公開版の id（null なら公開終了）。
  required var int? currentRevisionId,
  required final Set<int> publishedRevisions,
  final Map<(int, PlayMode), List<SpawnPoint>> spawns = const {},
}) implements ChallengeRepository {
  final List<String> calls = [];

  @override
  Future<Challenge?> findById(int id) async => Challenge(
    id: id,
    slug: 's',
    title: 't',
    currentRevisionId: currentRevisionId,
    createdAt: _t0,
  );

  /// 未公開の下書き版（行はあるが published_at が null）。
  final Set<int> draftRevisions = {};

  @override
  Future<({int challengeId, bool published})?> findRevisionStatus(
    int revisionId,
  ) async {
    calls.add('findRevisionStatus');
    if (draftRevisions.contains(revisionId)) {
      return (challengeId: 1, published: false);
    }
    if (!publishedRevisions.contains(revisionId)) return null;
    return (challengeId: 1, published: true);
  }

  @override
  Future<ChallengeRevision?> findPublishedRevision(int revisionId) async {
    if (!publishedRevisions.contains(revisionId)) return null;
    return ChallengeRevision(
      id: revisionId,
      challengeId: 1,
      revisionNo: revisionId,
      sceneProfile: 'bundled-v1',
      scoringVersion: 'v1',
      photo: _asset,
      map: _asset,
      photoAlt: 'alt',
      mapBounds: MapBounds(minX: 0, minZ: 0, maxX: 1, maxZ: 1),
      eyeHeightM: 1.6,
      shotFovDeg: 50,
      publishedAt: _t0,
      createdAt: _t0,
      modes: const [],
      landmarks: const [],
      credits: const [],
      secrets: null,
    );
  }

  @override
  Future<List<SpawnPoint>> listSpawnPoints(
    int revisionId,
    PlayMode mode,
  ) async => spawns[(revisionId, mode)] ?? const [];

  @override
  Future<SpawnPoint?> findSpawnPoint(int spawnPointId) async {
    for (final list in spawns.values) {
      for (final s in list) {
        if (s.id == spawnPointId) return s;
      }
    }
    return null;
  }

  @override
  Future<List<Challenge>> listPublished() => throw UnimplementedError();

  @override
  Future<Challenge?> findPublicById(int id) => throw UnimplementedError();

  @override
  Future<ChallengeRevision?> findRevision(int revisionId) =>
      throw UnimplementedError();

  /// 撮影済みのプレイの、正解・解説を含む版。null の版は秘密が欠けている。
  final Map<int, RevisionSecrets?> secrets = {};

  @override
  Future<ChallengeRevision?> findRevisionWithSecrets(int revisionId) async {
    if (!secrets.containsKey(revisionId)) return null;
    final revision = (await findPublishedRevision(revisionId))!;
    return ChallengeRevision(
      id: revision.id,
      challengeId: revision.challengeId,
      revisionNo: revision.revisionNo,
      sceneProfile: revision.sceneProfile,
      scoringVersion: revision.scoringVersion,
      photo: revision.photo,
      map: revision.map,
      photoAlt: revision.photoAlt,
      mapBounds: revision.mapBounds,
      eyeHeightM: revision.eyeHeightM,
      shotFovDeg: revision.shotFovDeg,
      publishedAt: revision.publishedAt,
      createdAt: revision.createdAt,
      modes: revision.modes,
      landmarks: revision.landmarks,
      credits: revision.credits,
      secrets: secrets[revisionId],
    );
  }
}

final _asset = Asset(
  id: 1,
  sha256: 'a' * 64,
  objectPath: 'media/${'a' * 64}/photo.png',
  contentType: 'image/png',
  byteLength: 1,
  createdAt: _t0,
);

SpawnPoint _spawn(int id, {double x = 0, String? label = '入口'}) => SpawnPoint(
  id: id,
  modeConfigId: 1,
  x: x,
  y: 0,
  z: 0,
  yawDeg: 90,
  sortOrder: id,
  label: label,
);

class _Sessions() implements PlaySessionRepository {
  final List<PlaySession> saved = [];

  /// 次の insert を、並行要求に負けた状態にする（別の要求が先に保存した）。
  PlaySession? racingWinner;

  @override
  Future<PlaySession?> findById(UuidValue id) async {
    for (final s in saved) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<PlaySession?> findByRequestId(
    int userProfileId,
    UuidValue requestId,
  ) async {
    for (final s in saved) {
      if (s.userProfileId == userProfileId && s.requestId == requestId) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<PlaySession> insert(PlaySession session) async {
    final winner = racingWinner;
    if (winner != null) {
      racingWinner = null;
      saved.add(winner);
      throw const DuplicateEntityException(
        entity: 'play_session',
        constraint: 'play_session_profile_request_uk',
      );
    }
    saved.add(session);
    return session;
  }
}

class _Shots() implements ShotRepository {
  final Map<UuidValue, Shot> byPlaySession = {};

  @override
  Future<Shot?> findByPlaySessionId(UuidValue playSessionId) async =>
      byPlaySession[playSessionId];

  @override
  Future<Shot> insert(Shot shot) => throw UnimplementedError();
}

class _Profiles({required final Map<UuidValue, int> ids})
    implements UserProfileRepository {
  @override
  Future<UserProfile?> findByAuthUserId(UuidValue authUserId) async {
    final id = ids[authUserId];
    return id == null
        ? null
        : UserProfile(
            id: id,
            authUserId: authUserId,
            nickname: 'n',
            createdAt: _t0,
          );
  }

  @override
  Future<UserProfile> insert(UserProfile profile) => throw UnimplementedError();

  @override
  Future<UserProfile?> updateNickname(int id, String nickname) =>
      throw UnimplementedError();
}

class _Limiter() implements StartRateLimiter {
  int? blockedFor;
  final List<int> acquired = [];

  @override
  int? retryAfter(int userProfileId) => blockedFor;

  @override
  void record(int userProfileId) => acquired.add(userProfileId);
}

class _Chooser() implements SpawnChooser {
  int next = 0;
  final List<int> counts = [];

  @override
  int choose(int count) {
    counts.add(count);
    return next % count;
  }
}

Matcher _fails(PlayFailure reason) =>
    throwsA(isA<PlayException>().having((e) => e.reason, 'reason', reason));

void main() {
  final alice = _uuid.v4obj();
  final bob = _uuid.v4obj();
  late _Challenges challenges;
  late _Sessions sessions;
  late _Limiter limiter;
  late _Chooser chooser;
  late _Shots shots;
  var clock = _t0;
  var idCounter = 0;

  StartPlay startPlay() => StartPlay(
    challenges,
    sessions,
    shots,
    _Profiles(ids: {alice: 1, bob: 2}),
    limiter,
    chooser,
    () => clock,
    () => UuidValue.fromString(
      '00000000-0000-7000-8000-${(++idCounter).toString().padLeft(12, '0')}',
    ),
  );

  GetPlaySession getPlay() => GetPlaySession(
    challenges,
    sessions,
    shots,
    _Profiles(ids: {alice: 1, bob: 2}),
  );

  setUp(() {
    clock = _t0;
    idCounter = 0;
    challenges = _Challenges(
      currentRevisionId: 10,
      publishedRevisions: {10, 9},
      spawns: {
        (10, PlayMode.free): [_spawn(1), _spawn(2), _spawn(3)],
        (10, PlayMode.near): [_spawn(4)],
        (9, PlayMode.free): [_spawn(5)],
      },
    );
    sessions = _Sessions();
    limiter = _Limiter();
    chooser = _Chooser();
    shots = _Shots();
  });

  Future<PlayResult> start({
    UuidValue? user,
    int revisionId = 10,
    PlayMode mode = PlayMode.free,
    UuidValue? requestId,
    int? entranceId,
  }) {
    final spawnPointId = entranceId ?? (mode == .free ? 1 : null);
    return startPlay().execute(
      user ?? alice,
      revisionId: revisionId,
      mode: mode,
      requestId: requestId ?? _uuid.v4obj(),
      spawnPointId: spawnPointId,
    );
  }

  group('開始', () {
    test('保存した開始点と、createTime の 2 時間後の期限を返す', () async {
      final result = await start();
      expect(result.spawn.id, 1);
      expect(result.session.startedAt, _t0);
      expect(result.session.expiresAt, _t0.add(const Duration(hours: 2)));
      expect(result.session.userProfileId, 1);
      expect(result.shot, isNull);
      expect(sessions.saved, hasLength(1));
    });

    test('free は指定した入口を保存し、候補外と欠落は invalidRequest', () async {
      expect((await start(entranceId: 2)).spawn.id, 2);
      expect(chooser.counts, isEmpty);
      await expectLater(start(entranceId: 99), _fails(.invalidRequest));
      await expectLater(
        startPlay().execute(
          alice,
          revisionId: 10,
          mode: .free,
          requestId: _uuid.v4obj(),
          spawnPointId: null,
        ),
        _fails(.invalidRequest),
      );
      expect(sessions.saved, hasLength(1));
    });

    test('near は入口 ID を受け取らず、唯一の点を返す', () async {
      await expectLater(
        start(mode: PlayMode.near, entranceId: 4),
        _fails(.invalidRequest),
      );
      for (var i = 0; i < 5; i++) {
        chooser.next = i;
        expect((await start(mode: PlayMode.near)).spawn.id, 4);
      }
    });

    test('mode が unknown・版 id が 0 以下・requestId が UUID v4 でないと invalidRequest（何も保存しない）', () async {
      await expectLater(start(mode: PlayMode.unknown), _fails(.invalidRequest));
      await expectLater(start(revisionId: 0), _fails(.invalidRequest));
      for (final id in const [
        '00000000-0000-0000-0000-000000000000', // nil
        '6ba7b810-9dad-11d1-80b4-00c04fd430c8', // v1
        '017f22e2-79b0-7cc3-98c4-dc0c0c07398f', // v7
        '017f22e2-79b0-4cc3-c8c4-dc0c0c07398f', // 版は 4 だが variant が違う
        'ffffffff-ffff-ffff-ffff-ffffffffffff', // max
      ]) {
        await expectLater(
          start(requestId: UuidValue.fromString(id)),
          _fails(.invalidRequest),
          reason: id,
        );
      }
      expect(sessions.saved, isEmpty);
      expect(limiter.acquired, isEmpty);
    });

    test('プロフィールがなければ profileNotInitialized', () async {
      await expectLater(
        start(user: _uuid.v4obj()),
        _fails(.profileNotInitialized),
      );
    });
  });

  group('版の確認', () {
    test(
      'ない版・未公開の下書き版は revisionNotFound（下書きを REVISION_NOT_PLAYABLE で知らせない）',
      () async {
        await expectLater(start(revisionId: 99), _fails(.revisionNotFound));
        challenges.draftRevisions.add(11);
        await expectLater(start(revisionId: 11), _fails(.revisionNotFound));
      },
    );

    test('公開済みの旧版は、現在の版でなければ revisionNotPlayable', () async {
      await expectLater(start(revisionId: 9), _fails(.revisionNotPlayable));
    });

    test('公開が終わった出題は revisionNotPlayable', () async {
      challenges.currentRevisionId = null;
      await expectLater(start(), _fails(.revisionNotPlayable));
    });

    test('near の開始点が 2 件あれば、黙って抽選せず壊れたデータとして扱う', () async {
      challenges.spawns[(10, PlayMode.near)] = [_spawn(4), _spawn(6)];
      await expectLater(
        start(mode: PlayMode.near),
        throwsA(isA<CorruptedDataException>()),
      );
      expect(sessions.saved, isEmpty);
    });

    test('モードに開始点がなければ、壊れたデータとして扱う', () async {
      challenges.spawns.remove((10, PlayMode.near));
      await expectLater(
        start(mode: PlayMode.near),
        throwsA(isA<CorruptedDataException>()),
      );
    });
  });

  group('再送（同じ requestId）', () {
    test('同じ id と開始点を返し、新しい行を増やさない', () async {
      final requestId = _uuid.v4obj();
      final first = await start(requestId: requestId);
      chooser.next = 2; // 引き直されても別の点にならないこと
      final again = await start(requestId: requestId);
      expect(again.session.id, first.session.id);
      expect(again.spawn.id, first.spawn.id);
      expect(sessions.saved, hasLength(1));
    });

    test('再送はレート制限の回数を消費せず、制限中でも返る', () async {
      final requestId = _uuid.v4obj();
      await start(requestId: requestId);
      expect(limiter.acquired, hasLength(1));
      limiter.blockedFor = 30; // 以降は制限中
      final again = await start(requestId: requestId);
      expect(again.session.requestId, requestId);
      expect(limiter.acquired, hasLength(1));
    });

    test('公開が旧版に切り替わった後でも、作成済みのセッションは同じものを返す', () async {
      final requestId = _uuid.v4obj();
      final first = await start(requestId: requestId);
      challenges.currentRevisionId = 9; // 公開版が変わる
      final again = await start(requestId: requestId);
      expect(again.session.id, first.session.id);
      expect(challenges.calls, hasLength(1), reason: '再送では版の確認をやり直さない');
    });

    test('版かモードを変えると requestIdReused', () async {
      final requestId = _uuid.v4obj();
      await start(requestId: requestId);
      await expectLater(
        start(requestId: requestId, mode: PlayMode.near),
        _fails(.requestIdReused),
      );
      await expectLater(
        start(requestId: requestId, revisionId: 9),
        _fails(.requestIdReused),
      );
      await expectLater(
        start(requestId: requestId, entranceId: 2),
        _fails(.requestIdReused),
      );
      await expectLater(
        startPlay().execute(
          alice,
          revisionId: 10,
          mode: .free,
          requestId: requestId,
          spawnPointId: null,
        ),
        _fails(.requestIdReused),
      );
    });

    test('別の利用者の同じ requestId は別のセッション', () async {
      final requestId = _uuid.v4obj();
      final a = await start(requestId: requestId);
      final b = await start(user: bob, requestId: requestId);
      expect(b.session.id, isNot(a.session.id));
      expect(b.session.userProfileId, 2);
    });

    test('並行要求に負けて一意制約違反になったら、保存済みのものを返す', () async {
      final requestId = _uuid.v4obj();
      sessions.racingWinner = PlaySession(
        id: _uuid.v7obj(),
        requestId: requestId,
        revisionId: 10,
        mode: PlayMode.free,
        spawnPointId: 1,
        userProfileId: 1,
        startedAt: _t0,
        expiresAt: _t0.add(const Duration(hours: 2)),
      );
      final result = await start(requestId: requestId);
      expect(result.session.spawnPointId, 1, reason: '負けた側ではなく、保存済みの入口');
      expect(sessions.saved, hasLength(1));
    });

    test('並行要求に負け、入力も違えば requestIdReused', () async {
      final requestId = _uuid.v4obj();
      sessions.racingWinner = PlaySession(
        id: _uuid.v7obj(),
        requestId: requestId,
        revisionId: 10,
        mode: PlayMode.near,
        spawnPointId: 4,
        userProfileId: 1,
        startedAt: _t0,
        expiresAt: _t0.add(const Duration(hours: 2)),
      );
      await expectLater(
        start(requestId: requestId, mode: PlayMode.free),
        _fails(.requestIdReused),
      );
    });
  });

  group('レート制限', () {
    test('新規の開始だけ回数を消費する', () async {
      await start();
      await start();
      expect(limiter.acquired, [1, 1]);
    });

    test('版の確認などで失敗した開始は、回数を使わない', () async {
      await expectLater(start(revisionId: 9), _fails(.revisionNotPlayable));
      await expectLater(start(revisionId: 99), _fails(.revisionNotFound));
      challenges.spawns.remove((10, PlayMode.near));
      await expectLater(
        start(mode: PlayMode.near),
        throwsA(isA<CorruptedDataException>()),
      );
      expect(limiter.acquired, isEmpty);
      await start();
      expect(limiter.acquired, [1]);
    });

    test('超過すると sessionRateLimited と retryAfterSeconds を返し、何も保存しない', () async {
      limiter.blockedFor = 42;
      await expectLater(
        start(),
        throwsA(
          isA<PlayException>()
              .having((e) => e.reason, 'reason', PlayFailure.sessionRateLimited)
              .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', 42),
        ),
      );
      expect(sessions.saved, isEmpty);
    });

    test('制限は版の確認より前（超過中は版が正しくなくても制限が先）', () async {
      limiter.blockedFor = 5;
      await expectLater(start(revisionId: 99), _fails(.sessionRateLimited));
    });
  });

  group('撮影済み（completed）', () {
    Shot shotFor(PlaySession session) => Shot(
      id: 7,
      requestId: _uuid.v4obj(),
      playSessionId: session.id,
      x: 1,
      y: 1.6,
      z: 2,
      yawDeg: 3,
      pitchDeg: 4,
      fovDeg: 50,
      distanceM: 0.5,
      yawDiffDeg: 1,
      pitchDiffDeg: 1,
      score: 900,
      rankAtSubmission: 2,
      bestScoreAtSubmission: 900,
      nicknameAtSubmission: 'n',
      bestAchieveTimeAtSubmission: _t0,
      createdAt: _t0,
    );
    const secrets = RevisionSecrets(
      goal: GoalPose(x: 0, y: 1.6, z: -45, yawDeg: 0, pitchDeg: 8),
      story: 'story',
      highlight: 'highlight',
    );

    test('取得・同じ requestId の再送で、撮影結果と正解・解説を返す', () async {
      final requestId = _uuid.v4obj();
      final started = await start(requestId: requestId);
      shots.byPlaySession[started.session.id] = shotFor(started.session);
      challenges.secrets[10] = secrets;

      for (final result in [
        await getPlay().execute(alice, started.session.id),
        await start(requestId: requestId),
      ]) {
        expect(result.completed, isTrue);
        expect(result.shot!.score, 900);
        expect(result.reveal!.story, 'story');
        expect(result.reveal!.goal.z, -45);
        expect(result.reveal!.verticalFovDeg, 50);
      }
    });

    test('版の正解・解説が欠けていれば、壊れたデータとして扱う', () async {
      final started = await start();
      shots.byPlaySession[started.session.id] = shotFor(started.session);
      challenges.secrets[10] = null; // 版はあるが、秘密がない
      await expectLater(
        getPlay().execute(alice, started.session.id),
        throwsA(isA<CorruptedDataException>()),
      );
      challenges.secrets.remove(10); // 版そのものがない
      await expectLater(
        getPlay().execute(alice, started.session.id),
        throwsA(isA<CorruptedDataException>()),
      );
    });

    test('未撮影なら、正解・解説を含む版を読まない', () async {
      final started = await start();
      final result = await getPlay().execute(alice, started.session.id);
      expect(result.completed, isFalse);
      expect(result.reveal, isNull);
    });
  });

  group('取得', () {
    test('開始したプレイを本人が取得できる（未撮影は shot なし）', () async {
      final started = await start();
      final got = await getPlay().execute(alice, started.session.id);
      expect(got.session.id, started.session.id);
      expect(got.spawn.id, started.spawn.id);
      expect(got.shot, isNull);
    });

    test('期限を過ぎていても取得できる', () async {
      final started = await start();
      clock = _t0.add(const Duration(days: 3));
      expect(
        (await getPlay().execute(alice, started.session.id)).session.id,
        started.session.id,
      );
    });

    test('公開版が切り替わっても取得できる', () async {
      final started = await start();
      challenges.currentRevisionId = 9;
      expect(
        (await getPlay().execute(alice, started.session.id)).session.id,
        started.session.id,
      );
    });

    test('ないプレイは sessionNotFound', () async {
      await expectLater(
        getPlay().execute(alice, _uuid.v4obj()),
        _fails(.sessionNotFound),
      );
    });

    test('他人のプレイは notSessionOwner', () async {
      final started = await start();
      await expectLater(
        getPlay().execute(bob, started.session.id),
        _fails(.notSessionOwner),
      );
    });

    test('プロフィールがなければ profileNotInitialized', () async {
      final started = await start();
      await expectLater(
        getPlay().execute(_uuid.v4obj(), started.session.id),
        _fails(.profileNotInitialized),
      );
    });
  });
}
