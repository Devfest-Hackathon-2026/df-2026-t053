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
import 'package:photohunt_server/src/generated/protocol.dart' as _itornf4k;
import 'package:serverpod/serverpod.dart' as _is;

import '../../../infrastructure/seed/input/seed_goal_input.dart' as _izy1kfhx;

/// 版の内容。goal・story・highlight は公開 DTO に出さない。
abstract class SeedRevisionFields
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedRevisionFields._({
    required this.revisionNo,
    required this.sceneProfile,
    required this.scoringVersion,
    required this.photoAlt,
    required this.eyeHeightMeters,
    required this.shotVerticalFovDegrees,
    required this.goal,
    required this.story,
    required this.highlight,
  });

  factory SeedRevisionFields({
    required int revisionNo,
    required String sceneProfile,
    required String scoringVersion,
    required String photoAlt,
    required double eyeHeightMeters,
    required double shotVerticalFovDegrees,
    required _izy1kfhx.SeedGoalInput goal,
    required String story,
    required String highlight,
  }) = _SeedRevisionFieldsImpl;

  factory SeedRevisionFields.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedRevisionFields(
      revisionNo: jsonSerialization['revisionNo'] as int,
      sceneProfile: jsonSerialization['sceneProfile'] as String,
      scoringVersion: jsonSerialization['scoringVersion'] as String,
      photoAlt: jsonSerialization['photoAlt'] as String,
      eyeHeightMeters: (jsonSerialization['eyeHeightMeters'] as num).toDouble(),
      shotVerticalFovDegrees:
          (jsonSerialization['shotVerticalFovDegrees'] as num).toDouble(),
      goal: _itornf4k.Protocol().deserialize<_izy1kfhx.SeedGoalInput>(
        jsonSerialization['goal'],
      ),
      story: jsonSerialization['story'] as String,
      highlight: jsonSerialization['highlight'] as String,
    );
  }

  int revisionNo;

  String sceneProfile;

  String scoringVersion;

  String photoAlt;

  double eyeHeightMeters;

  double shotVerticalFovDegrees;

  _izy1kfhx.SeedGoalInput goal;

  String story;

  String highlight;

  /// Returns a shallow copy of this [SeedRevisionFields]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedRevisionFields copyWith({
    int? revisionNo,
    String? sceneProfile,
    String? scoringVersion,
    String? photoAlt,
    double? eyeHeightMeters,
    double? shotVerticalFovDegrees,
    _izy1kfhx.SeedGoalInput? goal,
    String? story,
    String? highlight,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedRevisionFields',
      'revisionNo': revisionNo,
      'sceneProfile': sceneProfile,
      'scoringVersion': scoringVersion,
      'photoAlt': photoAlt,
      'eyeHeightMeters': eyeHeightMeters,
      'shotVerticalFovDegrees': shotVerticalFovDegrees,
      'goal': goal.toJson(),
      'story': story,
      'highlight': highlight,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SeedRevisionFieldsImpl extends SeedRevisionFields {
  _SeedRevisionFieldsImpl({
    required int revisionNo,
    required String sceneProfile,
    required String scoringVersion,
    required String photoAlt,
    required double eyeHeightMeters,
    required double shotVerticalFovDegrees,
    required _izy1kfhx.SeedGoalInput goal,
    required String story,
    required String highlight,
  }) : super._(
         revisionNo: revisionNo,
         sceneProfile: sceneProfile,
         scoringVersion: scoringVersion,
         photoAlt: photoAlt,
         eyeHeightMeters: eyeHeightMeters,
         shotVerticalFovDegrees: shotVerticalFovDegrees,
         goal: goal,
         story: story,
         highlight: highlight,
       );

  /// Returns a shallow copy of this [SeedRevisionFields]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedRevisionFields copyWith({
    int? revisionNo,
    String? sceneProfile,
    String? scoringVersion,
    String? photoAlt,
    double? eyeHeightMeters,
    double? shotVerticalFovDegrees,
    _izy1kfhx.SeedGoalInput? goal,
    String? story,
    String? highlight,
  }) {
    return SeedRevisionFields(
      revisionNo: revisionNo ?? this.revisionNo,
      sceneProfile: sceneProfile ?? this.sceneProfile,
      scoringVersion: scoringVersion ?? this.scoringVersion,
      photoAlt: photoAlt ?? this.photoAlt,
      eyeHeightMeters: eyeHeightMeters ?? this.eyeHeightMeters,
      shotVerticalFovDegrees:
          shotVerticalFovDegrees ?? this.shotVerticalFovDegrees,
      goal: goal ?? this.goal.copyWith(),
      story: story ?? this.story,
      highlight: highlight ?? this.highlight,
    );
  }
}
