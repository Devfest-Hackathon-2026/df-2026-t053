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

/// 会場図の範囲。モデルローカルの m。
abstract class MapBounds
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  MapBounds._({
    required this.minX,
    required this.minZ,
    required this.maxX,
    required this.maxZ,
  });

  factory MapBounds({
    required double minX,
    required double minZ,
    required double maxX,
    required double maxZ,
  }) = _MapBoundsImpl;

  factory MapBounds.fromJson(Map<String, dynamic> jsonSerialization) {
    return MapBounds(
      minX: (jsonSerialization['minX'] as num).toDouble(),
      minZ: (jsonSerialization['minZ'] as num).toDouble(),
      maxX: (jsonSerialization['maxX'] as num).toDouble(),
      maxZ: (jsonSerialization['maxZ'] as num).toDouble(),
    );
  }

  double minX;

  double minZ;

  double maxX;

  double maxZ;

  /// Returns a shallow copy of this [MapBounds]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  MapBounds copyWith({double? minX, double? minZ, double? maxX, double? maxZ});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MapBounds',
      'minX': minX,
      'minZ': minZ,
      'maxX': maxX,
      'maxZ': maxZ,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MapBounds',
      'minX': minX,
      'minZ': minZ,
      'maxX': maxX,
      'maxZ': maxZ,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _MapBoundsImpl extends MapBounds {
  _MapBoundsImpl({
    required double minX,
    required double minZ,
    required double maxX,
    required double maxZ,
  }) : super._(minX: minX, minZ: minZ, maxX: maxX, maxZ: maxZ);

  /// Returns a shallow copy of this [MapBounds]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  MapBounds copyWith({double? minX, double? minZ, double? maxX, double? maxZ}) {
    return MapBounds(
      minX: minX ?? this.minX,
      minZ: minZ ?? this.minZ,
      maxX: maxX ?? this.maxX,
      maxZ: maxZ ?? this.maxZ,
    );
  }
}
