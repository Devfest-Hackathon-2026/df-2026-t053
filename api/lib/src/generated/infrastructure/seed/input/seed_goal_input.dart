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

/// 撮影の正解姿勢。位置は視点（足元の Y に eyeHeightMeters を足した値）。
abstract class SeedGoalInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedGoalInput._({
    required this.x,
    required this.y,
    required this.z,
    required this.yawDegrees,
    required this.pitchDegrees,
  });

  factory SeedGoalInput({
    required double x,
    required double y,
    required double z,
    required double yawDegrees,
    required double pitchDegrees,
  }) = _SeedGoalInputImpl;

  factory SeedGoalInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedGoalInput(
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
      z: (jsonSerialization['z'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
      pitchDegrees: (jsonSerialization['pitchDegrees'] as num).toDouble(),
    );
  }

  double x;

  double y;

  double z;

  double yawDegrees;

  double pitchDegrees;

  /// Returns a shallow copy of this [SeedGoalInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedGoalInput copyWith({
    double? x,
    double? y,
    double? z,
    double? yawDegrees,
    double? pitchDegrees,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedGoalInput',
      'x': x,
      'y': y,
      'z': z,
      'yawDegrees': yawDegrees,
      'pitchDegrees': pitchDegrees,
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

class _SeedGoalInputImpl extends SeedGoalInput {
  _SeedGoalInputImpl({
    required double x,
    required double y,
    required double z,
    required double yawDegrees,
    required double pitchDegrees,
  }) : super._(
         x: x,
         y: y,
         z: z,
         yawDegrees: yawDegrees,
         pitchDegrees: pitchDegrees,
       );

  /// Returns a shallow copy of this [SeedGoalInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedGoalInput copyWith({
    double? x,
    double? y,
    double? z,
    double? yawDegrees,
    double? pitchDegrees,
  }) {
    return SeedGoalInput(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      yawDegrees: yawDegrees ?? this.yawDegrees,
      pitchDegrees: pitchDegrees ?? this.pitchDegrees,
    );
  }
}
