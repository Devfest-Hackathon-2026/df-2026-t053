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

/// 会場図。bounds は画像全体に対応するモデルローカルの範囲。
abstract class VenueMap
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  VenueMap._({
    required this.image,
    required this.bounds,
    required this.landmarks,
  });

  factory VenueMap({
    required _ix5zeh3i.AssetRef image,
    required _ix5zeh3i.MapBounds bounds,
    required List<_ix5zeh3i.Landmark> landmarks,
  }) = _VenueMapImpl;

  factory VenueMap.fromJson(Map<String, dynamic> jsonSerialization) {
    return VenueMap(
      image: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.AssetRef>(
        jsonSerialization['image'],
      ),
      bounds: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.MapBounds>(
        jsonSerialization['bounds'],
      ),
      landmarks: _ix5zeh3i.Protocol().deserialize<List<_ix5zeh3i.Landmark>>(
        jsonSerialization['landmarks'],
      ),
    );
  }

  _ix5zeh3i.AssetRef image;

  _ix5zeh3i.MapBounds bounds;

  List<_ix5zeh3i.Landmark> landmarks;

  /// Returns a shallow copy of this [VenueMap]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  VenueMap copyWith({
    _ix5zeh3i.AssetRef? image,
    _ix5zeh3i.MapBounds? bounds,
    List<_ix5zeh3i.Landmark>? landmarks,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VenueMap',
      'image': image.toJson(),
      'bounds': bounds.toJson(),
      'landmarks': landmarks.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VenueMap',
      'image': image.toJsonForProtocol(),
      'bounds': bounds.toJsonForProtocol(),
      'landmarks': landmarks.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _VenueMapImpl extends VenueMap {
  _VenueMapImpl({
    required _ix5zeh3i.AssetRef image,
    required _ix5zeh3i.MapBounds bounds,
    required List<_ix5zeh3i.Landmark> landmarks,
  }) : super._(image: image, bounds: bounds, landmarks: landmarks);

  /// Returns a shallow copy of this [VenueMap]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  VenueMap copyWith({
    _ix5zeh3i.AssetRef? image,
    _ix5zeh3i.MapBounds? bounds,
    List<_ix5zeh3i.Landmark>? landmarks,
  }) {
    return VenueMap(
      image: image ?? this.image.copyWith(),
      bounds: bounds ?? this.bounds.copyWith(),
      landmarks:
          landmarks ?? this.landmarks.map((e0) => e0.copyWith()).toList(),
    );
  }
}
