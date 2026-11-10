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

/// challenge.getChallenge の引数。
abstract class GetChallengeRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GetChallengeRequest._({required this.challengeId});

  factory GetChallengeRequest({required int challengeId}) =
      _GetChallengeRequestImpl;

  factory GetChallengeRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return GetChallengeRequest(
      challengeId: jsonSerialization['challengeId'] as int,
    );
  }

  int challengeId;

  /// Returns a shallow copy of this [GetChallengeRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  GetChallengeRequest copyWith({int? challengeId});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'GetChallengeRequest', 'challengeId': challengeId};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'GetChallengeRequest', 'challengeId': challengeId};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GetChallengeRequestImpl extends GetChallengeRequest {
  _GetChallengeRequestImpl({required int challengeId})
    : super._(challengeId: challengeId);

  /// Returns a shallow copy of this [GetChallengeRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GetChallengeRequest copyWith({int? challengeId}) {
    return GetChallengeRequest(challengeId: challengeId ?? this.challengeId);
  }
}
