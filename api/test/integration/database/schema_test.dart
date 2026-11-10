import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'support.dart';

/// migration が作るスキーマ（外部キーの動作・CHECK・索引）を確認する。
void main() {
  withDatabase('Given migration 済みのスキーマ', (sessionBuilder) {
    late Session s;
    setUp(() => s = sessionBuilder.build());

    Future<int> count(String table) async {
      final r = await sql(s, 'SELECT count(*) FROM "$table"');
      return r.first.first! as int;
    }

    test('foreign_key_check が空', () async {
      await insertFixture(s);
      expect(await sql(s, 'PRAGMA foreign_key_check'), isEmpty);
    });

    test('存在しない親を参照する行は挿入できない（foreign_keys=ON）', () async {
      await expectLater(
        SpawnPointRow.db.insertRow(
          s,
          SpawnPointRow(
            modeConfigId: 9999,
            x: 0,
            y: 0,
            z: 0,
            yawDeg: 0,
            sortOrder: 0,
          ),
        ),
        throwsA(isA<DatabaseQueryException>()),
      );
    });

    group('Restrict', () {
      test('play_session が参照する版は削除できない', () async {
        final f = await insertFixture(s);
        await insertPlaySession(s, f);
        await expectLater(
          ChallengeRevisionRow.db.deleteRow(s, f.revision),
          throwsA(isA<DatabaseQueryException>()),
        );
        expect(await count('challenge_revision'), 1);
      });

      test('play_session が参照する開始点は削除できない', () async {
        final f = await insertFixture(s);
        await insertPlaySession(s, f);
        await expectLater(
          SpawnPointRow.db.deleteRow(s, f.spawn),
          throwsA(isA<DatabaseQueryException>()),
        );
        // 開始点を巻き込む版の削除（Cascade）も止まる。
        await expectLater(
          ModeConfigRow.db.deleteRow(s, f.modeConfig),
          throwsA(isA<DatabaseQueryException>()),
        );
        expect(await count('spawn_point'), 1);
      });

      test('版が参照する asset・pavilion は削除できない', () async {
        final c = await insertChallenge(s);
        final photo = await insertAsset(s);
        await insertRevision(s, challenge: c, photo: photo);
        await expectLater(
          AssetRow.db.deleteRow(s, photo),
          throwsA(isA<DatabaseQueryException>()),
        );

        final r = (await ChallengeRevisionRow.db.find(s)).single;
        final p = await insertPavilion(s);
        await LandmarkRow.db.insertRow(
          s,
          LandmarkRow(
            revisionId: r.id!,
            pavilionId: p.id!,
            displayName: 'name',
            posX: 0,
            posZ: 0,
          ),
        );
        await expectLater(
          PavilionRow.db.deleteRow(s, p),
          throwsA(isA<DatabaseQueryException>()),
        );
      });

      test('公開中の版（challenge.current_revision_id）は削除できない', () async {
        final c = await insertChallenge(s);
        // current_revision_id は公開済みの版だけを指せる（#26 のトリガー）。
        final r = await insertRevision(s, challenge: c, publishedAt: t0);
        await ChallengeRow.db.updateRow(s, c.copyWith(currentRevisionId: r.id));
        await expectLater(
          ChallengeRevisionRow.db.deleteRow(s, r),
          throwsA(isA<DatabaseQueryException>()),
        );
      });
    });

    group('Cascade', () {
      test('未公開版を削除すると子が消える', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        final m = await insertModeConfig(s, revision: r);
        await insertSpawn(s, modeConfig: m);
        final p = await insertPavilion(s);
        await LandmarkRow.db.insertRow(
          s,
          LandmarkRow(
            revisionId: r.id!,
            pavilionId: p.id!,
            displayName: 'n',
            posX: 0,
            posZ: 0,
          ),
        );
        await CreditRow.db.insertRow(
          s,
          CreditRow(revisionId: r.id!, name: 'c', sortOrder: 0),
        );
        final st = await StructureRow.db.insertRow(
          s,
          StructureRow(
            revisionId: r.id!,
            name: 's',
            posX: 0,
            posZ: 0,
            facts: 'f',
            fallbackText: 't',
          ),
        );
        await StructureSourceRow.db.insertRow(
          s,
          StructureSourceRow(
            structureId: st.id!,
            title: 't',
            url: 'https://example.com',
            sortOrder: 0,
          ),
        );

        await ChallengeRevisionRow.db.deleteRow(s, r);

        for (final table in [
          'challenge_revision',
          'mode_config',
          'spawn_point',
          'landmark',
          'credit',
          'structure',
          'structure_source',
        ]) {
          expect(await count(table), 0, reason: table);
        }
        // 写真・会場図のasset、pavilionと親のchallengeは残る（モデルは同梱）。
        expect(await count('asset'), 2);
        expect(await count('pavilion'), 1);
        expect(await count('challenge'), 1);
      });
    });

    group('CHECK 制約', () {
      test('asset.sha256 は小文字の 16 進 64 桁', () async {
        for (final bad in [
          'a' * 63,
          'a' * 65,
          'A' * 64,
          'g' * 64,
          '${'a' * 63} ',
        ]) {
          await expectLater(
            insertAsset(s, sha256: bad),
            throwsA(isA<DatabaseQueryException>()),
            reason: bad,
          );
        }
        await insertAsset(s, sha256: '0123456789abcdef' * 4);
      });

      test('asset.byte_length は 1 以上', () async {
        for (final bad in [0, -1]) {
          await expectLater(
            AssetRow.db.insertRow(
              s,
              AssetRow(
                sha256: sha(7),
                objectPath: 'p',
                contentType: 'image/png',
                byteLength: bad,
                createdAt: t0,
              ),
            ),
            throwsA(isA<DatabaseQueryException>()),
          );
        }
      });

      test('shot.score は 0〜1000', () async {
        final f = await insertFixture(s);
        for (final bad in [-1, 1001]) {
          final play = await insertPlaySession(s, f);
          await expectLater(
            insertShotRow(s, play, score: bad),
            throwsA(isA<DatabaseQueryException>()),
            reason: '$bad',
          );
        }
        final p0 = await insertPlaySession(s, f);
        await insertShotRow(s, p0, score: 0);
        final p1 = await insertPlaySession(s, f);
        await insertShotRow(s, p1, score: 1000);
      });

      test('JSON 列は JSON として不正な文字列を拒否する', () async {
        final c = await insertChallenge(s);
        final r = await insertRevision(s, challenge: c);
        await expectLater(
          insertModeConfig(s, revision: r, walkable: '{not json'),
          throwsA(isA<DatabaseQueryException>()),
        );
        await expectLater(
          ChallengeRevisionRow.db.updateRow(s, r.copyWith(mapBoundsXz: '[1,')),
          throwsA(isA<DatabaseQueryException>()),
        );
      });
    });

    test('shot は更新できない', () async {
      final f = await insertFixture(s);
      final play = await insertPlaySession(s, f);
      final shot = await insertShotRow(s, play);
      await expectLater(
        ShotRow.db.updateRow(s, shot.copyWith(score: 999)),
        throwsA(isA<DatabaseQueryException>()),
      );
      expect((await ShotRow.db.findById(s, shot.id!))!.score, 500);
    });

    test('ランキング索引は score DESC, achieved_at ASC, user_profile_id ASC', () async {
      final r = await sql(
        s,
        "SELECT sql FROM sqlite_master WHERE name = 'best_score_ranking_idx'",
      );
      expect(
        r.single.single,
        contains(
          '("revision_id", "mode", "score" DESC, "achieved_at" ASC, '
          '"user_profile_id" ASC)',
        ),
      );
      // 実際に索引が並び順のクエリで使われる。
      final plan = await sql(
        s,
        'EXPLAIN QUERY PLAN SELECT * FROM best_score '
        "WHERE revision_id = 1 AND mode = 'free' "
        'ORDER BY score DESC, achieved_at ASC, user_profile_id ASC LIMIT 100',
      );
      final detail = plan.map((row) => row.last.toString()).join('\n');
      expect(detail, contains('best_score_ranking_idx'));
      expect(detail, isNot(contains('TEMP B-TREE')));
    });
  });
}
