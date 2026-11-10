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

/// カメラの姿勢。位置は視点（足元に eyeHeightMeters を足した値）。
abstract class CameraPose
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  CameraPose._({
    required this.positionX,
    required this.positionY,
    required this.positionZ,
    required this.yawDegrees,
    required this.pitchDegrees,
    required this.verticalFovDegrees,
  });

  factory CameraPose({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
    required double pitchDegrees,
    required double verticalFovDegrees,
  }) = _CameraPoseImpl;

  factory CameraPose.fromJson(Map<String, dynamic> jsonSerialization) {
    return CameraPose(
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionY: (jsonSerialization['positionY'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
      pitchDegrees: (jsonSerialization['pitchDegrees'] as num).toDouble(),
      verticalFovDegrees: (jsonSerialization['verticalFovDegrees'] as num)
          .toDouble(),
    );
  }

  double positionX;

  double positionY;

  double positionZ;

  double yawDegrees;

  double pitchDegrees;

  double verticalFovDegrees;

  /// Returns a shallow copy of this [CameraPose]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  CameraPose copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
    double? pitchDegrees,
    double? verticalFovDegrees,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CameraPose',
      'positionX': positionX,
      'positionY': positionY,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'pitchDegrees': pitchDegrees,
      'verticalFovDegrees': verticalFovDegrees,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CameraPose',
      'positionX': positionX,
      'positionY': positionY,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'pitchDegrees': pitchDegrees,
      'verticalFovDegrees': verticalFovDegrees,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _CameraPoseImpl extends CameraPose {
  _CameraPoseImpl({
    required double positionX,
    required double positionY,
    required double positionZ,
    required double yawDegrees,
    required double pitchDegrees,
    required double verticalFovDegrees,
  }) : super._(
         positionX: positionX,
         positionY: positionY,
         positionZ: positionZ,
         yawDegrees: yawDegrees,
         pitchDegrees: pitchDegrees,
         verticalFovDegrees: verticalFovDegrees,
       );

  /// Returns a shallow copy of this [CameraPose]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  CameraPose copyWith({
    double? positionX,
    double? positionY,
    double? positionZ,
    double? yawDegrees,
    double? pitchDegrees,
    double? verticalFovDegrees,
  }) {
    return CameraPose(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      positionZ: positionZ ?? this.positionZ,
      yawDegrees: yawDegrees ?? this.yawDegrees,
      pitchDegrees: pitchDegrees ?? this.pitchDegrees,
      verticalFovDegrees: verticalFovDegrees ?? this.verticalFovDegrees,
    );
  }
}
