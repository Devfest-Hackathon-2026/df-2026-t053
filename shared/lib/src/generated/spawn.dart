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

/// 開始点。位置は足元で、pitch の初期値は 0。
abstract class Spawn
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Spawn._({
    required this.positionX,
    required this.positionY,
    required this.positionZ,
    required this.yawDegrees,
  });

  factory Spawn({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
  }) = _SpawnImpl;

  factory Spawn.fromJson(Map<String, dynamic> jsonSerialization) {
    return Spawn(
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionY: (jsonSerialization['positionY'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
    );
  }

  double positionX;

  double positionY;

  double positionZ;

  double yawDegrees;

  /// Returns a shallow copy of this [Spawn]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Spawn copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Spawn',
      'positionX': positionX,
      'positionY': positionY,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Spawn',
      'positionX': positionX,
      'positionY': positionY,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _SpawnImpl extends Spawn {
  _SpawnImpl({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
  }) : super._(
         positionX: positionX,
         positionY: positionY,
         positionZ: positionZ,
         yawDegrees: yawDegrees,
       );

  /// Returns a shallow copy of this [Spawn]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Spawn copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
  }) {
    return Spawn(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      positionZ: positionZ ?? this.positionZ,
      yawDegrees: yawDegrees ?? this.yawDegrees,
    );
  }
}
