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

/// 会場図。bounds は画像全体に対応するモデルローカルの範囲。
abstract class SeedMapInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedMapInput._({required this.bounds});

  factory SeedMapInput({required _ix5zeh3i.MapBounds bounds}) =
      _SeedMapInputImpl;

  factory SeedMapInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedMapInput(
      bounds: _itornf4k.Protocol().deserialize<_ix5zeh3i.MapBounds>(
        jsonSerialization['bounds'],
      ),
    );
  }

  _ix5zeh3i.MapBounds bounds;

  /// Returns a shallow copy of this [SeedMapInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedMapInput copyWith({_ix5zeh3i.MapBounds? bounds});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'SeedMapInput', 'bounds': bounds.toJson()};
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

class _SeedMapInputImpl extends SeedMapInput {
  _SeedMapInputImpl({required _ix5zeh3i.MapBounds bounds})
    : super._(bounds: bounds);

  /// Returns a shallow copy of this [SeedMapInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedMapInput copyWith({_ix5zeh3i.MapBounds? bounds}) {
    return SeedMapInput(bounds: bounds ?? this.bounds.copyWith());
  }
}
