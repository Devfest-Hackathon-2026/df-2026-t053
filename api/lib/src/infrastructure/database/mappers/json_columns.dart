import 'dart:convert';

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

import '../../../domain/exceptions.dart';

/// JSON 列（TEXT）と shared の型付きモデルを相互に変換する。
///
/// 読み出しでは型と有限性を検査し、壊れたデータは [CorruptedDataException] にする。
/// 素通しの Map をドメインへ渡さない。

WalkableArea walkableFromJson(String raw, {required String entity}) {
  return _decode(raw, entity: entity, field: 'walkable', (map) {
    final area = WalkableArea.fromJson(map);
    final points = [...area.outer, for (final hole in area.holes) ...hole];
    if (points.any((p) => !p.x.isFinite || !p.z.isFinite)) {
      throw const FormatException('座標が有限ではない');
    }
    return area;
  });
}

String walkableToJson(WalkableArea area) => jsonEncode(area.toJson());

MapBounds mapBoundsFromJson(String raw, {required String entity}) {
  return _decode(raw, entity: entity, field: 'map_bounds_xz', (map) {
    final bounds = MapBounds.fromJson(map);
    final values = [bounds.minX, bounds.minZ, bounds.maxX, bounds.maxZ];
    if (values.any((v) => !v.isFinite)) {
      throw const FormatException('座標が有限ではない');
    }
    return bounds;
  });
}

String mapBoundsToJson(MapBounds bounds) => jsonEncode(bounds.toJson());

T _decode<T>(
  String raw,
  T Function(Map<String, dynamic> map) build, {
  required String entity,
  required String field,
}) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON のオブジェクトではない');
    }
    return build(decoded);
  } on Object catch (e) {
    throw CorruptedDataException(entity: entity, field: field, message: '$e');
  }
}
