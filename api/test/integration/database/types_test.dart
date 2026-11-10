import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/database/mappers/json_columns.dart';
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_challenge_repository.dart';
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

/// JSON 列・日時・列挙値の保存形式を確認する。
void main() {
  withDatabase('Given 列の型', (sessionBuilder) {
    late Session s;
    setUp(() => s = sessionBuilder.build());

    test('WalkableArea は穴あり・穴なしの両方が往復する', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      await insertModeConfig(
        s,
        revision: r,
        walkable: walkableToJson(walkableWithHole),
      );
      await insertModeConfig(
        s,
        revision: r,
        mode: PlayMode.near,
        walkable: walkableToJson(walkableSolid),
      );

      final rev = await OrmChallengeRepository(s).findRevision(r.id!);
      final withHole = rev!.modes
          .firstWhere((m) => m.mode == PlayMode.free)
          .walkable;
      final solid = rev.modes
          .firstWhere((m) => m.mode == PlayMode.near)
          .walkable;
      expect(withHole.toJson(), walkableWithHole.toJson());
      expect(withHole.holes.single.map((p) => p.x), [4, 6, 6]);
      expect(solid.toJson(), walkableSolid.toJson());
      expect(solid.holes, isEmpty);
      expect(solid.outer[1].x, 5.5);
    });

    test('MapBounds が往復する', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      final rev = await OrmChallengeRepository(s).findRevision(r.id!);
      expect(rev!.mapBounds.toJson(), mapBounds.toJson());
    });

    test('壊れた JSON 列は CorruptedDataException（Map を素通しにしない）', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      final bad = [
        '[]', // オブジェクトではない
        '"text"',
        '{}', // 項目がない
        '{"outer": [], "holes": 1}', // 型が違う
        '{"outer": [{"x": "1", "z": 2}], "holes": []}', // 座標が数でない
        '{"outer": [{"x": 1e999, "z": 2}], "holes": []}', // 有限でない
      ];
      for (final json in bad) {
        await ModeConfigRow.db.deleteWhere(
          s,
          where: (t) => t.id.notEquals(null),
        );
        await insertModeConfig(s, revision: r, walkable: json);
        await expectLater(
          OrmChallengeRepository(s).findRevision(r.id!),
          throwsA(
            isA<CorruptedDataException>()
                .having((e) => e.entity, 'entity', 'mode_config')
                .having((e) => e.field, 'field', 'walkable'),
          ),
          reason: json,
        );
      }

      await ChallengeRevisionRow.db.updateRow(
        s,
        r.copyWith(mapBoundsXz: '{"minX": 0}'),
      );
      await ModeConfigRow.db.deleteWhere(s, where: (t) => t.id.notEquals(null));
      await expectLater(
        OrmChallengeRepository(s).findRevision(r.id!),
        throwsA(
          isA<CorruptedDataException>().having(
            (e) => e.field,
            'field',
            'map_bounds_xz',
          ),
        ),
      );
    });

    test('日時は UTC のまま往復する（ミリ秒まで）', () async {
      final a = await insertAsset(s);
      expect(a.createdAt.isUtc, isTrue);
      final read = (await AssetRow.db.findById(s, a.id!))!;
      expect(read.createdAt.isUtc, isTrue);
      expect(read.createdAt, t0);

      // ローカル時刻で渡しても、DB の中身は同じ時刻（epoch）。mapper が toUtc する。
      final local = DateTime.fromMillisecondsSinceEpoch(
        t0.millisecondsSinceEpoch,
      );
      expect(local.isUtc, isFalse);
      final b = await AssetRow.db.insertRow(
        s,
        a.copyWith(id: null, sha256: sha(42), createdAt: local),
      );
      final stored = await sql(
        s,
        'SELECT created_at FROM asset WHERE id = ${b.id}',
      );
      expect(stored.single.single, t0.millisecondsSinceEpoch);
    });

    test('列挙値は文字列（byName）で保存される', () async {
      final f = await insertFixture(s);
      await insertPlaySession(s, f);
      final near = await insertModeConfig(
        s,
        revision: f.revision,
        mode: PlayMode.near,
      );
      expect(near.mode, PlayMode.near);

      final modes = await sql(s, 'SELECT mode FROM mode_config ORDER BY id');
      expect(modes.map((r) => r.single), ['free', 'near']);
      final session = await sql(s, 'SELECT mode FROM play_session');
      expect(session.single.single, 'free');
    });

    test('play_session.id は UUID（16 バイト）で保存される', () async {
      final f = await insertFixture(s);
      final play = await insertPlaySession(s, f);
      final r = await sql(s, 'SELECT length(id) FROM play_session');
      expect(r.single.single, 16);
      expect(play.id, isNotNull);
      final read = await PlaySessionRow.db.findById(s, play.id!);
      expect(read!.id, play.id);
    });
  });
}
