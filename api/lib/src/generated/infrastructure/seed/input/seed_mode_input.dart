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

import '../../../infrastructure/seed/input/seed_spawn_input.dart' as _iswddhi7;

/// モードごとの歩行領域と開始点（free は 2〜32 件、near は 1 件）。
abstract class SeedModeInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedModeInput._({
    required this.mode,
    required this.walkable,
    required this.spawns,
  });

  factory SeedModeInput({
    required _ix5zeh3i.PlayMode mode,
    required _ix5zeh3i.WalkableArea walkable,
    required List<_iswddhi7.SeedSpawnInput> spawns,
  }) = _SeedModeInputImpl;

  factory SeedModeInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedModeInput(
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      walkable: _itornf4k.Protocol().deserialize<_ix5zeh3i.WalkableArea>(
        jsonSerialization['walkable'],
      ),
      spawns: _itornf4k.Protocol().deserialize<List<_iswddhi7.SeedSpawnInput>>(
        jsonSerialization['spawns'],
      ),
    );
  }

  _ix5zeh3i.PlayMode mode;

  _ix5zeh3i.WalkableArea walkable;

  List<_iswddhi7.SeedSpawnInput> spawns;

  /// Returns a shallow copy of this [SeedModeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedModeInput copyWith({
    _ix5zeh3i.PlayMode? mode,
    _ix5zeh3i.WalkableArea? walkable,
    List<_iswddhi7.SeedSpawnInput>? spawns,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedModeInput',
      'mode': mode.toJson(),
      'walkable': walkable.toJson(),
      'spawns': spawns.toJson(valueToJson: (v) => v.toJson()),
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

class _SeedModeInputImpl extends SeedModeInput {
  _SeedModeInputImpl({
    required _ix5zeh3i.PlayMode mode,
    required _ix5zeh3i.WalkableArea walkable,
    required List<_iswddhi7.SeedSpawnInput> spawns,
  }) : super._(mode: mode, walkable: walkable, spawns: spawns);

  /// Returns a shallow copy of this [SeedModeInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedModeInput copyWith({
    _ix5zeh3i.PlayMode? mode,
    _ix5zeh3i.WalkableArea? walkable,
    List<_iswddhi7.SeedSpawnInput>? spawns,
  }) {
    return SeedModeInput(
      mode: mode ?? this.mode,
      walkable: walkable ?? this.walkable.copyWith(),
      spawns: spawns ?? this.spawns.map((e0) => e0.copyWith()).toList(),
    );
  }
}
