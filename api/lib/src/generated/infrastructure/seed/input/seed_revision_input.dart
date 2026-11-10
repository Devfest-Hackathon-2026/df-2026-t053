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
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod/serverpod.dart' as _is;

import '../../../infrastructure/seed/input/seed_assets_input.dart' as _ia4jf1i5;
import '../../../infrastructure/seed/input/seed_challenge_input.dart'
    as _iihn0yt5;
import '../../../infrastructure/seed/input/seed_landmark_input.dart'
    as _iavm5cu7;
import '../../../infrastructure/seed/input/seed_map_input.dart' as _i5nfujke;
import '../../../infrastructure/seed/input/seed_mode_input.dart' as _i5bgd8mz;
import '../../../infrastructure/seed/input/seed_revision_fields.dart'
    as _i4o593cg;
import '../../../infrastructure/seed/input/seed_structure_input.dart'
    as _ign3zemh;

/// seed の入力 1 版分（content/seeds/<slug>/r<n>/revision.yaml）。管理用 CLI だけが読む。
abstract class SeedRevisionInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedRevisionInput._({
    required this.challenge,
    required this.revision,
    required this.assets,
    required this.map,
    required this.modes,
    required this.landmarks,
    required this.credits,
    required this.structures,
  });

  factory SeedRevisionInput({
    required _iihn0yt5.SeedChallengeInput challenge,
    required _i4o593cg.SeedRevisionFields revision,
    required _ia4jf1i5.SeedAssetsInput assets,
    required _i5nfujke.SeedMapInput map,
    required List<_i5bgd8mz.SeedModeInput> modes,
    required List<_iavm5cu7.SeedLandmarkInput> landmarks,
    required List<_ix5zeh3i.Credit> credits,
    required List<_ign3zemh.SeedStructureInput> structures,
  }) = _SeedRevisionInputImpl;

  factory SeedRevisionInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedRevisionInput(
      challenge: _itornf4k.Protocol().deserialize<_iihn0yt5.SeedChallengeInput>(
        jsonSerialization['challenge'],
      ),
      revision: _itornf4k.Protocol().deserialize<_i4o593cg.SeedRevisionFields>(
        jsonSerialization['revision'],
      ),
      assets: _itornf4k.Protocol().deserialize<_ia4jf1i5.SeedAssetsInput>(
        jsonSerialization['assets'],
      ),
      map: _itornf4k.Protocol().deserialize<_i5nfujke.SeedMapInput>(
        jsonSerialization['map'],
      ),
      modes: _itornf4k.Protocol().deserialize<List<_i5bgd8mz.SeedModeInput>>(
        jsonSerialization['modes'],
      ),
      landmarks: _itornf4k.Protocol()
          .deserialize<List<_iavm5cu7.SeedLandmarkInput>>(
            jsonSerialization['landmarks'],
          ),
      credits: _itornf4k.Protocol().deserialize<List<_ix5zeh3i.Credit>>(
        jsonSerialization['credits'],
      ),
      structures: _itornf4k.Protocol()
          .deserialize<List<_ign3zemh.SeedStructureInput>>(
            jsonSerialization['structures'],
          ),
    );
  }

  _iihn0yt5.SeedChallengeInput challenge;

  _i4o593cg.SeedRevisionFields revision;

  _ia4jf1i5.SeedAssetsInput assets;

  _i5nfujke.SeedMapInput map;

  List<_i5bgd8mz.SeedModeInput> modes;

  List<_iavm5cu7.SeedLandmarkInput> landmarks;

  List<_ix5zeh3i.Credit> credits;

  List<_ign3zemh.SeedStructureInput> structures;

  /// Returns a shallow copy of this [SeedRevisionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedRevisionInput copyWith({
    _iihn0yt5.SeedChallengeInput? challenge,
    _i4o593cg.SeedRevisionFields? revision,
    _ia4jf1i5.SeedAssetsInput? assets,
    _i5nfujke.SeedMapInput? map,
    List<_i5bgd8mz.SeedModeInput>? modes,
    List<_iavm5cu7.SeedLandmarkInput>? landmarks,
    List<_ix5zeh3i.Credit>? credits,
    List<_ign3zemh.SeedStructureInput>? structures,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedRevisionInput',
      'challenge': challenge.toJson(),
      'revision': revision.toJson(),
      'assets': assets.toJson(),
      'map': map.toJson(),
      'modes': modes.toJson(valueToJson: (v) => v.toJson()),
      'landmarks': landmarks.toJson(valueToJson: (v) => v.toJson()),
      'credits': credits.toJson(valueToJson: (v) => v.toJson()),
      'structures': structures.toJson(valueToJson: (v) => v.toJson()),
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

class _SeedRevisionInputImpl extends SeedRevisionInput {
  _SeedRevisionInputImpl({
    required _iihn0yt5.SeedChallengeInput challenge,
    required _i4o593cg.SeedRevisionFields revision,
    required _ia4jf1i5.SeedAssetsInput assets,
    required _i5nfujke.SeedMapInput map,
    required List<_i5bgd8mz.SeedModeInput> modes,
    required List<_iavm5cu7.SeedLandmarkInput> landmarks,
    required List<_ix5zeh3i.Credit> credits,
    required List<_ign3zemh.SeedStructureInput> structures,
  }) : super._(
         challenge: challenge,
         revision: revision,
         assets: assets,
         map: map,
         modes: modes,
         landmarks: landmarks,
         credits: credits,
         structures: structures,
       );

  /// Returns a shallow copy of this [SeedRevisionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedRevisionInput copyWith({
    _iihn0yt5.SeedChallengeInput? challenge,
    _i4o593cg.SeedRevisionFields? revision,
    _ia4jf1i5.SeedAssetsInput? assets,
    _i5nfujke.SeedMapInput? map,
    List<_i5bgd8mz.SeedModeInput>? modes,
    List<_iavm5cu7.SeedLandmarkInput>? landmarks,
    List<_ix5zeh3i.Credit>? credits,
    List<_ign3zemh.SeedStructureInput>? structures,
  }) {
    return SeedRevisionInput(
      challenge: challenge ?? this.challenge.copyWith(),
      revision: revision ?? this.revision.copyWith(),
      assets: assets ?? this.assets.copyWith(),
      map: map ?? this.map.copyWith(),
      modes: modes ?? this.modes.map((e0) => e0.copyWith()).toList(),
      landmarks:
          landmarks ?? this.landmarks.map((e0) => e0.copyWith()).toList(),
      credits: credits ?? this.credits.map((e0) => e0.copyWith()).toList(),
      structures:
          structures ?? this.structures.map((e0) => e0.copyWith()).toList(),
    );
  }
}
