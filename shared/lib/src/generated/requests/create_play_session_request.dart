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

/// play.createPlaySession の引数。requestId は開始ごとに発行する UUID v4。
abstract class CreatePlaySessionRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  CreatePlaySessionRequest._({
    required this.revisionId,
    required this.mode,
    required this.requestId,
    this.spawnPointId,
  });

  factory CreatePlaySessionRequest({
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required _iss.UuidValue requestId,
    int? spawnPointId,
  }) = _CreatePlaySessionRequestImpl;

  factory CreatePlaySessionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CreatePlaySessionRequest(
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      requestId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      spawnPointId: jsonSerialization['spawnPointId'] as int?,
    );
  }

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  _iss.UuidValue requestId;

  /// 自由探索で入口が公開されているときの開始点。周辺探索と、入口のない版では null。
  int? spawnPointId;

  /// Returns a shallow copy of this [CreatePlaySessionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  CreatePlaySessionRequest copyWith({
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    _iss.UuidValue? requestId,
    int? spawnPointId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatePlaySessionRequest',
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'requestId': requestId.toJson(),
      if (spawnPointId != null) 'spawnPointId': spawnPointId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreatePlaySessionRequest',
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'requestId': requestId.toJson(),
      if (spawnPointId != null) 'spawnPointId': spawnPointId,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatePlaySessionRequestImpl extends CreatePlaySessionRequest {
  _CreatePlaySessionRequestImpl({
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required _iss.UuidValue requestId,
    int? spawnPointId,
  }) : super._(
         revisionId: revisionId,
         mode: mode,
         requestId: requestId,
         spawnPointId: spawnPointId,
       );

  /// Returns a shallow copy of this [CreatePlaySessionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  CreatePlaySessionRequest copyWith({
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    _iss.UuidValue? requestId,
    Object? spawnPointId = _Undefined,
  }) {
    return CreatePlaySessionRequest(
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
      requestId: requestId ?? this.requestId,
      spawnPointId: spawnPointId is int? ? spawnPointId : this.spawnPointId,
    );
  }
}
