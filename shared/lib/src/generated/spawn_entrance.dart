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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

/// 自由探索で選べる入口。座標は含めない。
abstract class SpawnEntrance
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  SpawnEntrance._({required this.id, required this.label});

  factory SpawnEntrance({required int id, required String label}) =
      _SpawnEntranceImpl;

  factory SpawnEntrance.fromJson(Map<String, dynamic> jsonSerialization) {
    return SpawnEntrance(
      id: jsonSerialization['id'] as int,
      label: jsonSerialization['label'] as String,
    );
  }

  int id;

  String label;

  /// Returns a shallow copy of this [SpawnEntrance]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  SpawnEntrance copyWith({int? id, String? label});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'SpawnEntrance', 'id': id, 'label': label};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'__className__': 'SpawnEntrance', 'id': id, 'label': label};
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _SpawnEntranceImpl extends SpawnEntrance {
  _SpawnEntranceImpl({required int id, required String label})
    : super._(id: id, label: label);

  /// Returns a shallow copy of this [SpawnEntrance]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  SpawnEntrance copyWith({int? id, String? label}) {
    return SpawnEntrance(id: id ?? this.id, label: label ?? this.label);
  }
}
