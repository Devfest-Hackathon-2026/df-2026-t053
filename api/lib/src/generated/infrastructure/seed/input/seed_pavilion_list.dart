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

import '../../../infrastructure/seed/input/seed_pavilion_input.dart'
    as _ihzmtbij;

/// pavilion マスターの入力（content/seeds/pavilions.yaml）。
abstract class SeedPavilionList
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedPavilionList._({required this.pavilions});

  factory SeedPavilionList({
    required List<_ihzmtbij.SeedPavilionInput> pavilions,
  }) = _SeedPavilionListImpl;

  factory SeedPavilionList.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedPavilionList(
      pavilions: _itornf4k.Protocol()
          .deserialize<List<_ihzmtbij.SeedPavilionInput>>(
            jsonSerialization['pavilions'],
          ),
    );
  }

  List<_ihzmtbij.SeedPavilionInput> pavilions;

  /// Returns a shallow copy of this [SeedPavilionList]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedPavilionList copyWith({List<_ihzmtbij.SeedPavilionInput>? pavilions});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedPavilionList',
      'pavilions': pavilions.toJson(valueToJson: (v) => v.toJson()),
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

class _SeedPavilionListImpl extends SeedPavilionList {
  _SeedPavilionListImpl({required List<_ihzmtbij.SeedPavilionInput> pavilions})
    : super._(pavilions: pavilions);

  /// Returns a shallow copy of this [SeedPavilionList]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedPavilionList copyWith({List<_ihzmtbij.SeedPavilionInput>? pavilions}) {
    return SeedPavilionList(
      pavilions:
          pavilions ?? this.pavilions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
