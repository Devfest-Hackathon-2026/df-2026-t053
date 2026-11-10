import 'dart:convert';
import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';

import 'seed_input.dart';

/// 登録時の相互検証で見つけた違反 1 件。
class const SeedViolation(
  /// 入力の場所（例 `modes[0].spawns[2]`）。
  final String path,
  final String message,
) {
  @override
  String toString() => '$path: $message';
}

/// 素材ファイルの実測値。ヘッダーを読めなかった場合、[probe] は null。
class const SeedAssetFacts({
  required final String declaredContentType,
  required final int byteLength,
  required final SeedImageFacts? probe,
});

/// 画像ヘッダーから読んだ値。
class const SeedImageFacts({
  required final String contentType,
  required final int width,
  required final int height,
  required final bool hasMetadata,
});

/// 件数・大きさの上限（docs/specs.md「登録時の相互検証」「素材URLと取得上限」）。
const int kSeedMaxLandmarks = 100;
const int kSeedMaxCredits = 30;
const int kSeedMaxStructures = 100;
const int kSeedMaxStructureSources = 30;
const int kSeedFreeSpawnMin = 2;
const int kSeedFreeSpawnMax = 32;
const int kSeedMaxDetailBytes = 1024 * 1024;
const int kSeedMaxImageBytes = 5 * 1024 * 1024;
const int kSeedMaxImageSide = 4096;
const double kSeedMinGoalDistanceMeters = 5.0;
const double kSeedMaxPitchDegrees = 65.0;
const Set<String> kSeedImageTypes = {'image/jpeg', 'image/png', 'image/webp'};
const Set<String> kSeedScoringVersions = {'v1'};

/// 足元の Y と目標の Y を比べるときの許容誤差（m）。
const double _kHeightEpsilon = 1e-6;

final RegExp _slugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
final RegExp _profilePattern = RegExp(r'^[a-z0-9]+([.-][a-z0-9]+)*$');

