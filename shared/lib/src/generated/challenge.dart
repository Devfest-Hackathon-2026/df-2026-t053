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

/// 出題。公開終了なら currentRevisionId は null。
abstract class Challenge
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Challenge._({required this.id, required this.title, this.currentRevisionId});

  factory Challenge({
    required int id,
    required String title,
    int? currentRevisionId,
  }) = _ChallengeImpl;

  factory Challenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return Challenge(
      id: jsonSerialization['id'] as int,
      title: jsonSerialization['title'] as String,
      currentRevisionId: jsonSerialization['currentRevisionId'] as int?,
    );
  }

  int id;

  String title;

  int? currentRevisionId;

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Challenge copyWith({int? id, String? title, int? currentRevisionId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Challenge',
      'id': id,
      'title': title,
      if (currentRevisionId != null) 'currentRevisionId': currentRevisionId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Challenge',
      'id': id,
      'title': title,
      if (currentRevisionId != null) 'currentRevisionId': currentRevisionId,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChallengeImpl extends Challenge {
  _ChallengeImpl({
    required int id,
    required String title,
    int? currentRevisionId,
  }) : super._(id: id, title: title, currentRevisionId: currentRevisionId);

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Challenge copyWith({
    int? id,
    String? title,
    Object? currentRevisionId = _Undefined,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      currentRevisionId: currentRevisionId is int?
          ? currentRevisionId
          : this.currentRevisionId,
    );
  }
}
