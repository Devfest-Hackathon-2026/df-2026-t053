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

/// play.getPlaySession の引数。
abstract class GetPlaySessionRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GetPlaySessionRequest._({required this.playSessionId});

  factory GetPlaySessionRequest({required _iss.UuidValue playSessionId}) =
      _GetPlaySessionRequestImpl;

  factory GetPlaySessionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GetPlaySessionRequest(
      playSessionId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['playSessionId'],
      ),
    );
  }

  _iss.UuidValue playSessionId;

  /// Returns a shallow copy of this [GetPlaySessionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  GetPlaySessionRequest copyWith({_iss.UuidValue? playSessionId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GetPlaySessionRequest',
      'playSessionId': playSessionId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GetPlaySessionRequest',
      'playSessionId': playSessionId.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GetPlaySessionRequestImpl extends GetPlaySessionRequest {
  _GetPlaySessionRequestImpl({required _iss.UuidValue playSessionId})
    : super._(playSessionId: playSessionId);

  /// Returns a shallow copy of this [GetPlaySessionRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GetPlaySessionRequest copyWith({_iss.UuidValue? playSessionId}) {
    return GetPlaySessionRequest(
      playSessionId: playSessionId ?? this.playSessionId,
    );
  }
}
