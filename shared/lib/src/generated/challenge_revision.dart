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

/// 出題の不変な公開版。正解・解説・開始候補は含めない。
abstract class ChallengeRevision
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ChallengeRevision._({
    required this.id,
    required this.challengeId,
    required this.sceneProfile,
    required this.photo,
    required this.photoAlt,
    required this.map,
    required this.modes,
    required this.eyeHeightMeters,
    required this.shotVerticalFovDegrees,
    required this.credits,
  });

  factory ChallengeRevision({
    required int id,
    required int challengeId,
    required String sceneProfile,
    required _ix5zeh3i.AssetRef photo,
    required String photoAlt,
    required _ix5zeh3i.VenueMap map,
    required List<_ix5zeh3i.ModeConfig> modes,
    required double eyeHeightMeters,
    required double shotVerticalFovDegrees,
    required List<_ix5zeh3i.Credit> credits,
  }) = _ChallengeRevisionImpl;

  factory ChallengeRevision.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChallengeRevision(
      id: jsonSerialization['id'] as int,
      challengeId: jsonSerialization['challengeId'] as int,
      sceneProfile: jsonSerialization['sceneProfile'] as String,
      photo: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.AssetRef>(
        jsonSerialization['photo'],
      ),
      photoAlt: jsonSerialization['photoAlt'] as String,
      map: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.VenueMap>(
        jsonSerialization['map'],
      ),
      modes: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.ModeConfig>>(
        jsonSerialization['modes'],
      ),
      eyeHeightMeters: (jsonSerialization['eyeHeightMeters'] as num).toDouble(),
      shotVerticalFovDegrees:
          (jsonSerialization['shotVerticalFovDegrees'] as num).toDouble(),
      credits: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.Credit>>(
        jsonSerialization['credits'],
      ),
    );
  }

  int id;

  int challengeId;

  String sceneProfile;

  _ix5zeh3i.AssetRef photo;

  String photoAlt;

  _ix5zeh3i.VenueMap map;

  List<_ix5zeh3i.ModeConfig> modes;

  double eyeHeightMeters;

  double shotVerticalFovDegrees;

  List<_ix5zeh3i.Credit> credits;

  /// Returns a shallow copy of this [ChallengeRevision]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ChallengeRevision copyWith({
    int? id,
    int? challengeId,
    String? sceneProfile,
    _ix5zeh3i.AssetRef? photo,
    String? photoAlt,
    _ix5zeh3i.VenueMap? map,
    List<_ix5zeh3i.ModeConfig>? modes,
    double? eyeHeightMeters,
    double? shotVerticalFovDegrees,
    List<_ix5zeh3i.Credit>? credits,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChallengeRevision',
      'id': id,
      'challengeId': challengeId,
      'sceneProfile': sceneProfile,
      'photo': photo.toJson(),
      'photoAlt': photoAlt,
      'map': map.toJson(),
      'modes': modes.toJson(valueToJson: (v) => v.toJson()),
      'eyeHeightMeters': eyeHeightMeters,
      'shotVerticalFovDegrees': shotVerticalFovDegrees,
      'credits': credits.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChallengeRevision',
      'id': id,
      'challengeId': challengeId,
      'sceneProfile': sceneProfile,
      'photo': photo.toJsonForProtocol(),
      'photoAlt': photoAlt,
      'map': map.toJsonForProtocol(),
      'modes': modes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'eyeHeightMeters': eyeHeightMeters,
      'shotVerticalFovDegrees': shotVerticalFovDegrees,
      'credits': credits.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ChallengeRevisionImpl extends ChallengeRevision {
  _ChallengeRevisionImpl({
    required int id,
    required int challengeId,
    required String sceneProfile,
    required _ix5zeh3i.AssetRef photo,
    required String photoAlt,
    required _ix5zeh3i.VenueMap map,
    required List<_ix5zeh3i.ModeConfig> modes,
    required double eyeHeightMeters,
    required double shotVerticalFovDegrees,
    required List<_ix5zeh3i.Credit> credits,
  }) : super._(
         id: id,
         challengeId: challengeId,
         sceneProfile: sceneProfile,
         photo: photo,
         photoAlt: photoAlt,
         map: map,
         modes: modes,
         eyeHeightMeters: eyeHeightMeters,
         shotVerticalFovDegrees: shotVerticalFovDegrees,
         credits: credits,
       );

  /// Returns a shallow copy of this [ChallengeRevision]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ChallengeRevision copyWith({
    int? id,
    int? challengeId,
    String? sceneProfile,
    _ix5zeh3i.AssetRef? photo,
    String? photoAlt,
    _ix5zeh3i.VenueMap? map,
    List<_ix5zeh3i.ModeConfig>? modes,
    double? eyeHeightMeters,
    double? shotVerticalFovDegrees,
    List<_ix5zeh3i.Credit>? credits,
  }) {
    return ChallengeRevision(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      sceneProfile: sceneProfile ?? this.sceneProfile,
      photo: photo ?? this.photo.copyWith(),
      photoAlt: photoAlt ?? this.photoAlt,
      map: map ?? this.map.copyWith(),
      modes: modes ?? this.modes.map((e0) => e0.copyWith()).toList(),
      eyeHeightMeters: eyeHeightMeters ?? this.eyeHeightMeters,
      shotVerticalFovDegrees:
          shotVerticalFovDegrees ?? this.shotVerticalFovDegrees,
      credits: credits ?? this.credits.map((e0) => e0.copyWith()).toList(),
    );
  }
}
