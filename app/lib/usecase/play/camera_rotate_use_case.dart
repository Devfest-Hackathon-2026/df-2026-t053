import 'dart:ui' show Offset;

import 'package:app/model/camera_direction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_rotate_use_case.g.dart';

@riverpod
class CameraRotateUseCase extends _$CameraRotateUseCase {
  @override
  void build() {}

  CameraDirection call({
    required CameraDirection current,
    required Offset delta,
    double sensitivity = 0.005,
  }) {
    var n = current.n;
    var e = current.e;
    var w = current.w;
    var s = current.s;

    if (delta.dy < 0) {
      n += -delta.dy * sensitivity;
    } else if (delta.dy > 0) {
      s += delta.dy * sensitivity;
    }

    if (delta.dx > 0) {
      e += delta.dx * sensitivity;
    } else if (delta.dx < 0) {
      w += -delta.dx * sensitivity;
    }

    return CameraDirection(n: n, e: e, w: w, s: s);
  }
}
