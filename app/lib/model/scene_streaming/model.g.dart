// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SceneTileManifest _$SceneTileManifestFromJson(Map<String, dynamic> json) =>
    _SceneTileManifest(
      version: (json['version'] as num).toInt(),
      tileSizeMeters: (json['tileSizeMeters'] as num).toDouble(),
      tiles: (json['tiles'] as List<dynamic>)
          .map((e) => SceneTile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SceneTileManifestToJson(_SceneTileManifest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'tileSizeMeters': instance.tileSizeMeters,
      'tiles': instance.tiles,
    };

_SceneTile _$SceneTileFromJson(Map<String, dynamic> json) => _SceneTile(
  id: json['id'] as String,
  minX: (json['minX'] as num).toDouble(),
  maxX: (json['maxX'] as num).toDouble(),
  minZ: (json['minZ'] as num).toDouble(),
  maxZ: (json['maxZ'] as num).toDouble(),
  detailPath: json['detailPath'] as String,
  coarsePath: json['coarsePath'] as String,
  detailTriangles: (json['detailTriangles'] as num).toInt(),
  coarseTriangles: (json['coarseTriangles'] as num).toInt(),
);

Map<String, dynamic> _$SceneTileToJson(_SceneTile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minX': instance.minX,
      'maxX': instance.maxX,
      'minZ': instance.minZ,
      'maxZ': instance.maxZ,
      'detailPath': instance.detailPath,
      'coarsePath': instance.coarsePath,
      'detailTriangles': instance.detailTriangles,
      'coarseTriangles': instance.coarseTriangles,
    };
