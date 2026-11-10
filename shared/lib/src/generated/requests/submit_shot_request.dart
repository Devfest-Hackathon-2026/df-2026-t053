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

/// play.submitShot の引数。requestId は撮影ごとに発行する UUID v4。
abstract class SubmitShotRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  SubmitShotRequest._({
    required this.playSessionId,
    required this.camera,
    required this.requestId,
  });

  factory SubmitShotRequest({
    required _iss.UuidValue playSessionId,
    required _ix5zeh3i.ShotInput camera,
    required _iss.UuidValue requestId,
  }) = _SubmitShotRequestImpl;

  factory SubmitShotRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return SubmitShotRequest(
      playSessionId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['playSessionId'],
      ),
      camera: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.ShotInput>(
        jsonSerialization['camera'],
      ),
      requestId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
    );
  }

  _iss.UuidValue playSessionId;

  _ix5zeh3i.ShotInput camera;

  _iss.UuidValue requestId;

  /// Returns a shallow copy of this [SubmitShotRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  SubmitShotRequest copyWith({
    _iss.UuidValue? playSessionId,
    _ix5zeh3i.ShotInput? camera,
    _iss.UuidValue? requestId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SubmitShotRequest',
      'playSessionId': playSessionId.toJson(),
      'camera': camera.toJson(),
      'requestId': requestId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SubmitShotRequest',
      'playSessionId': playSessionId.toJson(),
      'camera': camera.toJsonForProtocol(),
      'requestId': requestId.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _SubmitShotRequestImpl extends SubmitShotRequest {
  _SubmitShotRequestImpl({
    required _iss.UuidValue playSessionId,
    required _ix5zeh3i.ShotInput camera,
    required _iss.UuidValue requestId,
  }) : super._(
         playSessionId: playSessionId,
         camera: camera,
         requestId: requestId,
       );

  /// Returns a shallow copy of this [SubmitShotRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  SubmitShotRequest copyWith({
    _iss.UuidValue? playSessionId,
    _ix5zeh3i.ShotInput? camera,
    _iss.UuidValue? requestId,
  }) {
    return SubmitShotRequest(
      playSessionId: playSessionId ?? this.playSessionId,
      camera: camera ?? this.camera.copyWith(),
      requestId: requestId ?? this.requestId,
    );
  }
}
