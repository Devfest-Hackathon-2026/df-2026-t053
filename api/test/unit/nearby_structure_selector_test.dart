import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/selected_structure.dart';
import 'package:photohunt_server/src/domain/models/structure.dart';
import 'package:photohunt_server/src/domain/models/structure_source.dart';
import 'package:photohunt_server/src/domain/services/nearby_structure_selector.dart';
import 'package:test/test.dart';

Structure structure({
  int id = 1,
  int revision = 1,
  double x = 0,
  double z = 10,
  String facts = '確認済みの事実',
  String fallback = '固定解説',
  bool sources = true,
}) => Structure(
  id: id,
  revisionId: revision,
  pavilionId: null,
  name: '施設$id',
  posX: x,
  posZ: z,
  facts: facts,
  fallbackText: fallback,
  sources: sources
      ? [
          StructureSource(
            id: id,
            structureId: id,
            title: '登録資料',
            url: 'https://example.com/source',
            sortOrder: 0,
          ),
        ]
      : [],
);

List<SelectedStructure> select(List<Structure> structures, {double yaw = 0}) =>
    const NearbyStructureSelector().select(
      revisionId: 1,
      positionX: 0,
      positionZ: 0,
      yawDegrees: yaw,
      structures: structures,
    );

void main() {
  test('30m以内だけを選び、別版と資料の不足を除く', () {
    final result = select([
      structure(id: 1, z: 30),
      structure(id: 2, z: 30.0001),
      structure(id: 3, revision: 2),
      structure(id: 4, facts: ' '),
      structure(id: 5, fallback: ''),
      structure(id: 6, sources: false),
    ]);
    expect(result.map((s) => s.id), [1]);
    expect(result.single.distanceMeters, 30);
    expect(result.single.facts, '確認済みの事実');
    expect(result.single.sources.single.title, '登録資料');
  });
  test('近くの候補は左右60度の境界を含み、外側は第2段の最寄り1件になる', () {
    final values = [structure(id: 1), structure(id: 2, z: 12)];
    for (final sign in [-1, 1]) {
      expect(select(values, yaw: sign * 60).map((s) => s.id), [1, 2]);
      expect(select(values, yaw: sign * 59.999).map((s) => s.id), [1, 2]);
      expect(select(values, yaw: sign * 60.001).map((s) => s.id), [1]);
    }
  });
  test('正面は左右15度を含み、その外は左右に分かれる', () {
    for (final yaw in [-15.0, 0.0, 15.0]) {
      expect(
        select([structure()], yaw: yaw).single.direction,
        StructureDirection.front,
      );
    }
    expect(
      select([structure()], yaw: 15.001).single.direction,
      StructureDirection.left,
    );
    expect(
      select([structure()], yaw: -15.001).single.direction,
      StructureDirection.right,
    );
  });
  test('四方位とyawの周回を同じ規則で扱う', () {
    for (final (x, z, yaw) in [
      (0.0, 10.0, 0.0), // 北（+Z）
      (10.0, 0.0, 90.0), // 東（+X）
      (0.0, -10.0, 180.0), // 南（-Z）
      (-10.0, 0.0, 270.0), // 西（-X）
    ]) {
      for (final turn in [-360, 0, 360]) {
        expect(
          select([structure(x: x, z: z)], yaw: yaw + turn).single.direction,
          StructureDirection.front,
        );
      }
    }
  });
  test('北を向くと西は左・東は右（実行時は +X 東・+Z 北）', () {
    // 北（yaw 0°）を向いたまま、北西・北東の対象（相対角 ∓45°）。
    expect(
      select([structure(x: -10, z: 10)]).single.direction,
      StructureDirection.left,
    );
    expect(
      select([structure(x: 10, z: 10)]).single.direction,
      StructureDirection.right,
    );
    // 東（yaw 90°）を向くと、北は左・南は右。
    expect(
      select([structure(x: 10, z: 10)], yaw: 90).single.direction,
      StructureDirection.left,
    );
    expect(
      select([structure(x: 10, z: -10)], yaw: 90).single.direction,
      StructureDirection.right,
    );
  });
  test('英国パビリオン前の通路から北のパビリオンを向くと選ぶ（#213 の回帰）', () {
    // uk-pavilion の代表点と、周辺探索の歩行領域の北端に近い地点。対象は北に 27.6m。
    final pavilion = structure(x: -174.9, z: -99.4);
    List<SelectedStructure> from(double yaw) =>
        const NearbyStructureSelector().select(
          revisionId: 1,
          positionX: -175,
          positionZ: -127,
          yawDegrees: yaw,
          structures: [pavilion],
        );
    expect(from(0).single.direction, StructureDirection.front);
    // 背を向けたときは後ろと伝える（修正前は正面と判定していた）。
    expect(from(180).single.direction, StructureDirection.behind);
  });
  test('uk-pavilion r3 の開始点から、どこを向いても英国パビリオンを選ぶ（#226）', () {
    final pavilion = structure(x: -172.0, z: -118.0);
    SelectedStructure from(double x, double z, double yaw) =>
        const NearbyStructureSelector()
            .select(
              revisionId: 1,
              positionX: x,
              positionZ: z,
              yawDegrees: yaw,
              structures: [pavilion],
            )
            .single;
    // ゴール周辺探索の開始点（向き 100°）。対象は左 91.6°・27.3 m で、近くの候補の角度の外。
    final near = from(-176, -145, 100);
    expect(near.direction, StructureDirection.left);
    expect(near.distanceMeters, closeTo(27.3, 0.05));
    // 自由探索の東ゲート（向き 270°）。対象は約 790 m 先。
    final east = from(580, 123.4, 270);
    expect(east.distanceMeters, greaterThan(100));
    expect(east.direction, StructureDirection.left);
  });
  test('0.5m未満は背後でも方向なし、境界から方向を判定する', () {
    for (final z in [0.0, -0.4999]) {
      expect(
        select([structure(z: z)]).single.direction,
        StructureDirection.none,
      );
    }
    expect(
      select([structure(z: -0.5)]).single.direction,
      StructureDirection.behind,
    );
    expect(
      select([structure(z: 0.5)]).single.direction,
      StructureDirection.front,
    );
  });
  test('距離、絶対角度、IDの順で最大3件、入力順には依存しない', () {
    final values = [
      structure(id: 9, x: 6, z: 8),
      structure(id: 7, x: 6, z: 8),
      structure(id: 8),
      structure(id: 10, z: 1),
      structure(id: 11, z: 20),
    ];
    expect(select(values).map((s) => s.id), [10, 8, 7]);
    expect(select(values.reversed.toList()).map((s) => s.id), [10, 8, 7]);
  });
  test('近くに候補がなければ、距離の上限なしで最寄りの1件を選ぶ（#226）', () {
    final result = select([
      structure(id: 1, x: 0, z: 800),
      structure(id: 2, x: 0, z: -500),
      structure(id: 3, x: 400, z: 0),
    ]);
    expect(result.map((s) => s.id), [3]);
    expect(result.single.distanceMeters, 400);
    expect(result.single.direction, StructureDirection.right);
  });
  test('近くで向いている方の候補を、より近い背後の構造物より優先する', () {
    final result = select([structure(id: 1, z: -5), structure(id: 2, z: 20)]);
    expect(result.map((s) => s.id), [2]);
  });
  test('後ろは相対角度135度を超える範囲（南の対象、北東・北西向き）', () {
    expect(
      select([structure(z: -100)], yaw: 45).single.direction,
      StructureDirection.right,
    );
    expect(
      select([structure(z: -100)], yaw: 44.999).single.direction,
      StructureDirection.behind,
    );
    expect(
      select([structure(z: -100)], yaw: -45).single.direction,
      StructureDirection.left,
    );
    expect(
      select([structure(z: -100)], yaw: -44.999).single.direction,
      StructureDirection.behind,
    );
  });
  test('資料ありの構造物が版に1件もなければ専用例外', () {
    expect(
      () => select([
        structure(id: 1, revision: 2),
        structure(id: 2, facts: ''),
        structure(id: 3, sources: false),
      ]),
      throwsA(isA<NoGuideTargetException>()),
    );
  });
  test('候補なしは専用例外、非有限の姿勢は入力例外', () {
    expect(() => select([]), throwsA(isA<NoGuideTargetException>()));
    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(
        () => select([structure()], yaw: value),
        throwsA(isA<InvalidGuidePoseException>()),
      );
      expect(
        () => const NearbyStructureSelector().select(
          revisionId: 1,
          positionX: value,
          positionZ: 0,
          yawDegrees: 0,
          structures: [],
        ),
        throwsA(isA<InvalidGuidePoseException>()),
      );
      expect(
        () => select([structure(x: value)]),
        throwsA(isA<NoGuideTargetException>()),
      );
    }
  });
  test('入力・出力と出典を変更できない', () {
    final input = structure();
    final result = select([input]);
    // 入力の Structure も出典を変更できないコピーで持つ（#140）。
    expect(() => input.sources.clear(), throwsUnsupportedError);
    expect(result.single.sources, hasLength(1));
    expect(() => result.clear(), throwsUnsupportedError);
    expect(() => result.single.sources.clear(), throwsUnsupportedError);
  });
}