/// seed 入力 1 版を検証し、違反をすべて返す（最初の 1 件で止めない）。
///
/// 幾何の判定は shared の関数（実行時と同じ規則）を使う。
List<SeedViolation> validateSeed({
  required SeedRevision input,
  required Set<String> pavilionKeys,
  required SeedAssetFacts photo,
  required SeedAssetFacts map,
}) {
  final v = _Collector();
  final goal = input.goal;
  final bounds = input.bounds;

  // --- 文字列と版の識別 ---
  if (!_slugPattern.hasMatch(input.slug)) {
    v.add('challenge.slug', '英小文字・数字・ハイフンだけにする');
  }
  v.nonEmpty('challenge.title', input.title);
  if (input.revisionNo < 1) {
    v.add('revision.revisionNo', '1 以上にする');
  }
  if (!_profilePattern.hasMatch(input.sceneProfile)) {
    v.add('revision.sceneProfile', '英小文字・数字・ハイフン・ドットだけにする');
  }
  if (!kSeedScoringVersions.contains(input.scoringVersion)) {
    v.add('revision.scoringVersion', '対応する採点式は $kSeedScoringVersions');
  }
  v.nonEmpty('revision.photoAlt', input.photoAlt);
  v.nonEmpty('revision.story', input.story);
  v.nonEmpty('revision.highlight', input.highlight);

  // --- 撮影条件 ---
  if (v.finite('revision.eyeHeightMeters', input.eyeHeightMeters) &&
      input.eyeHeightMeters <= 0) {
    v.add('revision.eyeHeightMeters', '正の値にする');
  }
  if (v.finite(
        'revision.shotVerticalFovDegrees',
        input.shotVerticalFovDegrees,
      ) &&
      (input.shotVerticalFovDegrees <= 0 ||
          input.shotVerticalFovDegrees >= 180)) {
    v.add('revision.shotVerticalFovDegrees', '0 より大きく 180 未満にする');
  }
  final goalFinite = [
    v.finite('revision.goal.x', goal.x),
    v.finite('revision.goal.y', goal.y),
    v.finite('revision.goal.z', goal.z),
    v.finite('revision.goal.yawDegrees', goal.yawDegrees),
    v.finite('revision.goal.pitchDegrees', goal.pitchDegrees),
  ].every((ok) => ok);
  if (goalFinite) {
    if (goal.yawDegrees < 0 || goal.yawDegrees >= 360) {
      v.add('revision.goal.yawDegrees', '0 以上 360 未満にする');
    }
    if (goal.pitchDegrees.abs() > kSeedMaxPitchDegrees) {
      v.add(
        'revision.goal.pitchDegrees',
        '±$kSeedMaxPitchDegrees° に収める（撮影の入力範囲で再現できること）',
      );
    }
  }

  // --- 会場図 ---
  final boundsFinite = [
    v.finite('map.bounds.minX', bounds.minX),
    v.finite('map.bounds.minZ', bounds.minZ),
    v.finite('map.bounds.maxX', bounds.maxX),
    v.finite('map.bounds.maxZ', bounds.maxZ),
  ].every((ok) => ok);
  final boundsUsable =
      boundsFinite && bounds.maxX > bounds.minX && bounds.maxZ > bounds.minZ;
  if (boundsFinite && !boundsUsable) {
    v.add('map.bounds', '幅（maxX-minX）と高さ（maxZ-minZ）を正にする');
  }
  bool inBounds(double x, double z) =>
      x >= bounds.minX &&
      x <= bounds.maxX &&
      z >= bounds.minZ &&
      z <= bounds.maxZ;
  void checkInBounds(String path, double x, double z) {
    if (boundsUsable && x.isFinite && z.isFinite && !inBounds(x, z)) {
      v.add(path, '会場図の範囲（map.bounds）の外にある');
    }
  }

  // --- 素材 ---
  _checkAsset(v, 'assets.photo', photo);
  final mapProbe = _checkAsset(v, 'assets.map', map);
  if (mapProbe != null && boundsUsable) {
    final ratio = (bounds.maxX - bounds.minX) / (bounds.maxZ - bounds.minZ);
    // 幅から高さ、高さから幅の、どちらを求めても 1 px 以内で一致すること。
    // 比率が 1 でないとき、片方の向きは誤差が比率の分だけ大きく出るので、両方を見る。
    final expectedWidth = mapProbe.height * ratio;
    final expectedHeight = mapProbe.width / ratio;
    if ((mapProbe.width - expectedWidth).abs() > 1 ||
        (mapProbe.height - expectedHeight).abs() > 1) {
      v.add(
        'assets.map',
        '画像の幅／高さ（${mapProbe.width}×${mapProbe.height}）が bounds の比率 '
            '${ratio.toStringAsFixed(4)} と 1 px 以内で一致しない',
      );
    }
  }

  // --- モード・歩行領域・開始点 ---
  final modesByKind = <PlayMode, ({int index, SeedMode mode})>{};
  for (var i = 0; i < input.modes.length; i++) {
    final mode = input.modes[i];
    final path = 'modes[$i]';
    if (mode.mode == PlayMode.unknown) {
      v.add('$path.mode', 'free か near にする');
      continue;
    }
    if (modesByKind.containsKey(mode.mode)) {
      v.add('$path.mode', '${mode.mode.name} が重複している');
      continue;
    }
    modesByKind[mode.mode] = (index: i, mode: mode);
  }
  for (final kind in [PlayMode.free, PlayMode.near]) {
    if (!modesByKind.containsKey(kind)) {
      v.add('modes', '${kind.name} のモードがない');
    }
  }

  final usableAreas = <PlayMode, WalkableArea>{};
  double? footY;
  for (final MapEntry(key: kind, value: (:index, :mode))
      in modesByKind.entries) {
    final path = 'modes[$index]';
    final validation = validateWalkable(mode.walkable);
    for (final violation in validation.violations) {
      v.add('$path.walkable', violation.message);
    }
    if (validation.isValid) usableAreas[kind] = mode.walkable;
    for (final (ringIndex, ring) in [
      (-1, mode.walkable.outer),
      for (var h = 0; h < mode.walkable.holes.length; h++)
        (h, mode.walkable.holes[h]),
    ]) {
      final ringPath = ringIndex < 0
          ? '$path.walkable.outer'
          : '$path.walkable.holes[$ringIndex]';
      for (var p = 0; p < ring.length; p++) {
        checkInBounds('$ringPath[$p]', ring[p].x, ring[p].z);
      }
    }

    final count = mode.spawns.length;
    final (min, max) = kind == PlayMode.free
        ? (kSeedFreeSpawnMin, kSeedFreeSpawnMax)
        : (1, 1);
    if (count < min || count > max) {
      v.add(
        '$path.spawns',
        '${kind.name} の開始点は ${min == max ? '$min' : '$min〜$max'} 件にする（$count 件）',
      );
    }
    for (var s = 0; s < count; s++) {
      final spawn = mode.spawns[s];
      final spawnPath = '$path.spawns[$s]';
      final finite = [
        v.finite('$spawnPath.positionX', spawn.positionX),
        v.finite('$spawnPath.positionY', spawn.positionY),
        v.finite('$spawnPath.positionZ', spawn.positionZ),
        v.finite('$spawnPath.yawDegrees', spawn.yawDegrees),
      ].every((ok) => ok);
      if (!finite) continue;
      if (spawn.yawDegrees < 0 || spawn.yawDegrees >= 360) {
        v.add('$spawnPath.yawDegrees', '0 以上 360 未満にする');
      }
      final label = spawn.label?.trim();
      if (kind == .free) {
        if (label == null || label.isEmpty) {
          v.add('$spawnPath.label', '自由探索の開始点には表示名を付ける');
        }
      } else if (spawn.label != null) {
        v.add('$spawnPath.label', '表示名は自由探索の開始点だけに付ける');
      }
      final y = footY ??= spawn.positionY;
      if ((spawn.positionY - y).abs() > _kHeightEpsilon) {
        v.add(
          '$spawnPath.positionY',
          '全モード・開始点の足元 Y を同じ平面にする（$y と ${spawn.positionY}）',
        );
      }
      checkInBounds(spawnPath, spawn.positionX, spawn.positionZ);
      final area = usableAreas[kind];
      final foot = PointXZ(x: spawn.positionX, z: spawn.positionZ);
      if (area != null && !isInsideWalkable(area, foot)) {
        v.add(spawnPath, '${kind.name} の歩行領域の外にある');
      }
      if (goalFinite) {
        final distance = math.sqrt(
          math.pow(spawn.positionX - goal.x, 2) +
              math.pow(spawn.positionZ - goal.z, 2),
        );
        if (distance < kSeedMinGoalDistanceMeters) {
          v.add(
            spawnPath,
            '撮影地点との XZ 距離を $kSeedMinGoalDistanceMeters m 以上にする'
            '（${distance.toStringAsFixed(2)} m）',
          );
        }
      }
    }
    if (kind == .free && count > 0) {
      final names = [
        for (final spawn in mode.spawns)
          if (spawn.label?.trim() case final name? when name.isNotEmpty) name,
      ];
      if (names.length != names.toSet().length) {
        v.add('$path.spawns', '自由探索の表示名は重複させない');
      }
    }
  }

  // ゴールの足元は両モードで到達可能。validateWalkable を満たす領域は、穴が外周の内側に
  // 厳密に収まり互いに接触しないので連結であり、領域内の開始点とゴールは同じ接続領域にある。
  if (goalFinite) {
    checkInBounds('revision.goal', goal.x, goal.z);
    final goalFoot = PointXZ(x: goal.x, z: goal.z);
    for (final MapEntry(key: kind, value: area) in usableAreas.entries) {
      if (!isInsideWalkable(area, goalFoot)) {
        v.add('revision.goal', '足元位置が ${kind.name} の歩行領域の外にある');
      }
    }
    final eye = input.eyeHeightMeters;
    if (footY != null &&
        eye.isFinite &&
        (goal.y - (footY + eye)).abs() > _kHeightEpsilon) {
      v.add(
        'revision.goal.y',
        '足元 Y（$footY）＋eyeHeightMeters（$eye）に一致させる（${goal.y}）',
      );
    }
  }

  final free = usableAreas[PlayMode.free];
  final near = usableAreas[PlayMode.near];
  if (free != null && near != null) {
    for (final message in _nearOutsideFree(near: near, free: free)) {
      v.add('modes[${modesByKind[PlayMode.near]!.index}].walkable', message);
    }
  }

  // --- 会場図の地点 ---
  if (input.landmarks.length > kSeedMaxLandmarks) {
    v.add(
      'landmarks',
      '$kSeedMaxLandmarks 件以下にする（${input.landmarks.length} 件）',
    );
  }
  final seenPavilions = <String>{};
  for (var i = 0; i < input.landmarks.length; i++) {
    final landmark = input.landmarks[i];
    final path = 'landmarks[$i]';
    v.nonEmpty('$path.displayName', landmark.displayName);
    if (!pavilionKeys.contains(landmark.pavilionKey)) {
      v.add('$path.pavilionKey', 'pavilion マスターにない（${landmark.pavilionKey}）');
    }
    if (!seenPavilions.add(landmark.pavilionKey)) {
      v.add('$path.pavilionKey', '同じ版で重複している（${landmark.pavilionKey}）');
    }
    final finite = [
      v.finite('$path.positionX', landmark.positionX),
      v.finite('$path.positionZ', landmark.positionZ),
    ].every((ok) => ok);
    if (finite) checkInBounds(path, landmark.positionX, landmark.positionZ);
    v.latLon(path, landmark.latitude, landmark.longitude);
  }

  // --- 出典 ---
  if (input.credits.length > kSeedMaxCredits) {
    v.add('credits', '$kSeedMaxCredits 件以下にする（${input.credits.length} 件）');
  }
  for (var i = 0; i < input.credits.length; i++) {
    final credit = input.credits[i];
    v.nonEmpty('credits[$i].name', credit.name);
    final url = credit.url;
    if (url != null) v.httpsUrl('credits[$i].url', url);
  }

  // --- 構造物資料 ---
  if (input.structures.length > kSeedMaxStructures) {
    v.add(
      'structures',
      '$kSeedMaxStructures 件以下にする（${input.structures.length} 件）',
    );
  }
  for (var i = 0; i < input.structures.length; i++) {
    final structure = input.structures[i];
    final path = 'structures[$i]';
    v.nonEmpty('$path.name', structure.name);
    v.nonEmpty('$path.facts', structure.facts);
    v.nonEmpty('$path.fallbackText', structure.fallbackText);
    final key = structure.pavilionKey;
    if (key != null && !pavilionKeys.contains(key)) {
      v.add('$path.pavilionKey', 'pavilion マスターにない（$key）');
    }
    final finite = [
      v.finite('$path.positionX', structure.positionX),
      v.finite('$path.positionZ', structure.positionZ),
    ].every((ok) => ok);
    if (finite) checkInBounds(path, structure.positionX, structure.positionZ);
    if (structure.sources.isEmpty) {
      v.add('$path.sources', '出典を 1 件以上にする');
    }
    if (structure.sources.length > kSeedMaxStructureSources) {
      v.add('$path.sources', '$kSeedMaxStructureSources 件以下にする');
    }
    for (var s = 0; s < structure.sources.length; s++) {
      v.nonEmpty('$path.sources[$s].title', structure.sources[s].title);
      v.httpsUrl('$path.sources[$s].url', structure.sources[s].url);
    }
  }

  // --- 出題詳細の大きさ ---
  // 正解・解説を除いた、公開 DTO に載る内容の JSON の大きさで判定する。
  if (v.isEmpty) {
    final detail = utf8.encode(
      jsonEncode({
        'slug': input.slug,
        'title': input.title,
        'sceneProfile': input.sceneProfile,
        'photoAlt': input.photoAlt,
        'bounds': input.bounds.toJson(),
        'modes': [
          for (final m in input.modes)
            {'mode': m.mode.name, 'walkable': m.walkable.toJson()},
        ],
        'landmarks': [
          for (final l in input.landmarks)
            {
              'name': l.displayName,
              'x': l.positionX,
              'z': l.positionZ,
              'lat': l.latitude,
              'lon': l.longitude,
            },
        ],
        'credits': [for (final c in input.credits) c.toJson()],
      }),
    );
    if (detail.length > kSeedMaxDetailBytes) {
      v.add('', '出題詳細のシリアライズ結果を 1 MiB 以下にする（${detail.length} バイト）');
    }
  }

  return List.unmodifiable(v.violations);
}

