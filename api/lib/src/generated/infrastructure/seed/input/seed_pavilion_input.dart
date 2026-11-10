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

/// pavilion マスター 1 件。緯度経度は対で設定する。
abstract class SeedPavilionInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedPavilionInput._({
    required this.sourceKey,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory SeedPavilionInput({
    required String sourceKey,
    required String name,
    double? latitude,
    double? longitude,
  }) = _SeedPavilionInputImpl;

  factory SeedPavilionInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedPavilionInput(
      sourceKey: jsonSerialization['sourceKey'] as String,
      name: jsonSerialization['name'] as String,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
    );
  }

  String sourceKey;

  String name;

  double? latitude;

  double? longitude;

  /// Returns a shallow copy of this [SeedPavilionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedPavilionInput copyWith({
    String? sourceKey,
    String? name,
    double? latitude,
    double? longitude,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedPavilionInput',
      'sourceKey': sourceKey,
      'name': name,
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

class _SeedPavilionInputImpl extends SeedPavilionInput {
  _SeedPavilionInputImpl({
    required String sourceKey,
    required String name,
    double? latitude,
    double? longitude,
  }) : super._(
         sourceKey: sourceKey,
         name: name,
         latitude: latitude,
         longitude: longitude,
       );

  /// Returns a shallow copy of this [SeedPavilionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedPavilionInput copyWith({
    String? sourceKey,
    String? name,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
  }) {
    return SeedPavilionInput(
      sourceKey: sourceKey ?? this.sourceKey,
      name: name ?? this.name,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
    );
  }
}
