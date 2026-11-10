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

/// WAV 音声の断片。sequence=0 から連番、各 data は 1〜32768 bytes。最後だけ last=true。
abstract class GuideAudioChunk extends _ix5zeh3i.NearbyGuideEvent
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GuideAudioChunk._({
    required super.guideId,
    required this.sequence,
    required this.data,
    required this.contentType,
    required this.last,
  });

  factory GuideAudioChunk({
    required _iss.UuidValue guideId,
    required int sequence,
    required _idt.ByteData data,
    required String contentType,
    required bool last,
  }) = _GuideAudioChunkImpl;

  factory GuideAudioChunk.fromJson(Map<String, dynamic> jsonSerialization) {
    return GuideAudioChunk(
      guideId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['guideId'],
      ),
      sequence: jsonSerialization['sequence'] as int,
      data: _iss.ByteDataJsonExtension.fromJson(jsonSerialization['data']),
      contentType: jsonSerialization['contentType'] as String,
      last: _iss.BoolJsonExtension.fromJson(jsonSerialization['last']),
    );
  }

  int sequence;

  _idt.ByteData data;

  String contentType;

  bool last;

  /// Returns a shallow copy of this [GuideAudioChunk]
  /// with some or all fields replaced by the given arguments.
  @override
  @_iss.useResult
  GuideAudioChunk copyWith({
    _iss.UuidValue? guideId,
    int? sequence,
    _idt.ByteData? data,
    String? contentType,
    bool? last,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GuideAudioChunk',
      'guideId': guideId.toJson(),
      'sequence': sequence,
      'data': data.toJson(),
      'contentType': contentType,
      'last': last,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GuideAudioChunk',
      'guideId': guideId.toJson(),
      'sequence': sequence,
      'data': data.toJson(),
      'contentType': contentType,
      'last': last,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GuideAudioChunkImpl extends GuideAudioChunk {
  _GuideAudioChunkImpl({
    required _iss.UuidValue guideId,
    required int sequence,
    required _idt.ByteData data,
    required String contentType,
    required bool last,
  }) : super._(
         guideId: guideId,
         sequence: sequence,
         data: data,
         contentType: contentType,
         last: last,
       );

  /// Returns a shallow copy of this [GuideAudioChunk]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GuideAudioChunk copyWith({
    _iss.UuidValue? guideId,
    int? sequence,
    _idt.ByteData? data,
    String? contentType,
    bool? last,
  }) {
    return GuideAudioChunk(
      guideId: guideId ?? this.guideId,
      sequence: sequence ?? this.sequence,
      data: data ?? this.data.clone(),
      contentType: contentType ?? this.contentType,
      last: last ?? this.last,
    );
  }
}
