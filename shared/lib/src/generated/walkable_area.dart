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

/// 歩行できる領域。外周と、0 個以上の穴で表す。
abstract class WalkableArea
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  WalkableArea._({required this.outer, required this.holes});

  factory WalkableArea({
    required List<_ix5zeh3i.PointXZ> outer,
    required List<List<_ix5zeh3i.PointXZ>> holes,
  }) = _WalkableAreaImpl;

  factory WalkableArea.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalkableArea(
      outer: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.PointXZ>>(
        jsonSerialization['outer'],
      ),
      holes: _ix5zeh3i.Protocol().deserialize<List<List<_ix5zeh3i.PointXZ>>>(
        jsonSerialization['holes'],
      ),
    );
  }

  List<_ix5zeh3i.PointXZ> outer;

  List<List<_ix5zeh3i.PointXZ>> holes;

  /// Returns a shallow copy of this [WalkableArea]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  WalkableArea copyWith({
    List<_ix5zeh3i.PointXZ>? outer,
    List<List<_ix5zeh3i.PointXZ>>? holes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalkableArea',
      'outer': outer.toJson(valueToJson: (v) => v.toJson()),
      'holes': holes.toJson(
        valueToJson: (v) => v.toJson(valueToJson: (v) => v.toJson()),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalkableArea',
      'outer': outer.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'holes': holes.toJson(
        valueToJson: (v) => v.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      ),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _WalkableAreaImpl extends WalkableArea {
  _WalkableAreaImpl({
    required List<_ix5zeh3i.PointXZ> outer,
    required List<List<_ix5zeh3i.PointXZ>> holes,
  }) : super._(outer: outer, holes: holes);

  /// Returns a shallow copy of this [WalkableArea]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  WalkableArea copyWith({
    List<_ix5zeh3i.PointXZ>? outer,
    List<List<_ix5zeh3i.PointXZ>>? holes,
  }) {
    return WalkableArea(
      outer: outer ?? this.outer.map((e0) => e0.copyWith()).toList(),
      holes:
          holes ??
          this.holes
              .map((e0) => e0.map((e1) => e1.copyWith()).toList())
              .toList(),
    );
  }
}
