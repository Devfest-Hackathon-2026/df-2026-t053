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

/// モードごとの歩行可能領域。entrances は自由探索の入口（id と表示名だけ）。
abstract class ModeConfig
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  ModeConfig._({
    required this.mode,
    required this.walkable,
    required this.entrances,
  });

  factory ModeConfig({
    required _ix5zeh3i.PlayMode mode,
    required _ix5zeh3i.WalkableArea walkable,
    required List<_ix5zeh3i.SpawnEntrance> entrances,
  }) = _ModeConfigImpl;

  factory ModeConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModeConfig(
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      walkable: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.WalkableArea>(
        jsonSerialization['walkable'],
      ),
      entrances: _ix5zeh3i.Protocol()
          .deserialize<List<_ix5zeh3i.SpawnEntrance>>(
            jsonSerialization['entrances'],
          ),
    );
  }

  _ix5zeh3i.PlayMode mode;

  _ix5zeh3i.WalkableArea walkable;

  List<_ix5zeh3i.SpawnEntrance> entrances;

  /// Returns a shallow copy of this [ModeConfig]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  ModeConfig copyWith({
    _ix5zeh3i.PlayMode? mode,
    _ix5zeh3i.WalkableArea? walkable,
    List<_ix5zeh3i.SpawnEntrance>? entrances,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ModeConfig',
      'mode': mode.toJson(),
      'walkable': walkable.toJson(),
      'entrances': entrances.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ModeConfig',
      'mode': mode.toJson(),
      'walkable': walkable.toJsonForProtocol(),
      'entrances': entrances.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ModeConfigImpl extends ModeConfig {
  _ModeConfigImpl({
    required _ix5zeh3i.PlayMode mode,
    required _ix5zeh3i.WalkableArea walkable,
    required List<_ix5zeh3i.SpawnEntrance> entrances,
  }) : super._(mode: mode, walkable: walkable, entrances: entrances);

  /// Returns a shallow copy of this [ModeConfig]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  ModeConfig copyWith({
    _ix5zeh3i.PlayMode? mode,
    _ix5zeh3i.WalkableArea? walkable,
    List<_ix5zeh3i.SpawnEntrance>? entrances,
  }) {
    return ModeConfig(
      mode: mode ?? this.mode,
      walkable: walkable ?? this.walkable.copyWith(),
      entrances:
          entrances ?? this.entrances.map((e0) => e0.copyWith()).toList(),
    );
  }
}
