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

/// health.ping の結果。業務の値や秘密は含めない。
abstract class HealthResponse
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  HealthResponse._({required this.releaseId, required this.time});

  factory HealthResponse({required String releaseId, required DateTime time}) =
      _HealthResponseImpl;

  factory HealthResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return HealthResponse(
      releaseId: jsonSerialization['releaseId'] as String,
      time: _iss.DateTimeJsonExtension.fromJson(jsonSerialization['time']),
    );
  }

  String releaseId;

  DateTime time;

  /// Returns a shallow copy of this [HealthResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  HealthResponse copyWith({String? releaseId, DateTime? time});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HealthResponse',
      'releaseId': releaseId,
      'time': time.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HealthResponse',
      'releaseId': releaseId,
      'time': time.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _HealthResponseImpl extends HealthResponse {
  _HealthResponseImpl({required String releaseId, required DateTime time})
    : super._(releaseId: releaseId, time: time);

  /// Returns a shallow copy of this [HealthResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  HealthResponse copyWith({String? releaseId, DateTime? time}) {
    return HealthResponse(
      releaseId: releaseId ?? this.releaseId,
      time: time ?? this.time,
    );
  }
}
