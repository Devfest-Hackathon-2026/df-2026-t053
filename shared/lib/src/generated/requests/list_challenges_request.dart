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

/// challenge.listChallenges の引数。項目は持たない。
abstract class ListChallengesRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ListChallengesRequest._();

  factory ListChallengesRequest() = _ListChallengesRequestImpl;

  factory ListChallengesRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ListChallengesRequest();
  }

  /// Returns a shallow copy of this [ListChallengesRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ListChallengesRequest copyWith();
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'ListChallengesRequest'};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'ListChallengesRequest'};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ListChallengesRequestImpl extends ListChallengesRequest {
  _ListChallengesRequestImpl() : super._();

  /// Returns a shallow copy of this [ListChallengesRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ListChallengesRequest copyWith() {
    return ListChallengesRequest();
  }
}
