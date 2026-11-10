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

/// ガイド本文。必ず先頭に 1 回。生成成功なら aiGenerated=true、固定文なら false。
abstract class GuideText extends _ix5zeh3i.NearbyGuideEvent
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  GuideText._({
    required super.guideId,
    required this.text,
    required this.structures,
    required this.sources,
    required this.aiGenerated,
  });

  factory GuideText({
    required _iss.UuidValue guideId,
    required String text,
    required List<String> structures,
    required List<_ix5zeh3i.GuideSource> sources,
    required bool aiGenerated,
  }) = _GuideTextImpl;

  factory GuideText.fromJson(Map<String, dynamic> jsonSerialization) {
    return GuideText(
      guideId: _iss.UuidValueJsonExtension.fromJson(
        jsonSerialization['guideId'],
      ),
      text: jsonSerialization['text'] as String,
      structures: _ix5zeh3i.Protocol().deserialize<List<String>>(
        jsonSerialization['structures'],
      ),
      sources: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.GuideSource>>(
        jsonSerialization['sources'],
      ),
      aiGenerated: _iss.BoolJsonExtension.fromJson(
        jsonSerialization['aiGenerated'],
      ),
    );
  }

  String text;

  List<String> structures;

  List<_ix5zeh3i.GuideSource> sources;

  bool aiGenerated;

  /// Returns a shallow copy of this [GuideText]
  /// with some or all fields replaced by the given arguments.
  @override
  @_iss.useResult
  GuideText copyWith({
    _iss.UuidValue? guideId,
    String? text,
    List<String>? structures,
    List<_ix5zeh3i.GuideSource>? sources,
    bool? aiGenerated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GuideText',
      'guideId': guideId.toJson(),
      'text': text,
      'structures': structures.toJson(),
      'sources': sources.toJson(valueToJson: (v) => v.toJson()),
      'aiGenerated': aiGenerated,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GuideText',
      'guideId': guideId.toJson(),
      'text': text,
      'structures': structures.toJson(),
      'sources': sources.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'aiGenerated': aiGenerated,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _GuideTextImpl extends GuideText {
  _GuideTextImpl({
    required _iss.UuidValue guideId,
    required String text,
    required List<String> structures,
    required List<_ix5zeh3i.GuideSource> sources,
    required bool aiGenerated,
  }) : super._(
         guideId: guideId,
         text: text,
         structures: structures,
         sources: sources,
         aiGenerated: aiGenerated,
       );

  /// Returns a shallow copy of this [GuideText]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  GuideText copyWith({
    _iss.UuidValue? guideId,
    String? text,
    List<String>? structures,
    List<_ix5zeh3i.GuideSource>? sources,
    bool? aiGenerated,
  }) {
    return GuideText(
      guideId: guideId ?? this.guideId,
      text: text ?? this.text,
      structures: structures ?? this.structures.map((e0) => e0).toList(),
      sources: sources ?? this.sources.map((e0) => e0.copyWith()).toList(),
      aiGenerated: aiGenerated ?? this.aiGenerated,
    );
  }
}
