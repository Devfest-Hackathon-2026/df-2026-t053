import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/infrastructure/database/mappers/json_columns.dart';
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

void main() {
  group('walkableFromJson', () {
    test('穴あり・穴なしを往復する', () {
      final withHole = WalkableArea(
        outer: [PointXZ(x: 0, z: 0), PointXZ(x: 4, z: 0), PointXZ(x: 0, z: 4)],
        holes: [
          [PointXZ(x: 1, z: 1), PointXZ(x: 2, z: 1), PointXZ(x: 1, z: 2)],
        ],
      );
      final solid = WalkableArea(outer: withHole.outer, holes: []);
      for (final area in [withHole, solid]) {
        final decoded = walkableFromJson(
          walkableToJson(area),
          entity: 'mode_config',
        );
        expect(decoded.toJson(), area.toJson());
      }
    });

    test('壊れた値は CorruptedDataException', () {
      for (final raw in ['', 'not json', '[]', 'null', '{}', '{"outer": 1}']) {
        expect(
          () => walkableFromJson(raw, entity: 'mode_config'),
          throwsA(isA<CorruptedDataException>()),
          reason: raw,
        );
      }
    });
  });

  group('mapBoundsFromJson', () {
    test('往復する', () {
      final bounds = MapBounds(minX: -1, minZ: -2, maxX: 3.5, maxZ: 4.5);
      expect(
        mapBoundsFromJson(
          mapBoundsToJson(bounds),
          entity: 'challenge_revision',
        ).toJson(),
        bounds.toJson(),
      );
    });

    test('項目の不足・型違いは CorruptedDataException', () {
      for (final raw in [
        '{"minX": 0}',
        '{"minX":"a","minZ":0,"maxX":1,"maxZ":1}',
      ]) {
        expect(
          () => mapBoundsFromJson(raw, entity: 'challenge_revision'),
          throwsA(isA<CorruptedDataException>()),
          reason: raw,
        );
      }
    });
  });
}
