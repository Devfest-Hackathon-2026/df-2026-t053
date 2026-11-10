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

/// 音声が利用できない理由。未知の値は UNKNOWN（汎用の音声利用不可）として扱う。
enum GuideAudioUnavailableReason implements _iss.SerializableModel {
  UNKNOWN,
  TTS_FAILED,
  AUDIO_TIMEOUT,
  TEXT_FALLBACK;

  static GuideAudioUnavailableReason fromJson(String name) {
    switch (name) {
      case 'UNKNOWN':
        return GuideAudioUnavailableReason.UNKNOWN;
      case 'TTS_FAILED':
        return GuideAudioUnavailableReason.TTS_FAILED;
      case 'AUDIO_TIMEOUT':
        return GuideAudioUnavailableReason.AUDIO_TIMEOUT;
      case 'TEXT_FALLBACK':
        return GuideAudioUnavailableReason.TEXT_FALLBACK;
      default:
        return GuideAudioUnavailableReason.UNKNOWN;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
