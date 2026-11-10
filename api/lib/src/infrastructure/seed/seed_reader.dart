import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:photohunt_shared/photohunt_shared.dart' show PointXZ;
import 'package:yaml/yaml.dart';

import '../../application/seed/load_seed_revision.dart';
import '../../application/seed/seed_input.dart';
import '../../application/seed/seed_validator.dart' show kSeedMaxImageBytes;
import '../../generated/protocol.dart';
import '../media/image_probe.dart';

/// 入力ファイルを読めない・形が違う。
class const SeedInputException(final String message) implements Exception {
  @override
  String toString() => 'SeedInputException($message)';
}

/// `DIR/revision.yaml`・素材・pavilion マスターを読む。
///
/// YAML は生成モデル（`input/*.spy.yaml`）の fromJson で型付きにしてから、
/// application の入力型へ変換する。手書きの JSON 変換は持たない。
SeedBundle readSeedBundle({
  required String dir,
  required String pavilionsPath,
}) {
  final raw = readSeedRevisionInput(dir);
  final pavilions = _parse(
    pavilionsPath,
    SeedPavilionList.fromJson,
    (m) => m.toJson(),
  ).pavilions;

  ({SeedFile file, String sha256}) read(SeedAssetFileInput asset) {
    final root = p.normalize(dir);
    final path = p.normalize(p.join(dir, asset.file));
    // 版のディレクトリの外を読まない（../ などで別の素材を混ぜない）。
    if (!p.isWithin(root, path)) {
      throw SeedInputException('素材は版のディレクトリ内に置く: ${asset.file}');
    }
    final f = File(path);
    if (!f.existsSync()) throw SeedInputException('素材ファイルがない: $path');
    // 上限を超えるファイルは読まない（指定の間違いで動画などを丸ごと読み込まない）。
    // 大きさの違反は検証が報告する。
    final length = f.lengthSync();
    if (length > kSeedMaxImageBytes) {
      return (
        file: SeedFile(
          bytes: Uint8List(0),
          byteLength: length,
          sha256: '',
          probe: null,
        ),
        sha256: '',
      );
    }
    final bytes = f.readAsBytesSync();
    final sha = sha256.convert(bytes).toString();
    return (
      file: SeedFile(
        bytes: bytes,
        byteLength: bytes.length,
        sha256: sha,
        probe: probeImage(bytes),
      ),
      sha256: sha,
    );
  }

  final photo = read(raw.assets.photo);
  final map = read(raw.assets.map);
  final input = seedRevisionFromInput(raw);
  return SeedBundle(
    input: input,
    pavilions: [
      for (final pavilion in pavilions)
        SeedPavilion(
          sourceKey: pavilion.sourceKey,
          name: pavilion.name,
          latitude: pavilion.latitude,
          longitude: pavilion.longitude,
        ),
    ],
    photo: photo.file,
    map: map.file,
    digest: seedDigest(input, photoSha256: photo.sha256, mapSha256: map.sha256),
  );
}

/// `DIR/revision.yaml` を読み取り形式（生成モデル）で読む。
SeedRevisionInput readSeedRevisionInput(String dir) => _parse(
  p.join(dir, 'revision.yaml'),
  SeedRevisionInput.fromJson,
  (m) => m.toJson(),
);

