import 'package:freezed_annotation/freezed_annotation.dart';

part 'camera_direction.freezed.dart';

@freezed
abstract class CameraDirection with _$CameraDirection {
  const factory CameraDirection({
    required double n,
    required double e,
    required double w,
    required double s,
  }) = _CameraDirection;
}
