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

/// health.ping の引数。項目は持たない。
abstract class HealthRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  HealthRequest._();

  factory HealthRequest() = _HealthRequestImpl;

  factory HealthRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return HealthRequest();
  }

  /// Returns a shallow copy of this [HealthRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  HealthRequest copyWith();
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'HealthRequest'};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'HealthRequest'};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _HealthRequestImpl extends HealthRequest {
  _HealthRequestImpl() : super._();

  /// Returns a shallow copy of this [HealthRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  HealthRequest copyWith() {
    return HealthRequest();
  }
}
