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

/// 撮影確定時の値。同じ requestId の再送では同じ値を返す。
abstract class SubmitShotResponse
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  SubmitShotResponse._({
    required this.shot,
    required this.reveal,
    required this.myRankingEntry,
  });

  factory SubmitShotResponse({
    required _ix5zeh3i.Shot shot,
    required _ix5zeh3i.Reveal reveal,
    required _ix5zeh3i.RankingEntry myRankingEntry,
  }) = _SubmitShotResponseImpl;

  factory SubmitShotResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubmitShotResponse(
      shot: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.Shot>(
        jsonSerialization['shot'],
      ),
      reveal: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.Reveal>(
        jsonSerialization['reveal'],
      ),
      myRankingEntry: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.RankingEntry>(
        jsonSerialization['myRankingEntry'],
      ),
    );
  }

  _ix5zeh3i.Shot shot;

  _ix5zeh3i.Reveal reveal;

  _ix5zeh3i.RankingEntry myRankingEntry;

  /// Returns a shallow copy of this [SubmitShotResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  SubmitShotResponse copyWith({
    _ix5zeh3i.Shot? shot,
    _ix5zeh3i.Reveal? reveal,
    _ix5zeh3i.RankingEntry? myRankingEntry,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SubmitShotResponse',
      'shot': shot.toJson(),
      'reveal': reveal.toJson(),
      'myRankingEntry': myRankingEntry.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SubmitShotResponse',
      'shot': shot.toJsonForProtocol(),
      'reveal': reveal.toJsonForProtocol(),
      'myRankingEntry': myRankingEntry.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _SubmitShotResponseImpl extends SubmitShotResponse {
  _SubmitShotResponseImpl({
    required _ix5zeh3i.Shot shot,
    required _ix5zeh3i.Reveal reveal,
    required _ix5zeh3i.RankingEntry myRankingEntry,
  }) : super._(shot: shot, reveal: reveal, myRankingEntry: myRankingEntry);

  /// Returns a shallow copy of this [SubmitShotResponse]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  SubmitShotResponse copyWith({
    _ix5zeh3i.Shot? shot,
    _ix5zeh3i.Reveal? reveal,
    _ix5zeh3i.RankingEntry? myRankingEntry,
  }) {
    return SubmitShotResponse(
      shot: shot ?? this.shot.copyWith(),
      reveal: reveal ?? this.reveal.copyWith(),
      myRankingEntry: myRankingEntry ?? this.myRankingEntry.copyWith(),
    );
  }
}
