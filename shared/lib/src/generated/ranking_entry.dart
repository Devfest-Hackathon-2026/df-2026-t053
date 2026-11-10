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

/// 順位の 1 行。SubmitShotResponse では撮影時のスナップショット。
abstract class RankingEntry
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  RankingEntry._({
    required this.rank,
    required this.nickname,
    required this.score,
    required this.achieveTime,
    required this.mine,
  });

  factory RankingEntry({
    required int rank,
    required String nickname,
    required int score,
    required DateTime achieveTime,
    required bool mine,
  }) = _RankingEntryImpl;

  factory RankingEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return RankingEntry(
      rank: jsonSerialization['rank'] as int,
      nickname: jsonSerialization['nickname'] as String,
      score: jsonSerialization['score'] as int,
      achieveTime: _iss.DateTimeJsonExtension.fromJson(
        jsonSerialization['achieveTime'],
      ),
      mine: _iss.BoolJsonExtension.fromJson(jsonSerialization['mine']),
    );
  }

  int rank;

  String nickname;

  int score;

  DateTime achieveTime;

  bool mine;

  /// Returns a shallow copy of this [RankingEntry]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  RankingEntry copyWith({
    int? rank,
    String? nickname,
    int? score,
    DateTime? achieveTime,
    bool? mine,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RankingEntry',
      'rank': rank,
      'nickname': nickname,
      'score': score,
      'achieveTime': achieveTime.toJson(),
      'mine': mine,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RankingEntry',
      'rank': rank,
      'nickname': nickname,
      'score': score,
      'achieveTime': achieveTime.toJson(),
      'mine': mine,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _RankingEntryImpl extends RankingEntry {
  _RankingEntryImpl({
    required int rank,
    required String nickname,
    required int score,
    required DateTime achieveTime,
    required bool mine,
  }) : super._(
         rank: rank,
         nickname: nickname,
         score: score,
         achieveTime: achieveTime,
         mine: mine,
       );

  /// Returns a shallow copy of this [RankingEntry]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  RankingEntry copyWith({
    int? rank,
    String? nickname,
    int? score,
    DateTime? achieveTime,
    bool? mine,
  }) {
    return RankingEntry(
      rank: rank ?? this.rank,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      achieveTime: achieveTime ?? this.achieveTime,
      mine: mine ?? this.mine,
    );
  }
}
