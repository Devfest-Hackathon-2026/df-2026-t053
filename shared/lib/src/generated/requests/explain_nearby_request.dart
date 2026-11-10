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

/// guide.explainNearby の引数。
abstract class ExplainNearbyRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ExplainNearbyRequest._({
    required this.playSessionId,
    required this.positionX,
    required this.positionZ,
    required this.yawDegrees,
    required this.locale,
  });

  factory ExplainNearbyRequest({
    required _iss.UuidValue playSessionId,
    required double positionX,
    required double positionZ,
    required double yawDegrees,
    required String locale,
  }) = _ExplainNearbyRequestImpl;

  factory ExplainNearbyRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ExplainNearbyRequest(
      playSessionId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['playSessionId'],
      ),
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      yawDegrees: (jsonSerialization['yawDegrees'] as num).toDouble(),
      locale: jsonSerialization['locale'] as String,
    );
  }

  _iss.UuidValue playSessionId;

  double positionX;

  double positionZ;

  double yawDegrees;

  String locale;

  /// Returns a shallow copy of this [ExplainNearbyRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ExplainNearbyRequest copyWith({
    _iss.UuidValue? playSessionId,
    double? positionX,
    double? positionZ,
    double? yawDegrees,
    String? locale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExplainNearbyRequest',
      'playSessionId': playSessionId.toJson(),
      'positionX': positionX,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'locale': locale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ExplainNearbyRequest',
      'playSessionId': playSessionId.toJson(),
      'positionX': positionX,
      'positionZ': positionZ,
      'yawDegrees': yawDegrees,
      'locale': locale,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ExplainNearbyRequestImpl extends ExplainNearbyRequest {
  _ExplainNearbyRequestImpl({
    required _iss.UuidValue playSessionId,
    required double positionX,
    required double positionZ,
    required double yawDegrees,
    required String locale,
  }) : super._(
         playSessionId: playSessionId,
         positionX: positionX,
         positionZ: positionZ,
         yawDegrees: yawDegrees,
         locale: locale,
       );

  /// Returns a shallow copy of this [ExplainNearbyRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ExplainNearbyRequest copyWith({
    _iss.UuidValue? playSessionId,
    double? positionX,
    double? positionZ,
    double? yawDegrees,
    String? locale,
  }) {
    return ExplainNearbyRequest(
      playSessionId: playSessionId ?? this.playSessionId,
      positionX: positionX ?? this.positionX,
      positionZ: positionZ ?? this.positionZ,
      yawDegrees: yawDegrees ?? this.yawDegrees,
      locale: locale ?? this.locale,
    );
  }
}
