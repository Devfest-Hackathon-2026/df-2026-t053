import 'package:photohunt_server/src/application/usecase/get_challenge.dart';
import 'package:photohunt_server/src/application/usecase/get_challenge_revision.dart';
import 'package:photohunt_server/src/application/usecase/list_challenges.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/models.dart';
import 'package:photohunt_server/src/domain/repositories/challenge_repository.dart';
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

class _FakeRepository({
  final Map<int, Challenge> challenges = const {},
  final Map<int, ChallengeRevision> revisions = const {},
}) implements ChallengeRepository {
  @override
  Future<List<Challenge>> listPublished() async => [
    for (final c in challenges.values)
      if (c.currentRevisionId != null) c,
  ]..sort((a, b) => a.id.compareTo(b.id));

  @override
  Future<Challenge?> findById(int id) async => challenges[id];

  @override
  Future<Challenge?> findPublicById(int id) async {
    final challenge = challenges[id];
    if (challenge == null) return null;
    final everPublished =
        challenge.currentRevisionId != null ||
        revisions.values.any(
          (r) => r.challengeId == id && r.publishedAt != null,
        );
    return everPublished ? challenge : null;
  }

  @override
  Future<ChallengeRevision?> findRevision(int revisionId) async =>
      revisions[revisionId];

  @override
  Future<ChallengeRevision?> findPublishedRevision(int revisionId) async {
    final revision = revisions[revisionId];
    return revision?.publishedAt == null ? null : revision;
  }

  @override
  Future<({int challengeId, bool published})?> findRevisionStatus(
    int revisionId,
  ) => throw StateError('出題の取得は版の状態だけを読まない');

  @override
  Future<List<SpawnPoint>> listSpawnPoints(int revisionId, PlayMode mode) =>
      throw StateError('出題の取得は開始点を読まない');

  @override
  Future<SpawnPoint?> findSpawnPoint(int spawnPointId) =>
      throw StateError('出題の取得は開始点を読まない');

  @override
  Future<ChallengeRevision?> findRevisionWithSecrets(int revisionId) =>
      throw StateError('出題の取得は秘密を読まない');
}

Challenge _challenge(int id, {int? current}) => Challenge(
  id: id,
  slug: 's$id',
  title: 't$id',
  currentRevisionId: current,
  createdAt: DateTime.utc(2026),
);

final _asset = Asset(
  id: 1,
  sha256: 'a' * 64,
  objectPath: 'media/${'a' * 64}/photo.png',
  contentType: 'image/png',
  byteLength: 10,
  createdAt: DateTime.utc(2026),
);

ChallengeRevision _revision(int id, {DateTime? publishedAt}) =>
    ChallengeRevision(
      id: id,
      challengeId: 1,
      revisionNo: id,
      sceneProfile: 'bundled-v1',
      scoringVersion: 'v1',
      photo: _asset,
      map: _asset,
      photoAlt: 'alt',
      mapBounds: MapBounds(minX: 0, minZ: 0, maxX: 1, maxZ: 1),
      eyeHeightM: 1.6,
      shotFovDeg: 50,
      publishedAt: publishedAt,
      createdAt: DateTime.utc(2026),
      modes: const [],
      landmarks: const [],
      credits: const [],
      secrets: null,
    );

Matcher _fails(ChallengeFailure reason) => throwsA(
  isA<ChallengeException>().having((e) => e.reason, 'reason', reason),
);

void main() {
  test('listChallenges は公開中の出題だけを id の昇順で返し、0 件なら空', () async {
    expect(await ListChallenges(_FakeRepository()).execute(), isEmpty);
    final repo = _FakeRepository(
      challenges: {
        3: _challenge(3, current: 30),
        1: _challenge(1, current: 10),
        2: _challenge(2),
      },
    );
    expect((await ListChallenges(repo).execute()).map((c) => c.id), [1, 3]);
  });

  group('getChallenge', () {
    final repo = _FakeRepository(
      challenges: {
        1: _challenge(1), // 公開が終わった出題（公開済みの版は残っている）
        2: _challenge(2), // 一度も公開されていない出題（下書きだけ）
        3: _challenge(3, current: 30), // 公開中
      },
      revisions: {10: _revision(10, publishedAt: DateTime.utc(2026, 11, 1))},
    );

    test('公開終了した出題は currentRevisionId が null のまま返す', () async {
      expect((await GetChallenge(repo).execute(1)).currentRevisionId, isNull);
    });

    test('公開中の出題を返す', () async {
      expect((await GetChallenge(repo).execute(3)).currentRevisionId, 30);
    });

    test('一度も公開されていない出題は、ない場合と同じ challengeNotFound', () async {
      await expectLater(
        GetChallenge(repo).execute(2),
        _fails(.challengeNotFound),
      );
    });

    test('ない出題は challengeNotFound', () async {
      await expectLater(
        GetChallenge(repo).execute(99),
        _fails(.challengeNotFound),
      );
    });

    test('0 以下の ID は invalidRequest', () async {
      await expectLater(GetChallenge(repo).execute(0), _fails(.invalidRequest));
      await expectLater(
        GetChallenge(repo).execute(-1),
        _fails(.invalidRequest),
      );
    });
  });

  group('getChallengeRevision', () {
    final repo = _FakeRepository(
      revisions: {
        1: _revision(1, publishedAt: DateTime.utc(2026, 11, 1)), // 公開済みの旧版
        2: _revision(2), // 未公開の下書き
      },
    );

    test('公開済みの旧版も返す', () async {
      expect((await GetChallengeRevision(repo).execute(1)).id, 1);
    });

    test('未公開の下書き版は、版がない場合と同じ revisionNotFound', () async {
      await expectLater(
        GetChallengeRevision(repo).execute(2),
        _fails(.revisionNotFound),
      );
      await expectLater(
        GetChallengeRevision(repo).execute(3),
        _fails(.revisionNotFound),
      );
    });

    test('0 以下の ID は invalidRequest', () async {
      await expectLater(
        GetChallengeRevision(repo).execute(0),
        _fails(.invalidRequest),
      );
    });
  });
}
