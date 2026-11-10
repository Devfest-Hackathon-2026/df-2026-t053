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

/// 版・モード別の上位 100 件。空なら空配列。
abstract class ListRankingEntriesResponse
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ListRankingEntriesResponse._({required this.entries});

  factory ListRankingEntriesResponse({
    required List<_ix5zeh3i.RankingEntry> entries,
  }) = _ListRankingEntriesResponseImpl;

  factory ListRankingEntriesResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ListRankingEntriesResponse(
      entries: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.RankingEntry>>(
        jsonSerialization['entries'],
      ),
    );
  }

  List<_ix5zeh3i.RankingEntry> entries;

  /// Returns a shallow copy of this [ListRankingEntriesResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ListRankingEntriesResponse copyWith({List<_ix5zeh3i.RankingEntry>? entries});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListRankingEntriesResponse',
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListRankingEntriesResponse',
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ListRankingEntriesResponseImpl extends ListRankingEntriesResponse {
  _ListRankingEntriesResponseImpl({
    required List<_ix5zeh3i.RankingEntry> entries,
  }) : super._(entries: entries);

  /// Returns a shallow copy of this [ListRankingEntriesResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ListRankingEntriesResponse copyWith({List<_ix5zeh3i.RankingEntry>? entries}) {
    return ListRankingEntriesResponse(
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
    );
  }
}
