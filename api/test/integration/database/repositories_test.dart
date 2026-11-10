import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/models.dart';
import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_best_score_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_challenge_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_play_session_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_shot_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_structure_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_user_profile_repository.dart';
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
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'support.dart';

/// repository の各メソッドを、実 SQLite（migration 適用済み）で確認する。
void main() {
  withDatabase('Given repository', (sessionBuilder) {
    late Session s;
    setUp(() => s = sessionBuilder.build());

    group('ChallengeRepository', () {
      test('モデル素材なしで版を登録し、写真・会場図・sceneProfileを読み取れる', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        expect(await AssetRow.db.count(s), 2);
        final revision = await OrmChallengeRepository(s).findRevision(r.id!);
        expect(revision?.sceneProfile, 'profile-a');
        expect(revision?.photo.id, r.photoAssetId);
        expect(revision?.map.id, r.mapAssetId);
      });

      test('listPublished は公開中の出題だけを id 昇順で返す', () async {
        final draft = await insertChallenge(s, slug: 'draft');
        final a = await insertChallenge(s, slug: 'a');
        final b = await insertChallenge(s, slug: 'b');
        for (final c in [b, a]) {
          // current_revision_id は公開済みの版だけを指せる（#26 のトリガー）。
          final r = await insertRevision(s, challenge: c, publishedAt: t0);
          await ChallengeRow.db.updateRow(
            s,
            c.copyWith(currentRevisionId: r.id),
          );
        }
        final repo = OrmChallengeRepository(s);
        final list = await repo.listPublished();
        expect(list.map((c) => c.slug), ['a', 'b']);
        expect(list.map((c) => c.id), [a.id, b.id]);
        expect(list.every((c) => c.currentRevisionId != null), isTrue);
        expect((await repo.findById(draft.id!))!.currentRevisionId, isNull);
        expect(await repo.findById(999999), isNull);
      });

      test('findRevision は子データを含み、秘密は読まない', () async {
        final c = await insertChallenge(s);
        // 子データは下書きのうちに入れ、最後に公開する（公開後の追加は #26 のトリガーが拒否する）。
        final r = await insertRevision(s, challenge: c);
        final free = await insertModeConfig(s, revision: r);
        final near = await insertModeConfig(
          s,
          revision: r,
          mode: PlayMode.near,
          walkable: walkableJson(walkableSolid),
        );
        await insertSpawn(s, modeConfig: free, sortOrder: 1);
        await insertSpawn(s, modeConfig: free, sortOrder: 0);
        await insertSpawn(s, modeConfig: near);
        final p = await insertPavilion(s);
        await LandmarkRow.db.insertRow(
          s,
          LandmarkRow(
            revisionId: r.id!,
            pavilionId: p.id!,
            displayName: 'パビリオン',
            posX: 1,
            posZ: 2,
            lat: 34.65,
            lon: 135.4,
          ),
        );
        await CreditRow.db.insertRow(
          s,
          CreditRow(revisionId: r.id!, name: 'B', sortOrder: 1),
        );
        await CreditRow.db.insertRow(
          s,
          CreditRow(
            revisionId: r.id!,
            name: 'A',
            url: 'https://example.com',
            sortOrder: 0,
          ),
        );

        await ChallengeRevisionRow.db.updateRow(s, r.copyWith(publishedAt: t0));

        final rev = await OrmChallengeRepository(s).findRevision(r.id!);
        expect(rev, isNotNull);
        expect(rev!.secrets, isNull);
        expect(rev.challengeId, c.id);
        expect(rev.revisionNo, 1);
        expect(rev.publishedAt, t0);
        expect(rev.mapBounds.maxX, 50.5);
        expect(rev.photo.id, r.photoAssetId);
        expect(rev.map.id, r.mapAssetId);
        expect(rev.modes.map((m) => m.mode), [PlayMode.free, PlayMode.near]);
        expect(rev.modes.first.walkable.holes, hasLength(1));
        expect(rev.modes.last.walkable.holes, isEmpty);
        expect(rev.modes.first.spawnPoints.map((p) => p.sortOrder), [0, 1]);
        expect(rev.modes.last.spawnPoints, hasLength(1));
        expect(rev.landmarks.single.displayName, 'パビリオン');
        expect(rev.landmarks.single.lat, 34.65);
        expect(rev.credits.map((c) => c.name), ['A', 'B']);
        expect(rev.credits.first.url, 'https://example.com');
        expect(await OrmChallengeRepository(s).findRevision(999999), isNull);
      });

      test('findRevisionWithSecrets は正解姿勢・story・highlight を含む', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        final rev = await OrmChallengeRepository(s)
            .findRevisionWithSecrets(r.id!);
        final secrets = rev!.secrets!;
        expect(secrets.goal.x, 1.5);
        expect(secrets.goal.y, 1.6);
        expect(secrets.goal.z, 2.5);
        expect(secrets.goal.yawDeg, 90);
        expect(secrets.goal.pitchDeg, -5);
        expect(secrets.story, 'story text');
        expect(secrets.highlight, 'highlight text');
      });

      test('壊れた JSON の版は CorruptedDataException', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        // JSON としては正しいが、WalkableArea ではない値。
        await insertModeConfig(s, revision: r, walkable: '{"outer": "x"}');
        await expectLater(
          OrmChallengeRepository(s).findRevision(r.id!),
          throwsA(isA<CorruptedDataException>()),
        );
      });
    });

    group('findPublicById', () {
      test('公開中・公開が終わった出題は返し、下書きだけの出題とない出題は null', () async {
        final repo = OrmChallengeRepository(s);
        final live = await insertChallenge(s, slug: 'live');
        final liveRevision = await insertRevision(
          s,
          challenge: live,
          publishedAt: t0,
        );
        await ChallengeRow.db.updateRow(
          s,
          live.copyWith(currentRevisionId: liveRevision.id),
        );
        final ended = await insertChallenge(s, slug: 'ended');
        await insertRevision(s, challenge: ended, publishedAt: t0);
        final draft = await insertChallenge(s, slug: 'draft');
        await insertRevision(s, challenge: draft);
        final empty = await insertChallenge(s, slug: 'empty');

        expect(
          (await repo.findPublicById(live.id!))?.currentRevisionId,
          isNotNull,
        );
        final endedResult = await repo.findPublicById(ended.id!);
        expect(endedResult, isNotNull);
        expect(endedResult!.currentRevisionId, isNull);
        expect(await repo.findPublicById(draft.id!), isNull);
        expect(await repo.findPublicById(empty.id!), isNull);
        expect(await repo.findPublicById(999999), isNull);
        // 管理用の findById は、下書きだけの出題も返す。
        expect(await repo.findById(draft.id!), isNotNull);
      });
    });

    group('findPublishedRevision', () {
      test('未公開の下書きは、子データが壊れていても読み込まず null を返す', () async {
        final c = await insertChallenge(s);
        final draft = await insertRevision(s, challenge: c);
        await insertModeConfig(s, revision: draft, walkable: '{"outer": "x"}');
        final repo = OrmChallengeRepository(s);
        expect(await repo.findPublishedRevision(draft.id!), isNull);
        // 同じ下書きを findRevision で読むと、壊れた JSON で失敗する（読み込んでいる証拠）。
        await expectLater(
          repo.findRevision(draft.id!),
          throwsA(isA<CorruptedDataException>()),
        );
      });

      test('公開済みの版は子データごと返し、ない版は null', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c, publishedAt: t0);
        final repo = OrmChallengeRepository(s);
        final revision = await repo.findPublishedRevision(r.id!);
        expect(revision?.id, r.id);
        expect(revision?.secrets, isNull);
        expect(await repo.findPublishedRevision(999999), isNull);
      });
    });

    group('UserProfileRepository', () {
      test('insert・findByAuthUserId・updateNickname', () async {
        final repo = OrmUserProfileRepository(s);
        final authUserId = const Uuid().v4obj();
        expect(await repo.findByAuthUserId(authUserId), isNull);

        final saved = await repo.insert(
          UserProfile(
            id: null,
            authUserId: authUserId,
            nickname: 'まる',
            createdAt: t0,
          ),
        );
        expect(saved.id, isNotNull);
        expect(saved.authUserId, authUserId);
        expect(saved.nickname, 'まる');
        expect(saved.createdAt, t0);

        final found = await repo.findByAuthUserId(authUserId);
        expect(found!.id, saved.id);

        final renamed = await repo.updateNickname(saved.id!, 'さんかく');
        expect(renamed!.nickname, 'さんかく');
        expect((await repo.findByAuthUserId(authUserId))!.nickname, 'さんかく');
        expect(await repo.updateNickname(999999, 'x'), isNull);
      });

      test('auth_user_id の重複は ProfileAlreadyExistsException', () async {
        final repo = OrmUserProfileRepository(s);
        final authUserId = const Uuid().v4obj();
        UserProfile profile() => UserProfile(
          id: null,
          authUserId: authUserId,
          nickname: 'n',
          createdAt: t0,
        );
        await repo.insert(profile());
        await expectLater(
          repo.insert(profile()),
          throwsA(isA<ProfileAlreadyExistsException>()),
        );
      });
    });

    group('PlaySessionRepository', () {
      PlaySession session(Fixture f, {UuidValue? requestId}) => PlaySession(
        id: const Uuid().v7obj(),
        requestId: requestId ?? const Uuid().v4obj(),
        revisionId: f.revision.id!,
        mode: PlayMode.near,
        spawnPointId: f.spawn.id!,
        userProfileId: f.profile.id!,
        startedAt: t0,
        expiresAt: t0.add(const Duration(minutes: 30)),
      );

      test('insert・findById・findByRequestId', () async {
        final f = await insertFixture(s);
        final repo = OrmPlaySessionRepository(s);
        final input = session(f);
        final saved = await repo.insert(input);
        expect(saved.id, input.id);
        expect(saved.requestId, input.requestId);
        expect(saved.mode, PlayMode.near);
        expect(saved.startedAt, t0);
        expect(saved.expiresAt, t0.add(const Duration(minutes: 30)));

        expect((await repo.findById(input.id))!.userProfileId, f.profile.id);
        expect(await repo.findById(const Uuid().v7obj()), isNull);

        final byRequest = await repo.findByRequestId(
          f.profile.id!,
          input.requestId,
        );
        expect(byRequest!.id, input.id);
        // 別の本人の同じ requestId は見えない。
        final other = await insertProfile(s);
        expect(await repo.findByRequestId(other.id!, input.requestId), isNull);
      });

      test('同じ (本人, requestId) の 2 行目は DuplicateEntityException', () async {
        final f = await insertFixture(s);
        final repo = OrmPlaySessionRepository(s);
        final requestId = const Uuid().v4obj();
        await repo.insert(session(f, requestId: requestId));
        await expectLater(
          repo.insert(session(f, requestId: requestId)),
          throwsDuplicate('play_session', 'play_session_profile_request_uk'),
        );
      });
    });

    group('ShotRepository', () {
      Shot shot(PlaySessionRow play, {int score = 640}) => Shot(
        id: null,
        requestId: const Uuid().v4obj(),
        playSessionId: play.id!,
        x: 1.25,
        y: 1.6,
        z: -2.5,
        yawDeg: 12.5,
        pitchDeg: -3,
        fovDeg: 60,
        distanceM: 4.75,
        yawDiffDeg: 2.5,
        pitchDiffDeg: 0.5,
        score: score,
        rankAtSubmission: 3,
        bestScoreAtSubmission: 700,
        nicknameAtSubmission: 'まる',
        bestAchieveTimeAtSubmission: t0,
        createdAt: t0,
      );

      test('insert・findByPlaySessionId', () async {
        final f = await insertFixture(s);
        final play = await insertPlaySession(s, f);
        final repo = OrmShotRepository(s);
        expect(await repo.findByPlaySessionId(play.id!), isNull);

        final saved = await repo.insert(shot(play));
        expect(saved.id, isNotNull);
        expect(saved.score, 640);
        expect(saved.x, 1.25);
        expect(saved.z, -2.5);
        expect(saved.nicknameAtSubmission, 'まる');
        expect(saved.bestAchieveTimeAtSubmission, t0);

        final found = await repo.findByPlaySessionId(play.id!);
        expect(found!.id, saved.id);
        expect(found.playSessionId, play.id);
      });

      test('同じプレイへの 2 行目は DuplicateEntityException', () async {
        final f = await insertFixture(s);
        final play = await insertPlaySession(s, f);
        final repo = OrmShotRepository(s);
        await repo.insert(shot(play));
        await expectLater(
          repo.insert(shot(play)),
          throwsDuplicate('shot', 'shot_play_session_uk'),
        );
      });
    });

    group('BestScoreRepository', () {
      /// 同じ版・モードに、指定の (score, achievedAt) の自己ベストを持つ本人を作る。
      Future<BestScore> addBest(
        Fixture f, {
        required int score,
        required DateTime achievedAt,
        PlayMode mode = PlayMode.free,
        UserProfileRow? profile,
      }) async {
        final user = profile ?? await insertProfile(s);
        final play = await PlaySessionRow.db.insertRow(
          s,
          PlaySessionRow(
            id: const Uuid().v7obj(),
            requestId: const Uuid().v4obj(),
            revisionId: f.revision.id!,
            mode: mode,
            spawnPointId: f.spawn.id!,
            userProfileId: user.id!,
            startedAt: t0,
            expiresAt: t0,
          ),
        );
        final shot = await insertShotRow(s, play, score: score);
        return OrmBestScoreRepository(s).upsert(
          BestScore(
            id: null,
            userProfileId: user.id!,
            revisionId: f.revision.id!,
            mode: mode,
            shotId: shot.id!,
            score: score,
            achievedAt: achievedAt,
          ),
        );
      }

      test('upsert は作成し、同じ (本人, 版, モード) なら置き換える', () async {
        final f = await insertFixture(s);
        final repo = OrmBestScoreRepository(s);
        expect(
          await repo.find(f.profile.id!, f.revision.id!, PlayMode.free),
          isNull,
        );

        final first = await addBest(
          f,
          score: 300,
          achievedAt: t0,
          profile: f.profile,
        );
        expect(first.id, isNotNull);
        expect(first.mode, PlayMode.free);

        // 同じ本人・版・モードで、より高い点の撮影に置き換える。
        final play = await insertPlaySession(s, f);
        final better = await insertShotRow(s, play, score: 800);
        final later = t0.add(const Duration(minutes: 5));
        final replaced = await repo.upsert(
          BestScore(
            id: null,
            userProfileId: f.profile.id!,
            revisionId: f.revision.id!,
            mode: PlayMode.free,
            shotId: better.id!,
            score: 800,
            achievedAt: later,
          ),
        );
        expect(replaced.id, first.id);
        final found = await repo.find(
          f.profile.id!,
          f.revision.id!,
          PlayMode.free,
        );
        expect(found!.score, 800);
        expect(found.shotId, better.id);
        expect(found.achievedAt, later);
        expect(await BestScoreRow.db.count(s), 1);
        // 別モードは別の行。
        expect(
          await repo.find(f.profile.id!, f.revision.id!, PlayMode.near),
          isNull,
        );
      });

      test('listTop は score 降順 → achievedAt 昇順 → userProfileId 昇順', () async {
        final f = await insertFixture(s);
        final at = t0;
        final later = t0.add(const Duration(seconds: 1));
        final low = await addBest(f, score: 100, achievedAt: at);
        final tieLate = await addBest(f, score: 500, achievedAt: later);
        final tieEarlyB = await addBest(f, score: 500, achievedAt: at);
        final tieEarlyA = await addBest(f, score: 500, achievedAt: at);
        final top = await addBest(f, score: 900, achievedAt: later);
        // 別モード・別版は含まれない。
        await addBest(f, score: 1000, achievedAt: at, mode: PlayMode.near);

        final repo = OrmBestScoreRepository(s);
        final list = await repo.listTop(f.revision.id!, PlayMode.free, 100);
        expect(list.map((b) => b.id), [
          top.id,
          tieEarlyB.id, // 同点・同時刻は userProfileId の昇順（B が先に作られた）
          tieEarlyA.id,
          tieLate.id,
          low.id,
        ]);
        expect(tieEarlyB.userProfileId, lessThan(tieEarlyA.userProfileId));

        final limited = await repo.listTop(f.revision.id!, PlayMode.free, 2);
        expect(limited.map((b) => b.id), [top.id, tieEarlyB.id]);
        expect(
          await repo.listTop(f.revision.id!, PlayMode.near, 100),
          hasLength(1),
        );
        expect(await repo.listTop(999999, PlayMode.free, 100), isEmpty);
      });

      test('rankOf は listTop と同じ並び順の 1 始まりの順位', () async {
        final f = await insertFixture(s);
        final later = t0.add(const Duration(seconds: 1));
        final entries = [
          await addBest(f, score: 900, achievedAt: later),
          await addBest(f, score: 500, achievedAt: t0),
          await addBest(f, score: 500, achievedAt: t0),
          await addBest(f, score: 500, achievedAt: later),
          await addBest(f, score: 100, achievedAt: t0),
        ];
        final repo = OrmBestScoreRepository(s);
        final listed = await repo.listTop(f.revision.id!, PlayMode.free, 100);
        for (var i = 0; i < listed.length; i++) {
          final b = listed[i];
          final rank = await repo.rankOf(
            revisionId: b.revisionId,
            mode: b.mode,
            score: b.score,
            achievedAt: b.achievedAt,
            userProfileId: b.userProfileId,
          );
          expect(rank, i + 1, reason: 'entry $i');
        }
        expect(entries, hasLength(5));
        // まだ記録のない人の点数でも順位が出る（撮影時順位の予定値）。
        expect(
          await repo.rankOf(
            revisionId: f.revision.id!,
            mode: PlayMode.free,
            score: 1000,
            achievedAt: t0,
            userProfileId: 1 << 30,
          ),
          1,
        );
        expect(
          await repo.rankOf(
            revisionId: f.revision.id!,
            mode: PlayMode.free,
            score: 0,
            achievedAt: t0,
            userProfileId: 1 << 30,
          ),
          6,
        );
      });
    });

    group('StructureRepository', () {
      test('listByRevision は構造物を id 昇順、出典を sortOrder 昇順で返す', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        final other = await insertRevision(s, challenge: c, revisionNo: 2);
        final p = await insertPavilion(s);
        Future<StructureRow> add(
          ChallengeRevisionRow rev,
          String name, {
          int? pavilionId,
        }) => StructureRow.db.insertRow(
          s,
          StructureRow(
            revisionId: rev.id!,
            pavilionId: pavilionId,
            name: name,
            posX: 1.5,
            posZ: -2.5,
            facts: 'facts $name',
            fallbackText: 'fallback $name',
          ),
        );
        final first = await add(r, 'first', pavilionId: p.id);
        final second = await add(r, 'second');
        await add(other, 'other-revision');
        for (final (title, order) in [('B', 1), ('A', 0)]) {
          await StructureSourceRow.db.insertRow(
            s,
            StructureSourceRow(
              structureId: first.id!,
              title: title,
              url: 'https://example.com/$title',
              sortOrder: order,
            ),
          );
        }

        final repo = OrmStructureRepository(s);
        final list = await repo.listByRevision(r.id!);
        expect(list.map((e) => e.name), ['first', 'second']);
        expect(list.first.id, first.id);
        expect(list.first.pavilionId, p.id);
        expect(list.first.sources.map((e) => e.title), ['A', 'B']);
        expect(list.first.posX, 1.5);
        expect(list.last.id, second.id);
        expect(list.last.pavilionId, isNull);
        expect(list.last.sources, isEmpty);
        expect(await repo.listByRevision(999999), isEmpty);
      });
    });

    test('transaction を渡すと、その中の書き込みが rollback される', () async {
      final f = await insertFixture(s);
      final requestId = const Uuid().v4obj();
      PlaySession session() => PlaySession(
        id: const Uuid().v7obj(),
        requestId: requestId,
        revisionId: f.revision.id!,
        mode: PlayMode.free,
        spawnPointId: f.spawn.id!,
        userProfileId: f.profile.id!,
        startedAt: t0,
        expiresAt: t0,
      );
      await expectLater(
        s.db.transaction((tx) async {
          final repo = OrmPlaySessionRepository(s, transaction: tx);
          await repo.insert(session());
          expect(
            await repo.findByRequestId(f.profile.id!, requestId),
            isNotNull,
          );
          throw StateError('abort');
        }),
        throwsStateError,
      );
      expect(
        await OrmPlaySessionRepository(s)
            .findByRequestId(f.profile.id!, requestId),
        isNull,
      );
    });
  });
}
