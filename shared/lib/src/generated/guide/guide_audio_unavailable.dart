/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

part of 'nearby_guide_event.dart';

/// 音声を送れないことの通知。本文は保持する。
abstract class GuideAudioUnavailable extends _ix5zeh3i.NearbyGuideEvent
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GuideAudioUnavailable._({required super.guideId, required this.reason});

  factory GuideAudioUnavailable({
    required _iss.UuidValue guideId,
    required _ix5zeh3i.GuideAudioUnavailableReason reason,
  }) = _GuideAudioUnavailableImpl;

  factory GuideAudioUnavailable.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return GuideAudioUnavailable(
      guideId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['guideId'],
      ),
      reason: _ix5zeh3i.GuideAudioUnavailableReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _ix5zeh3i.GuideAudioUnavailableReason reason;

  /// Returns a shallow copy of this [GuideAudioUnavailable]
  /// with some or all fields replaced by the given arguments.
  @override
  @_iss.useResult
  GuideAudioUnavailable copyWith({
    _iss.UuidValue? guideId,
    _ix5zeh3i.GuideAudioUnavailableReason? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GuideAudioUnavailable',
      'guideId': guideId.toJson(),
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GuideAudioUnavailable',
      'guideId': guideId.toJson(),
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GuideAudioUnavailableImpl extends GuideAudioUnavailable {
  _GuideAudioUnavailableImpl({
    required _iss.UuidValue guideId,
    required _ix5zeh3i.GuideAudioUnavailableReason reason,
  }) : super._(guideId: guideId, reason: reason);

  /// Returns a shallow copy of this [GuideAudioUnavailable]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GuideAudioUnavailable copyWith({
    _iss.UuidValue? guideId,
    _ix5zeh3i.GuideAudioUnavailableReason? reason,
  }) {
    return GuideAudioUnavailable(
      guideId: guideId ?? this.guideId,
      reason: reason ?? this.reason,
    );
  }
}