SeedImageFacts? _checkAsset(_Collector v, String path, SeedAssetFacts asset) {
  if (!kSeedImageTypes.contains(asset.declaredContentType)) {
    v.add('$path.contentType', '$kSeedImageTypes のどれかにする');
  }
  if (asset.byteLength <= 0) {
    v.add(path, '空のファイル');
  } else if (asset.byteLength > kSeedMaxImageBytes) {
    // 中身は読んでいない。ほかの検査（形式・寸法）は行わない。
    v.add(path, '5 MiB 以下にする（${asset.byteLength} バイト）');
    return null;
  }
  final probe = asset.probe;
  if (probe == null) {
    v.add(path, 'JPEG・PNG・WebP の画像として読めない');
    return null;
  }
  if (probe.contentType != asset.declaredContentType) {
    v.add('$path.contentType', '実ファイルの形式（${probe.contentType}）と一致しない');
  }
  if (probe.width <= 0 || probe.height <= 0) {
    v.add(path, '画像の寸法が 0');
  }
  if (math.max(probe.width, probe.height) > kSeedMaxImageSide) {
    v.add(
      path,
      '最大辺を $kSeedMaxImageSide px 以下にする（${probe.width}×${probe.height}）',
    );
  }
  if (probe.hasMetadata) {
    v.add(path, 'EXIF・XMP を除いてから登録する（位置・端末情報を公開しない）');
  }
  return probe;
}

