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

/// 撮影の確定結果。
abstract class Shot
    implements _iss.SerializableModel, _iss.ProtocolSerialization {
  Shot._({
    required this.id,
    required this.camera,
    required this.score,
    required this.distanceMeters,
    required this.yawDiffDegrees,
    required this.pitchDiffDegrees,
    required this.createTime,
  });

  factory Shot({
    required int id,
    required _ix5zeh3i.CameraPose camera,
    required int score,
    required double distanceMeters,
    required double yawDiffDegrees,
    required double pitchDiffDegrees,
    required DateTime createTime,
  }) = _ShotImpl;

  factory Shot.fromJson(Map<String, dynamic> jsonSerialization) {
    return Shot(
      id: jsonSerialization['id'] as int,
      camera: _ix5zeh3i.Protocol().deserialize<_ix5zeh3i.CameraPose>(
        jsonSerialization['camera'],
      ),
      score: jsonSerialization['score'] as int,
      distanceMeters: (jsonSerialization['distanceMeters'] as num).toDouble(),
      yawDiffDegrees: (jsonSerialization['yawDiffDegrees'] as num).toDouble(),
      pitchDiffDegrees: (jsonSerialization['pitchDiffDegrees'] as num)
          .toDouble(),
      createTime: _iss.DateTimeJsonExtension.fromJson(
        jsonSerialization['createTime'],
      ),
    );
  }

  int id;

  _ix5zeh3i.CameraPose camera;

  int score;

  double distanceMeters;

  double yawDiffDegrees;

  double pitchDiffDegrees;

  DateTime createTime;

  /// Returns a shallow copy of this [Shot]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  Shot copyWith({
    int? id,
    _ix5zeh3i.CameraPose? camera,
    int? score,
    double? distanceMeters,
    double? yawDiffDegrees,
    double? pitchDiffDegrees,
    DateTime? createTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Shot',
      'id': id,
      'camera': camera.toJson(),
      'score': score,
      'distanceMeters': distanceMeters,
      'yawDiffDegrees': yawDiffDegrees,
      'pitchDiffDegrees': pitchDiffDegrees,
      'createTime': createTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Shot',
      'id': id,
      'camera': camera.toJsonForProtocol(),
      'score': score,
      'distanceMeters': distanceMeters,
      'yawDiffDegrees': yawDiffDegrees,
      'pitchDiffDegrees': pitchDiffDegrees,
      'createTime': createTime.toJson(),
    };
  }

  @override
  String toString() {
    return _iss.SerializationManager.encode(this);
  }
}

class _ShotImpl extends Shot {
  _ShotImpl({
    required int id,
    required _ix5zeh3i.CameraPose camera,
    required int score,
    required double distanceMeters,
    required double yawDiffDegrees,
    required double pitchDiffDegrees,
    required DateTime createTime,
  }) : super._(
         id: id,
         camera: camera,
         score: score,
         distanceMeters: distanceMeters,
         yawDiffDegrees: yawDiffDegrees,
         pitchDiffDegrees: pitchDiffDegrees,
         createTime: createTime,
       );

  /// Returns a shallow copy of this [Shot]
  /// with some or all fields replaced by the given arguments.
  @_iss.useResult
  @override
  Shot copyWith({
    int? id,
    _ix5zeh3i.CameraPose? camera,
    int? score,
    double? distanceMeters,
    double? yawDiffDegrees,
    double? pitchDiffDegrees,
    DateTime? createTime,
  }) {
    return Shot(
      id: id ?? this.id,
      camera: camera ?? this.camera.copyWith(),
      score: score ?? this.score,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      yawDiffDegrees: yawDiffDegrees ?? this.yawDiffDegrees,
      pitchDiffDegrees: pitchDiffDegrees ?? this.pitchDiffDegrees,
      createTime: createTime ?? this.createTime,
    );
  }
}
