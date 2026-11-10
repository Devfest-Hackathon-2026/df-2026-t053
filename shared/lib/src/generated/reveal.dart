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

/// 撮影後に明かす正解と解説。撮影前の応答には含めない。
abstract class Reveal
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Reveal._({
    required this.goalCamera,
    required this.story,
    required this.highlight,
  });

  factory Reveal({
    required _ix5zeh3i.CameraPose goalCamera,
    required String story,
    required String highlight,
  }) = _RevealImpl;

  factory Reveal.fromJson(Map<String, dynamic> jsonSerialization) {
    return Reveal(
      goalCamera: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.CameraPose>(
        jsonSerialization['goalCamera'],
      ),
      story: jsonSerialization['story'] as String,
      highlight: jsonSerialization['highlight'] as String,
    );
  }

  _ix5zeh3i.CameraPose goalCamera;

  String story;

  String highlight;

  /// Returns a shallow copy of this [Reveal]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Reveal copyWith({
    _ix5zeh3i.CameraPose? goalCamera,
    String? story,
    String? highlight,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Reveal',
      'goalCamera': goalCamera.toJson(),
      'story': story,
      'highlight': highlight,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Reveal',
      'goalCamera': goalCamera.toJsonForProtocol(),
      'story': story,
      'highlight': highlight,
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _RevealImpl extends Reveal {
  _RevealImpl({
    required _ix5zeh3i.CameraPose goalCamera,
    required String story,
    required String highlight,
  }) : super._(goalCamera: goalCamera, story: story, highlight: highlight);

  /// Returns a shallow copy of this [Reveal]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Reveal copyWith({
    _ix5zeh3i.CameraPose? goalCamera,
    String? story,
    String? highlight,
  }) {
    return Reveal(
      goalCamera: goalCamera ?? this.goalCamera.copyWith(),
      story: story ?? this.story,
      highlight: highlight ?? this.highlight,
    );
  }
}