/// 読み取り形式（生成モデル）から application の入力型へ変換する。
SeedRevision seedRevisionFromInput(SeedRevisionInput raw) {
  final r = raw.revision;
  return SeedRevision(
    slug: raw.challenge.slug,
    title: raw.challenge.title,
    revisionNo: r.revisionNo,
    sceneProfile: r.sceneProfile,
    scoringVersion: r.scoringVersion,
    photoAlt: r.photoAlt,
    eyeHeightMeters: r.eyeHeightMeters,
    shotVerticalFovDegrees: r.shotVerticalFovDegrees,
    goal: SeedGoal(
      x: r.goal.x,
      y: r.goal.y,
      z: r.goal.z,
      yawDegrees: r.goal.yawDegrees,
      pitchDegrees: r.goal.pitchDegrees,
    ),
    story: r.story,
    highlight: r.highlight,
    photo: SeedAssetFile(
      file: raw.assets.photo.file,
      contentType: raw.assets.photo.contentType,
    ),
    map: SeedAssetFile(
      file: raw.assets.map.file,
      contentType: raw.assets.map.contentType,
    ),
    bounds: raw.map.bounds,
    modes: [
      for (final m in raw.modes)
        SeedMode(
          mode: m.mode,
          walkable: m.walkable,
          spawns: [
            for (final s in m.spawns)
              SeedSpawn(
                positionX: s.positionX,
                positionY: s.positionY,
                positionZ: s.positionZ,
                yawDegrees: s.yawDegrees,
                label: s.label,
              ),
          ],
        ),
    ],
    landmarks: [
      for (final l in raw.landmarks)
        SeedLandmark(
          pavilionKey: l.pavilionKey,
          displayName: l.displayName,
          positionX: l.positionX,
          positionZ: l.positionZ,
          latitude: l.latitude,
          longitude: l.longitude,
        ),
    ],
    credits: raw.credits,
    structures: [
      for (final s in raw.structures)
        SeedStructure(
          name: s.name,
          pavilionKey: s.pavilionKey,
          positionX: s.positionX,
          positionZ: s.positionZ,
          facts: s.facts,
          fallbackText: s.fallbackText,
          sources: s.sources,
        ),
    ],
  );
}

/// digest の正規形の版。正規形（[_canonical]）を変えたら上げる。
///
/// 上げると、登録済みの版を同じ内容で再投入しても衝突（exit 3）になる。
/// 入力モデル（`input/*.spy.yaml`）の項目を足しただけでは digest は変わらない。
const int kSeedDigestVersion = 2;

/// 入力と素材の内容を正規化した SHA-256。
///
/// 生成モデルの toJson ではなく、項目を明示した正規形から計算する（入力モデルの変更で
/// 同じ内容の digest が変わらないように）。素材はファイル名ではなく内容の SHA-256 で比べる。
/// 有限でない数は文字列（`NaN` など）に置き換える。検証で違反になるので登録はされないが、
/// どの入力にも別の値を返す。
String seedDigest(
  SeedRevision input, {
  required String photoSha256,
  required String mapSha256,
}) {
  final canonical = _canonical(
    input,
    photoSha256: photoSha256,
    mapSha256: mapSha256,
  );
  return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
}

Map<String, Object?> _canonical(
  SeedRevision r, {
  required String photoSha256,
  required String mapSha256,
}) {
  Object? n(double? v) => v == null || v.isFinite ? v : v.toString();
  List<Object?> ring(List<PointXZ> points) => [
    for (final p in points) [n(p.x), n(p.z)],
  ];
  return {
    'digestVersion': kSeedDigestVersion,
    'slug': r.slug,
    'title': r.title,
    'revisionNo': r.revisionNo,
    'sceneProfile': r.sceneProfile,
    'scoringVersion': r.scoringVersion,
    'photoAlt': r.photoAlt,
    'eyeHeightMeters': n(r.eyeHeightMeters),
    'shotVerticalFovDegrees': n(r.shotVerticalFovDegrees),
    'goal': [
      n(r.goal.x),
      n(r.goal.y),
      n(r.goal.z),
      n(r.goal.yawDegrees),
      n(r.goal.pitchDegrees),
    ],
    'story': r.story,
    'highlight': r.highlight,
    'photo': [photoSha256, r.photo.contentType],
    'map': [mapSha256, r.map.contentType],
    'bounds': [
      n(r.bounds.minX),
      n(r.bounds.minZ),
      n(r.bounds.maxX),
      n(r.bounds.maxZ),
    ],
    'modes': [
      for (final m in r.modes)
        {
          'mode': m.mode.name,
          'outer': ring(m.walkable.outer),
          'holes': [for (final h in m.walkable.holes) ring(h)],
          'spawns': [
            for (final s in m.spawns)
              [
                n(s.positionX),
                n(s.positionY),
                n(s.positionZ),
                n(s.yawDegrees),
                s.label,
              ],
          ],
        },
    ],
    'landmarks': [
      for (final l in r.landmarks)
        [
          l.pavilionKey,
          l.displayName,
          n(l.positionX),
          n(l.positionZ),
          n(l.latitude),
          n(l.longitude),
        ],
    ],
    'credits': [
      for (final c in r.credits) [c.name, c.url],
    ],
    'structures': [
      for (final s in r.structures)
        {
          'name': s.name,
          'pavilionKey': s.pavilionKey,
          'position': [n(s.positionX), n(s.positionZ)],
          'facts': s.facts,
          'fallbackText': s.fallbackText,
          'sources': [
            for (final source in s.sources) [source.title, source.url],
          ],
        },
    ],
  };
}