/// near の領域が free の領域に収まらない理由を返す。
///
/// 実行時と同じ判定（[isInsideWalkable]・[clampMove]）を使う。
/// 1. near の外周の頂点が free で歩ける位置にある。
/// 2. near の外周の各辺を free の中で歩いても止められない（free の外周や穴を横切らない）。
/// 3. free の穴の頂点・辺が near で歩ける位置を通らない（free の穴が near の中に残っていない）。
List<String> _nearOutsideFree({
  required WalkableArea near,
  required WalkableArea free,
}) {
  final messages = <String>[];
  final outer = near.outer;
  for (var i = 0; i < outer.length; i++) {
    if (!isInsideWalkable(free, outer[i])) {
      messages.add('near の外周の頂点 $i が free の歩行領域の外にある');
      return messages;
    }
  }
  for (var i = 0; i < outer.length; i++) {
    final from = outer[i];
    final to = outer[(i + 1) % outer.length];
    if (clampMove(free, from, to).blocked) {
      messages.add('near の外周の辺 $i が free の境界や穴を横切る');
      return messages;
    }
  }
  for (var h = 0; h < free.holes.length; h++) {
    final hole = free.holes[h];
    final inside =
        hole.any((p) => isInsideWalkable(near, p)) ||
        [
          for (var i = 0; i < hole.length; i++)
            _crossesWalkable(near, hole[i], hole[(i + 1) % hole.length]),
        ].any((crosses) => crosses);
    if (inside) messages.add('free の穴 $h が near の歩行領域の中にある');
  }
  return messages;
}

