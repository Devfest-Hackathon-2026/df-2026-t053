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

/// 撮影の入力。冪等性の判定に使う 4 値。Y と画角はサーバーが版から補う。
abstract class ShotInput
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ShotInput._({
    required this.positionX,
    required this.positionZ,
    required this.yawDegrees,
    required this.pitchDegrees,
  });

  factory ShotInput({
    required double positionX,
    required double positionZ,
    required double yawDegrees,
    required double pitchDegrees,
  }) = _ShotInputImpl;

  factory ShotInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShotInput(
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
      pitchDegrees: (jsonSerialization['pitchDegrees'] as num).toDouble(),
    );
  }

  double positionX;

  double positionZ;

  double yawDegrees;

  double pitchDegrees;

  /// Returns a shallow copy of this [ShotInput]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ShotInput copyWith({
    double? positionX,
    double? positionZ,
    double? yawDegrees,
    double? pitchDegrees,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ShotInput',
      'positionX': positionX,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'pitchDegrees': pitchDegrees,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ShotInput',
      'positionX': positionX,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'pitchDegrees': pitchDegrees,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ShotInputImpl extends ShotInput {
  _ShotInputImpl({
    required double positionX,
    required double positionZ,
    required double yawDegrees,
    required double pitchDegrees,
  }) : super._(
         positionX: positionX,
         positionZ: positionZ,
         yawDegrees: yawDegrees,
         pitchDegrees: pitchDegrees,
       );

  /// Returns a shallow copy of this [ShotInput]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ShotInput copyWith({
    double? positionX,
    double? positionZ,
    double? yawDegrees,
    double? pitchDegrees,
  }) {
    return ShotInput(
      positionX: positionX ?? this.positionX,
      positionZ: positionZ ?? this.positionZ,
      yawDegrees: yawDegrees ?? this.yawDegrees,
      pitchDegrees: pitchDegrees ?? this.pitchDegrees,
    );
  }
}
