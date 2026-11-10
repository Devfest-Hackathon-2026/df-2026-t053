import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_user_profile_repository.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/sqlite_ranking_repository.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'ranking_support.dart';
import 'support.dart';

void main() {
  withDatabase('Given ranking read model', (builder) {
    late Session session;
    late SqliteRankingRepository repo;
    setUp(() {
      session = builder.build();
      repo = SqliteRankingRepository(session);
    });

    test('点数・達成時刻・プロフィールIDの順をListと本人Getで共通にする', () async {
      final f = await insertFixture(session);
      final b = await insertProfile(session);
      final c = await insertProfile(session);
      final d = await insertProfile(session);
      await insertRankedScore(session, f, score: 900);
      await insertRankedScore(
        session,
        f,
        profile: b,
        score: 900,
        achievedAt: t0.subtract(const Duration(milliseconds: 1)),
      );
      await insertRankedScore(session, f, profile: c, score: 950);
      await insertRankedScore(session, f, profile: d, score: 900);
      final list = await repo.listTop(
        revisionId: f.revision.id!,
        mode: .free,
        limit: 100,
      );
      expect(list.map((r) => r.userProfileId), [
        c.id,
        b.id,
        f.profile.id,
        d.id,
      ]);
      expect(list.map((r) => r.rank), [1, 2, 3, 4]);
      for (final row in list) {
        final mine = await repo.findMine(
          revisionId: f.revision.id!,
          mode: .free,
          userProfileId: row.userProfileId,
        );
        expect(mine?.rank, row.rank);
        expect(mine?.nickname, row.nickname);
        expect(mine?.achievedAt, row.achievedAt);
        expect(mine?.achievedAt.isUtc, isTrue);
      }
    });

    test('保存精度以下の日時差は同点としてIDで整列する', () async {
      final f = await insertFixture(session);
      final b = await insertProfile(session);
      await insertRankedScore(
        session,
        f,
        achievedAt: t0.add(const Duration(microseconds: 900)),
      );
      await insertRankedScore(
        session,
        f,
        profile: b,
        achievedAt: t0.add(const Duration(microseconds: 100)),
      );
      final list = await repo.listTop(
        revisionId: f.revision.id!,
        mode: .free,
        limit: 100,
      );
      expect(list.map((r) => r.userProfileId), [f.profile.id, b.id]);
      expect(list.map((r) => r.achievedAt), [t0, t0]);
      expect(
        (await repo.findMine(
          revisionId: f.revision.id!,
          mode: .free,
          userProfileId: b.id!,
        ))?.rank,
        2,
      );
    });

    test('100件は全件、101件目は一覧に含めず本人Getで返す', () async {
      final f = await insertFixture(session);
      for (var i = 0; i < 100; i++) {
        final profile = i == 0 ? f.profile : await insertProfile(session);
        await insertRankedScore(session, f, profile: profile, score: 1000 - i);
      }
      expect(
        await repo.listTop(revisionId: f.revision.id!, mode: .free, limit: 100),
        hasLength(100),
      );
      final last = await insertProfile(session);
      await insertRankedScore(session, f, profile: last, score: 800);
      final top = await repo.listTop(
        revisionId: f.revision.id!,
        mode: .free,
        limit: 100,
      );
      expect(top, hasLength(100));
      expect(top.last.rank, 100);
      expect(top.where((r) => r.userProfileId == last.id), isEmpty);
      expect(
        (await repo.findMine(
          revisionId: f.revision.id!,
          mode: .free,
          userProfileId: last.id!,
        ))?.rank,
        101,
      );
    });

    test('別の版とモードを混在させず、記録なしをnullと空一覧で返す', () async {
      final f = await insertFixture(session);
      final other = await insertFixture(session);
      final mode = await insertModeConfig(
        session,
        revision: f.revision,
        mode: .near,
      );
      final spawn = await insertSpawn(session, modeConfig: mode);
      final near = Fixture(f.challenge, f.revision, mode, spawn, f.profile);
      await insertRankedScore(session, f, score: 400);
      await insertRankedScore(session, other, profile: f.profile, score: 999);
      await insertRankedScore(session, near, score: 700);
      final free = await repo.listTop(
        revisionId: f.revision.id!,
        mode: .free,
        limit: 100,
      );
      expect(free.single.score, 400);
      expect(
        (await repo.listTop(
          revisionId: f.revision.id!,
          mode: .near,
          limit: 100,
        )).single.score,
        700,
      );
      expect(
        await repo.findMine(
          revisionId: f.revision.id!,
          mode: .free,
          userProfileId: other.profile.id!,
        ),
        isNull,
      );
      expect(
        await repo.listTop(revisionId: 999999, mode: .free, limit: 100),
        isEmpty,
      );
      expect(await repo.publishedRevisionExists(999999), isFalse);
      // 下書きの版は、存在を公開しないため「ない」と同じ扱いにする。
      expect(f.revision.publishedAt, isNull);
      expect(await repo.publishedRevisionExists(f.revision.id!), isFalse);
      await publishFixture(session, f);
      expect(await repo.publishedRevisionExists(f.revision.id!), isTrue);
    });

    test('公開終了（出題の現在版が外れた）後も、公開済みの版として読める', () async {
      final f = await insertFixture(session);
      await publishFixture(session, f);
      final live = await ChallengeRow.db.updateRow(
        session,
        f.challenge.copyWith(currentRevisionId: f.revision.id),
      );
      expect(await repo.publishedRevisionExists(f.revision.id!), isTrue);
      await ChallengeRow.db.updateRow(
        session,
        live.copyWith(currentRevisionId: null),
      );
      expect(await repo.publishedRevisionExists(f.revision.id!), isTrue);
    });

    test('現在の名前を返し、撮影時スナップショットを更新しない', () async {
      final f = await insertFixture(session);
      final shot = await insertRankedScore(session, f);
      final before = shot.toJson();
      await OrmUserProfileRepository(session)
          .updateNickname(f.profile.id!, '変更後の名前');
      expect(
        (await repo.listTop(
          revisionId: f.revision.id!,
          mode: .free,
          limit: 100,
        )).single.nickname,
        '変更後の名前',
      );
      expect(
        (await repo.findMine(
          revisionId: f.revision.id!,
          mode: .free,
          userProfileId: f.profile.id!,
        ))?.nickname,
        '変更後の名前',
      );
      expect((await ShotRow.db.findById(session, shot.id!))?.toJson(), before);
    });

    test('Listと本人Getの実クエリがランキング索引を使う', () async {
      final f = await insertFixture(session);
      for (final query in [listRankingSql, myRankingSql]) {
        final plan = await session.db.unsafeQuery(
          'EXPLAIN QUERY PLAN $query',
          parameters: QueryParameters.named({
            'revisionId': f.revision.id!,
            'mode': 'free',
            if (query == listRankingSql)
              'limit': 100
            else
              'profileId': f.profile.id!,
          }),
        );
        final details = plan.map((r) => r.last.toString()).join('\n');
        expect(details, contains('best_score_ranking_idx'));
        expect(details, isNot(contains('USE TEMP B-TREE FOR ORDER BY')));
      }
    });
  });
}
