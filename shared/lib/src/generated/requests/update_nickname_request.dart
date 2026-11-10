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

/// profile.updateNickname の引数。nickname だけを受け付ける。
abstract class UpdateNicknameRequest
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  UpdateNicknameRequest._({required this.nickname});

  factory UpdateNicknameRequest({required String nickname}) =
      _UpdateNicknameRequestImpl;

  factory UpdateNicknameRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UpdateNicknameRequest(
      nickname: jsonSerialization['nickname'] as String,
    );
  }

  String nickname;

  /// Returns a shallow copy of this [UpdateNicknameRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  UpdateNicknameRequest copyWith({String? nickname});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'UpdateNicknameRequest', 'nickname': nickname};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'UpdateNicknameRequest', 'nickname': nickname};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _UpdateNicknameRequestImpl extends UpdateNicknameRequest {
  _UpdateNicknameRequestImpl({required String nickname})
    : super._(nickname: nickname);

  /// Returns a shallow copy of this [UpdateNicknameRequest]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  UpdateNicknameRequest copyWith({String? nickname}) {
    return UpdateNicknameRequest(nickname: nickname ?? this.nickname);
  }
}
