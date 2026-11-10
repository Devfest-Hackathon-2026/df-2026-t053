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

/// challenge.getChallengeRevision の引数。
abstract class GetChallengeRevisionRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GetChallengeRevisionRequest._({required this.revisionId});

  factory GetChallengeRevisionRequest({required int revisionId}) =
      _GetChallengeRevisionRequestImpl;

  factory GetChallengeRevisionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GetChallengeRevisionRequest(
      revisionId: jsonSerialization['revisionId'] as int,
    );
  }

  int revisionId;

  /// Returns a shallow copy of this [GetChallengeRevisionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  GetChallengeRevisionRequest copyWith({int? revisionId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GetChallengeRevisionRequest',
      'revisionId': revisionId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GetChallengeRevisionRequest',
      'revisionId': revisionId,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GetChallengeRevisionRequestImpl extends GetChallengeRevisionRequest {
  _GetChallengeRevisionRequestImpl({required int revisionId})
    : super._(revisionId: revisionId);

  /// Returns a shallow copy of this [GetChallengeRevisionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GetChallengeRevisionRequest copyWith({int? revisionId}) {
    return GetChallengeRevisionRequest(
      revisionId: revisionId ?? this.revisionId,
    );
  }
}
