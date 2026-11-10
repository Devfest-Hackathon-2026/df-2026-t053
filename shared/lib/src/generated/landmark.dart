/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// 会場図上のパビリオン等の地点。緯度経度は対で設定する。
abstract class Landmark
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Landmark._({
    required this.id,
    required this.name,
    required this.positionX,
    required this.positionZ,
    this.latitude,
    this.longitude,
  });

  factory Landmark({
    required int id,
    required String name,
    required double positionX,
    required double positionZ,
    double? latitude,
    double? longitude,
  }) = _LandmarkImpl;

  factory Landmark.fromJson(Map<String, dynamic> jsonSerialization) {
    return Landmark(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
    );
  }

  int id;

  String name;

  double positionX;

  double positionZ;

  double? latitude;

  double? longitude;

  /// Returns a shallow copy of this [Landmark]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Landmark copyWith({
    int? id,
    String? name,
    double? positionX,
    double? positionZ,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Landmark',
      'id': id,
      'name': name,
      'positionX': positionX,
      'positionZ': positionZ,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Landmark',
      'id': id,
      'name': name,
      'positionX': positionX,
      'positionZ': positionZ,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LandmarkImpl extends Landmark {
  _LandmarkImpl({
    required int id,
    required String name,
    required double positionX,
    required double positionZ,
    double? latitude,
    double? longitude,
  }) : super._(
         id: id,
         name: name,
         positionX: positionX,
         positionZ: positionZ,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [Landmark]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Landmark copyWith({
    int? id,
    String? name,
    double? positionX,
    double? positionZ,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
  }) {
    return Landmark(
      id: id ?? this.id,
      name: name ?? this.name,
      positionX: positionX ?? this.positionX,
      positionZ: positionZ ?? this.positionZ,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
    );
  }
}
