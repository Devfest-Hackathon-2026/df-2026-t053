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

/// 会場モデルのローカル座標（m）の XZ 平面上の点。
abstract class PointXZ
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  PointXZ._({required this.x, required this.z});

  factory PointXZ({required double x, required double z}) = _PointXZImpl;

  factory PointXZ.fromJson(Map<String, dynamic> jsonSerialization) {
    return PointXZ(
      x: (jsonSerialization['x'] as num).toDouble(),
      z: (jsonSerialization['z'] as num).toDouble(),
    );
  }

  double x;

  double z;

  /// Returns a shallow copy of this [PointXZ]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  PointXZ copyWith({double? x, double? z});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'PointXZ', 'x': x, 'z': z};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'PointXZ', 'x': x, 'z': z};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _PointXZImpl extends PointXZ {
  _PointXZImpl({required double x, required double z}) : super._(x: x, z: z);

  /// Returns a shallow copy of this [PointXZ]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  PointXZ copyWith({double? x, double? z}) {
    return PointXZ(x: x ?? this.x, z: z ?? this.z);
  }
}
