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

import '../../../infrastructure/seed/input/seed_asset_file_input.dart'
    as _iyf1gm05;

/// 公開素材（写真・会場図）。3D モデルはアプリ同梱のため含めない。
abstract class SeedAssetsInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedAssetsInput._({required this.photo, required this.map});

  factory SeedAssetsInput({
    required _iyf1gm05.SeedAssetFileInput photo,
    required _iyf1gm05.SeedAssetFileInput map,
  }) = _SeedAssetsInputImpl;

  factory SeedAssetsInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedAssetsInput(
      photo: _itornf4k.Protocol().deserialize<_iyf1gm05.SeedAssetFileInput>(
        jsonSerialization['photo'],
      ),
      map: _itornf4k.Protocol().deserialize<_iyf1gm05.SeedAssetFileInput>(
        jsonSerialization['map'],
      ),
    );
  }

  _iyf1gm05.SeedAssetFileInput photo;

  _iyf1gm05.SeedAssetFileInput map;

  /// Returns a shallow copy of this [SeedAssetsInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedAssetsInput copyWith({
    _iyf1gm05.SeedAssetFileInput? photo,
    _iyf1gm05.SeedAssetFileInput? map,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedAssetsInput',
      'photo': photo.toJson(),
      'map': map.toJson(),
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

class _SeedAssetsInputImpl extends SeedAssetsInput {
  _SeedAssetsInputImpl({
    required _iyf1gm05.SeedAssetFileInput photo,
    required _iyf1gm05.SeedAssetFileInput map,
  }) : super._(photo: photo, map: map);

  /// Returns a shallow copy of this [SeedAssetsInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedAssetsInput copyWith({
    _iyf1gm05.SeedAssetFileInput? photo,
    _iyf1gm05.SeedAssetFileInput? map,
  }) {
    return SeedAssetsInput(
      photo: photo ?? this.photo.copyWith(),
      map: map ?? this.map.copyWith(),
    );
  }
}
