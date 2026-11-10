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

/// ガイド用の構造物資料。
abstract class SeedStructureInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SeedStructureInput._({
    required this.name,
    this.pavilionKey,
    required this.positionX,
    required this.positionZ,
    required this.facts,
    required this.fallbackText,
    required this.sources,
  });

  factory SeedStructureInput({
    required String name,
    String? pavilionKey,
    required double positionX,
    required double positionZ,
    required String facts,
    required String fallbackText,
    required List<_ix5zeh3i.GuideSource> sources,
  }) = _SeedStructureInputImpl;

  factory SeedStructureInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeedStructureInput(
      name: jsonSerialization['name'] as String,
      pavilionKey: jsonSerialization['pavilionKey'] as String?,
      positionX: (jsonSerialization['positionX'] as num).toDouble(),
      positionZ: (jsonSerialization['positionZ'] as num).toDouble(),
      facts: jsonSerialization['facts'] as String,
      fallbackText: jsonSerialization['fallbackText'] as String,
      sources: _itornf4k.Protocol().deserialize<List<_ix5zeh3i.GuideSource>>(
        jsonSerialization['sources'],
      ),
    );
  }

  String name;

  String? pavilionKey;

  double positionX;

  double positionZ;

  String facts;

  String fallbackText;

  List<_ix5zeh3i.GuideSource> sources;

  /// Returns a shallow copy of this [SeedStructureInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeedStructureInput copyWith({
    String? name,
    String? pavilionKey,
    double? positionX,
    double? positionZ,
    String? facts,
    String? fallbackText,
    List<_ix5zeh3i.GuideSource>? sources,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeedStructureInput',
      'name': name,
      if (pavilionKey != null) 'pavilionKey': pavilionKey,
      'positionX': positionX,
      'positionZ': positionZ,
      'facts': facts,
      'fallbackText': fallbackText,
      'sources': sources.toJson(valueToJson: (v) => v.toJson()),
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

class _Undefined {}

class _SeedStructureInputImpl extends SeedStructureInput {
  _SeedStructureInputImpl({
    required String name,
    String? pavilionKey,
    required double positionX,
    required double positionZ,
    required String facts,
    required String fallbackText,
    required List<_ix5zeh3i.GuideSource> sources,
  }) : super._(
         name: name,
         pavilionKey: pavilionKey,
         positionX: positionX,
         positionZ: positionZ,
         facts: facts,
         fallbackText: fallbackText,
         sources: sources,
       );

  /// Returns a shallow copy of this [SeedStructureInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeedStructureInput copyWith({
    String? name,
    Object? pavilionKey = _Undefined,
    double? positionX,
    double? positionZ,
    String? facts,
    String? fallbackText,
    List<_ix5zeh3i.GuideSource>? sources,
  }) {
    return SeedStructureInput(
      name: name ?? this.name,
      pavilionKey: pavilionKey is String? ? pavilionKey : this.pavilionKey,
      positionX: positionX ?? this.positionX,
      positionZ: positionZ ?? this.positionZ,
      facts: facts ?? this.facts,
      fallbackText: fallbackText ?? this.fallbackText,
      sources: sources ?? this.sources.map((e0) => e0.copyWith()).toList(),
    );
  }
}
