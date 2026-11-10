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

/// 不正な項目の名前と固定の理由。値そのものは入れない。
abstract class FieldViolation
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  FieldViolation._({required this.field, required this.reason});

  factory FieldViolation({required String field, required String reason}) =
      _FieldViolationImpl;

  factory FieldViolation.fromJson(Map<String, dynamic> jsonSerialization) {
    return FieldViolation(
      field: jsonSerialization['field'] as String,
      reason: jsonSerialization['reason'] as String,
    );
  }

  String field;

  String reason;

  /// Returns a shallow copy of this [FieldViolation]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  FieldViolation copyWith({String? field, String? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldViolation',
      'field': field,
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FieldViolation',
      'field': field,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _FieldViolationImpl extends FieldViolation {
  _FieldViolationImpl({required String field, required String reason})
    : super._(field: field, reason: reason);

  /// Returns a shallow copy of this [FieldViolation]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  FieldViolation copyWith({String? field, String? reason}) {
    return FieldViolation(
      field: field ?? this.field,
      reason: reason ?? this.reason,
    );
  }
}
