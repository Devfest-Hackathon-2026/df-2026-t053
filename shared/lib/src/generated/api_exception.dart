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
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// 業務エラー。code は gRPC 相当の分類、reason は固定の文字列定数（api_error_reasons.dart）。message は開発者向けの固定説明で、SQL・秘密・生の例外を入れない。
abstract class ApiException
    implements
        _iss.SerializableException,
        _iss.SerializableModel,
        _iss.ProtocolSerialization {
  ApiException._({
    required this.code,
    required this.reason,
    required this.message,
    this.retryAfterSeconds,
    this.fieldViolations,
  });

  factory ApiException({
    required _ix5zeh3i.ApiErrorCode code,
    required String reason,
    required String message,
    int? retryAfterSeconds,
    List<_ix5zeh3i.FieldViolation>? fieldViolations,
  }) = _ApiExceptionImpl;

  factory ApiException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiException(
      code: _ix5zeh3i.ApiErrorCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
      reason: jsonSerialization['reason'] as String,
      message: jsonSerialization['message'] as String,
      retryAfterSeconds: jsonSerialization['retryAfterSeconds'] as int?,
      fieldViolations: jsonSerialization['fieldViolations'] == null
          ? null
          : _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.FieldViolation>>(
              jsonSerialization['fieldViolations'],
            ),
    );
  }

  _ix5zeh3i.ApiErrorCode code;

  String reason;

  String message;

  int? retryAfterSeconds;

  List<_ix5zeh3i.FieldViolation>? fieldViolations;

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ApiException copyWith({
    _ix5zeh3i.ApiErrorCode? code,
    String? reason,
    String? message,
    int? retryAfterSeconds,
    List<_ix5zeh3i.FieldViolation>? fieldViolations =
        const _iss.$UndefinedList<_ix5zeh3i.FieldViolation>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiException',
      'code': code.toJson(),
      'reason': reason,
      'message': message,
      if (retryAfterSeconds != null) 'retryAfterSeconds': retryAfterSeconds,
      if (fieldViolations != null)
        'fieldViolations': fieldViolations?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ApiException',
      'code': code.toJson(),
      'reason': reason,
      'message': message,
      if (retryAfterSeconds != null) 'retryAfterSeconds': retryAfterSeconds,
      if (fieldViolations != null)
        'fieldViolations': fieldViolations?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return 'ApiException(code: $code, reason: $reason, message: $message, retryAfterSeconds: $retryAfterSeconds, fieldViolations: $fieldViolations)';
  }
}

class _Undefined {}

class _ApiExceptionImpl extends ApiException {
  _ApiExceptionImpl({
    required _ix5zeh3i.ApiErrorCode code,
    required String reason,
    required String message,
    int? retryAfterSeconds,
    List<_ix5zeh3i.FieldViolation>? fieldViolations,
  }) : super._(
         code: code,
         reason: reason,
         message: message,
         retryAfterSeconds: retryAfterSeconds,
         fieldViolations: fieldViolations,
       );

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ApiException copyWith({
    _ix5zeh3i.ApiErrorCode? code,
    String? reason,
    String? message,
    Object? retryAfterSeconds = _Undefined,
    List<_ix5zeh3i.FieldViolation>? fieldViolations =
        const _iss.$UndefinedList<_ix5zeh3i.FieldViolation>(),
  }) {
    return ApiException(
      code: code ?? this.code,
      reason: reason ?? this.reason,
      message: message ?? this.message,
      retryAfterSeconds: retryAfterSeconds is int?
          ? retryAfterSeconds
          : this.retryAfterSeconds,
      fieldViolations: fieldViolations is _iss.UndefinedSentinel
          ? this.fieldViolations?.map((e0) => e0.copyWith()).toList()
          : fieldViolations,
    );
  }
}
