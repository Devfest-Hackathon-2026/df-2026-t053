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
import 'package:serverpod/serverpod.dart' as _is;

/// 会場図上の地点。pavilionKey は pavilions.yaml の sourceKey。緯度経度は対で設定する。
abstract class SeedLandmarkInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedLandmarkInput._({
    required this.pavilionKey,
    required this.displayName,
    required this.positionX,
    required this.positionZ,
    this.latitude,
    this.longitude,
  });

  factory SeedLandmarkInput({
    required String pavilionKey,
    required String displayName,
    required double positionX,
    required double positionZ,
    double? latitude,
    double? longitude,
  }) = _SeedLandmarkInputImpl;

  factory SeedLandmarkInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedLandmarkInput(
      pavilionKey: jsonSerialization['pavilionKey'] as String,
      displayName: jsonSerialization['displayName'] as String,
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
    );
  }

  String pavilionKey;

  String displayName;

  double positionX;

  double positionZ;

  double? latitude;

  double? longitude;

  /// Returns a shallow copy of this [SeedLandmarkInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedLandmarkInput copyWith({
    String? pavilionKey,
    String? displayName,
    double? positionX,
    double? positionZ,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedLandmarkInput',
      'pavilionKey': pavilionKey,
      'displayName': displayName,
      'positionX': positionX,
      'positionZ': positionZ,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeedLandmarkInputImpl extends SeedLandmarkInput {
  _SeedLandmarkInputImpl({
    required String pavilionKey,
    required String displayName,
    required double positionX,
    required double positionZ,
    double? latitude,
    double? longitude,
  }) : super._(
         pavilionKey: pavilionKey,
         displayName: displayName,
         positionX: positionX,
         positionZ: positionZ,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [SeedLandmarkInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedLandmarkInput copyWith({
    String? pavilionKey,
    String? displayName,
    double? positionX,
    double? positionZ,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
  }) {
    return SeedLandmarkInput(
      pavilionKey: pavilionKey ?? this.pavilionKey,
      displayName: displayName ?? this.displayName,
      positionX: positionX ?? this.positionX,
      positionZ: positionZ ?? this.positionZ,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
    );
  }
}
