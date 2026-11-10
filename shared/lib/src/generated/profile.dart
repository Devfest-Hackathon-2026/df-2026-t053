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

/// プロフィール。anonymous は出力専用。
abstract class Profile
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Profile._({required this.nickname, required this.anonymous});

  factory Profile({required String nickname, required bool anonymous}) =
      _ProfileImpl;

  factory Profile.fromJson(Map<String, dynamic> jsonSerialization) {
    return Profile(
      nickname: jsonSerialization['nickname'] as String,
      anonymous: _iss.BoolJsonExtension.fromJson(
        jsonSerialization['anonymous'],
      ),
    );
  }

  String nickname;

  bool anonymous;

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Profile copyWith({String? nickname, bool? anonymous});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Profile',
      'nickname': nickname,
      'anonymous': anonymous,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Profile',
      'nickname': nickname,
      'anonymous': anonymous,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ProfileImpl extends Profile {
  _ProfileImpl({required String nickname, required bool anonymous})
    : super._(nickname: nickname, anonymous: anonymous);

  /// Returns a shallow copy of this [Profile]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Profile copyWith({String? nickname, bool? anonymous}) {
    return Profile(
      nickname: nickname ?? this.nickname,
      anonymous: anonymous ?? this.anonymous,
    );
  }
}
