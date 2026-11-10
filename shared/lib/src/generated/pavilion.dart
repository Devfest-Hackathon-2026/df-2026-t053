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

/// 万博パビリオンマスター。緯度経度は対で設定する。
abstract class Pavilion
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Pavilion._({
    required this.id,
    required this.sourceKey,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory Pavilion({
    required int id,
    required String sourceKey,
    required String name,
    double? latitude,
    double? longitude,
  }) = _PavilionImpl;

  factory Pavilion.fromJson(Map<String, dynamic> jsonSerialization) {
    return Pavilion(
      id: jsonSerialization['id'] as int,
      sourceKey: jsonSerialization['sourceKey'] as String,
      name: jsonSerialization['name'] as String,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
    );
  }

  int id;

  String sourceKey;

  String name;

  double? latitude;

  double? longitude;

  /// Returns a shallow copy of this [Pavilion]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Pavilion copyWith({
    int? id,
    String? sourceKey,
    String? name,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Pavilion',
      'id': id,
      'sourceKey': sourceKey,
      'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Pavilion',
      'id': id,
      'sourceKey': sourceKey,
      'name': name,
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

class _PavilionImpl extends Pavilion {
  _PavilionImpl({
    required int id,
    required String sourceKey,
    required String name,
    double? latitude,
    double? longitude,
  }) : super._(
         id: id,
         sourceKey: sourceKey,
         name: name,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [Pavilion]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Pavilion copyWith({
    int? id,
    String? sourceKey,
    String? name,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
  }) {
    return Pavilion(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      name: name ?? this.name,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
    );
  }
}
