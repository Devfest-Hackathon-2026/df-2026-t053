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

/// 開始点。label がある自由探索の点だけを入口として公開する。
abstract class SeedSpawnInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedSpawnInput._({
    required this.positionX,
    required this.positionY,
    required this.positionZ,
    required this.yawDegrees,
    this.label,
  });

  factory SeedSpawnInput({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
    String? label,
  }) = _SeedSpawnInputImpl;

  factory SeedSpawnInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedSpawnInput(
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionY: (jsonSerialization['positionY'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
      label: jsonSerialization['label'] as String?,
    );
  }

  double positionX;

  double positionY;

  double positionZ;

  double yawDegrees;

  String? label;

  /// Returns a shallow copy of this [SeedSpawnInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedSpawnInput copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
    String? label,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedSpawnInput',
      'positionX': positionX,
      'positionY': positionY,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      if (label != null) 'label': label,
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

class _SeedSpawnInputImpl extends SeedSpawnInput {
  _SeedSpawnInputImpl({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
    String? label,
  }) : super._(
         positionX: positionX,
         positionY: positionY,
         positionZ: positionZ,
         yawDegrees: yawDegrees,
         label: label,
       );

  /// Returns a shallow copy of this [SeedSpawnInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedSpawnInput copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
    Object? label = _Undefined,
  }) {
    return SeedSpawnInput(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      positionZ: positionZ ?? this.positionZ,
      yawDegrees: yawDegrees ?? this.yawDegrees,
      label: label is String? ? label : this.label,
    );
  }
}