T _parse<T>(
  String path,
  T Function(Map<String, dynamic>) fromJson,
  Map<String, dynamic> Function(T) toJson,
) {
  final file = File(path);
  if (!file.existsSync()) throw SeedInputException('ファイルがない: $path');
  final Object? node;
  try {
    node = _plain(loadYaml(file.readAsStringSync(), sourceUrl: Uri.file(path)));
  } on YamlException catch (e) {
    throw SeedInputException('$path の YAML を読めない: ${e.message}');
  }
  if (node is! Map<String, dynamic>) {
    throw SeedInputException('$path の最上位はマップにする');
  }
  final T model;
  try {
    model = fromJson(node);
  } on TypeError catch (e) {
    // 生成モデルの fromJson は、項目が足りない・型が違うと TypeError になる。
    throw SeedInputException('$path の項目が足りない、または型が違う: $e');
  }
  // 生成モデルの fromJson は知らないキーを黙って捨てる。省略できる項目の書き間違い
  // （latitude を lat と書くなど）が null として通らないよう、知らないキーを拒否する。
  final unknown = _unknownKeys(node, toJson(model), '');
  if (unknown.isNotEmpty) {
    throw SeedInputException('$path に知らない項目がある: ${unknown.join(', ')}');
  }
  return model;
}

/// [input]（YAML）にあって [parsed]（読んだモデルの toJson）にないキーの場所。
///
/// 生成モデルの toJson は null の項目を出さないので、値が null のキーは数えない
/// （書き間違えても値は null のまま。null 以外を書けば、ここで見つかる）。
List<String> _unknownKeys(Object? input, Object? parsed, String path) {
  if (input is Map<String, dynamic> && parsed is Map<String, dynamic>) {
    final found = <String>[];
    for (final MapEntry(:key, :value) in input.entries) {
      final at = path.isEmpty ? key : '$path.$key';
      if (parsed.containsKey(key)) {
        found.addAll(_unknownKeys(value, parsed[key], at));
      } else if (value != null) {
        found.add(at);
      }
    }
    return found;
  }
  if (input is List && parsed is List && input.length == parsed.length) {
    return [
      for (var i = 0; i < input.length; i++)
        ..._unknownKeys(input[i], parsed[i], '$path[$i]'),
    ];
  }
  return const [];
}

/// YAML のノードを、JSON と同じ素の Map・List・値に変換する。
/// jsonEncode を通さないのは、`.nan`・`.inf` を検証で違反として報告するため。
Object? _plain(Object? node) => switch (node) {
  YamlMap() => <String, dynamic>{
    for (final MapEntry(:key, :value) in node.entries) '$key': _plain(value),
  },
  YamlList() => [for (final value in node) _plain(value)],
  _ => node,
};
