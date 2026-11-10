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

/// ranking.listRankingEntries の引数。
abstract class ListRankingEntriesRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ListRankingEntriesRequest._({required this.revisionId, required this.mode});

  factory ListRankingEntriesRequest({
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
  }) = _ListRankingEntriesRequestImpl;

  factory ListRankingEntriesRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ListRankingEntriesRequest(
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
    );
  }

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  /// Returns a shallow copy of this [ListRankingEntriesRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ListRankingEntriesRequest copyWith({
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListRankingEntriesRequest',
      'revisionId': revisionId,
      'mode': mode.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListRankingEntriesRequest',
      'revisionId': revisionId,
      'mode': mode.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ListRankingEntriesRequestImpl extends ListRankingEntriesRequest {
  _ListRankingEntriesRequestImpl({
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
  }) : super._(revisionId: revisionId, mode: mode);

  /// Returns a shallow copy of this [ListRankingEntriesRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ListRankingEntriesRequest copyWith({
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
  }) {
    return ListRankingEntriesRequest(
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
    );
  }
}
