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

/// プレイ。active では shot / reveal / myRankingEntry はすべて null、completed ではすべて返す。
abstract class PlaySession
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  PlaySession._({
    required this.id,
    required this.revisionId,
    required this.mode,
    required this.spawnPointId,
    required this.spawn,
    required this.state,
    required this.createTime,
    required this.expireTime,
    this.shot,
    this.reveal,
    this.myRankingEntry,
  });

  factory PlaySession({
    required _iss.UuidValue id,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int spawnPointId,
    required _ix5zeh3i.Spawn spawn,
    required _ix5zeh3i.PlaySessionState state,
    required DateTime createTime,
    required DateTime expireTime,
    _ix5zeh3i.Shot? shot,
    _ix5zeh3i.Reveal? reveal,
    _ix5zeh3i.RankingEntry? myRankingEntry,
  }) = _PlaySessionImpl;

  factory PlaySession.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaySession(
      id: _iss.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      spawnPointId: jsonSerialization['spawnPointId'] as int,
      spawn: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.Spawn>(
        jsonSerialization['spawn'],
      ),
      state: _ix5zeh3i.PlaySessionState.fromJson(
        (jsonSerialization['state'] as String),
      ),
      createTime: _iss.DateTimeJsonExtension.fromJson(
        jsonSerialization['createTime'],
      ),
      expireTime: _iss.DateTimeJsonExtension.fromJson(
        jsonSerialization['expireTime'],
      ),
      shot: jsonSerialization['shot'] == null
          ? null
          : _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.Shot>(
              jsonSerialization['shot'],
            ),
      reveal: jsonSerialization['reveal'] == null
          ? null
          : _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.Reveal>(
              jsonSerialization['reveal'],
            ),
      myRankingEntry: jsonSerialization['myRankingEntry'] == null
          ? null
          : _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.RankingEntry>(
              jsonSerialization['myRankingEntry'],
            ),
    );
  }

  _iss.UuidValue id;

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  int spawnPointId;

  _ix5zeh3i.Spawn spawn;

  _ix5zeh3i.PlaySessionState state;

  DateTime createTime;

  DateTime expireTime;

  _ix5zeh3i.Shot? shot;

  _ix5zeh3i.Reveal? reveal;

  _ix5zeh3i.RankingEntry? myRankingEntry;

  /// Returns a shallow copy of this [PlaySession]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  PlaySession copyWith({
    _iss.UuidValue? id,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? spawnPointId,
    _ix5zeh3i.Spawn? spawn,
    _ix5zeh3i.PlaySessionState? state,
    DateTime? createTime,
    DateTime? expireTime,
    _ix5zeh3i.Shot? shot = const _UndefinedPlaySession$shot(),
    _ix5zeh3i.Reveal? reveal = const _UndefinedPlaySession$reveal(),
    _ix5zeh3i.RankingEntry? myRankingEntry =
        const _UndefinedPlaySession$myRankingEntry(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaySession',
      'id': id.toJson(),
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'spawnPointId': spawnPointId,
      'spawn': spawn.toJson(),
      'state': state.toJson(),
      'createTime': createTime.toJson(),
      'expireTime': expireTime.toJson(),
      if (shot != null) 'shot': shot?.toJson(),
      if (reveal != null) 'reveal': reveal?.toJson(),
      if (myRankingEntry != null) 'myRankingEntry': myRankingEntry?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaySession',
      'id': id.toJson(),
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'spawnPointId': spawnPointId,
      'spawn': spawn.toJsonForProtocol(),
      'state': state.toJson(),
      'createTime': createTime.toJson(),
      'expireTime': expireTime.toJson(),
      if (shot != null) 'shot': shot?.toJsonForProtocol(),
      if (reveal != null) 'reveal': reveal?.toJsonForProtocol(),
      if (myRankingEntry != null)
        'myRankingEntry': myRankingEntry?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _UndefinedPlaySession$shot extends _iss.UndefinedSentinel
    implements _ix5zeh3i.Shot {
  const _UndefinedPlaySession$shot();
}

class _UndefinedPlaySession$reveal extends _iss.UndefinedSentinel
    implements _ix5zeh3i.Reveal {
  const _UndefinedPlaySession$reveal();
}

class _UndefinedPlaySession$myRankingEntry extends _iss.UndefinedSentinel
    implements _ix5zeh3i.RankingEntry {
  const _UndefinedPlaySession$myRankingEntry();
}

class _PlaySessionImpl extends PlaySession {
  _PlaySessionImpl({
    required _iss.UuidValue id,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int spawnPointId,
    required _ix5zeh3i.Spawn spawn,
    required _ix5zeh3i.PlaySessionState state,
    required DateTime createTime,
    required DateTime expireTime,
    _ix5zeh3i.Shot? shot,
    _ix5zeh3i.Reveal? reveal,
    _ix5zeh3i.RankingEntry? myRankingEntry,
  }) : super._(
         id: id,
         revisionId: revisionId,
         mode: mode,
         spawnPointId: spawnPointId,
         spawn: spawn,
         state: state,
         createTime: createTime,
         expireTime: expireTime,
         shot: shot,
         reveal: reveal,
         myRankingEntry: myRankingEntry,
       );

  /// Returns a shallow copy of this [PlaySession]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  PlaySession copyWith({
    _iss.UuidValue? id,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? spawnPointId,
    _ix5zeh3i.Spawn? spawn,
    _ix5zeh3i.PlaySessionState? state,
    DateTime? createTime,
    DateTime? expireTime,
    _ix5zeh3i.Shot? shot = const _UndefinedPlaySession$shot(),
    _ix5zeh3i.Reveal? reveal = const _UndefinedPlaySession$reveal(),
    _ix5zeh3i.RankingEntry? myRankingEntry =
        const _UndefinedPlaySession$myRankingEntry(),
  }) {
    return PlaySession(
      id: id ?? this.id,
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
      spawnPointId: spawnPointId ?? this.spawnPointId,
      spawn: spawn ?? this.spawn.copyWith(),
      state: state ?? this.state,
      createTime: createTime ?? this.createTime,
      expireTime: expireTime ?? this.expireTime,
      shot: shot is _iss.UndefinedSentinel ? this.shot?.copyWith() : shot,
      reveal: reveal is _iss.UndefinedSentinel
          ? this.reveal?.copyWith()
          : reveal,
      myRankingEntry: myRankingEntry is _iss.UndefinedSentinel
          ? this.myRankingEntry?.copyWith()
          : myRankingEntry,
    );
  }
}