/// 線分 [a]→[b] のどこかが [area] で歩ける位置を通るか。
///
/// 線分を [area] の全境界（外周・穴）との交点で区切ると、各区間の中では内外が変わらない。
/// 区間の中点で判定する（頂点がすべて穴の中でも、辺が穴の外を横切る形を見逃さない）。
bool _crossesWalkable(WalkableArea area, PointXZ a, PointXZ b) {
  final dx = b.x - a.x;
  final dz = b.z - a.z;
  final ts = <double>[0, 1];
  for (final ring in [area.outer, ...area.holes]) {
    for (var i = 0; i < ring.length; i++) {
      final c = ring[i];
      final d = ring[(i + 1) % ring.length];
      final ex = d.x - c.x;
      final ez = d.z - c.z;
      final denom = dx * ez - dz * ex;
      if (denom == 0) continue; // 平行。重なる場合も区間の中点で判定できる。
      final t = ((c.x - a.x) * ez - (c.z - a.z) * ex) / denom;
      final u = ((c.x - a.x) * dz - (c.z - a.z) * dx) / denom;
      if (t > 0 && t < 1 && u >= 0 && u <= 1) ts.add(t);
    }
  }
  ts.sort();
  for (var i = 0; i + 1 < ts.length; i++) {
    if (ts[i + 1] - ts[i] < 1e-9) continue;
    final t = (ts[i] + ts[i + 1]) / 2;
    if (isInsideWalkable(area, PointXZ(x: a.x + dx * t, z: a.z + dz * t))) {
      return true;
    }
  }
  return false;
}

class _Collector() {
  final List<SeedViolation> violations = [];

  bool get isEmpty => violations.isEmpty;

  void add(String path, String message) =>
      violations.add(SeedViolation(path, message));

  /// 有限なら true。違反は記録する。
  bool finite(String path, double value) {
    if (value.isFinite) return true;
    add(path, '有限の数にする（$value）');
    return false;
  }

  void nonEmpty(String path, String value) {
    if (value.trim().isEmpty) add(path, '空にしない');
  }

  void latLon(String path, double? lat, double? lon) {
    if ((lat == null) != (lon == null)) {
      add(path, '緯度と経度は対で設定する（片方だけは不可）');
      return;
    }
    if (lat == null || lon == null) return;
    if (finite('$path.latitude', lat) && (lat < -90 || lat > 90)) {
      add('$path.latitude', '−90〜90 にする');
    }
    if (finite('$path.longitude', lon) && (lon < -180 || lon > 180)) {
      add('$path.longitude', '−180〜180 にする');
    }
  }

  void httpsUrl(String path, String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      add(path, 'https の URL にする');
    }
  }
}
