import 'dart:ui' show Offset, Rect;

import 'package:app/model/position.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_projection.g.dart';

@riverpod
class MapProjectionUseCase extends _$MapProjectionUseCase {
  @override
  void build() {}

  /// Projects the XZ plane onto a north-up map. [Position.y] is world Z.
  Offset worldToMap(
    Position position, {
    required Rect worldBounds,
    required Rect viewport,
  }) {
    final imageRect = fittedMapRect(worldBounds, viewport);
    final u = (position.x - worldBounds.left) / worldBounds.width;
    final v = (position.y - worldBounds.top) / worldBounds.height;
    return Offset(
      imageRect.left + u * imageRect.width,
      imageRect.top + v * imageRect.height,
    );
  }

  /// The image and its overlays use the same fitted rectangle.
  Rect fittedMapRect(Rect worldBounds, Rect viewport) {
    if (!worldBounds.isFinite ||
        !worldBounds.width.isFinite ||
        !worldBounds.height.isFinite ||
        worldBounds.isEmpty) {
      throw ArgumentError.value(worldBounds, 'worldBounds');
    }
    if (!viewport.isFinite ||
        !viewport.width.isFinite ||
        !viewport.height.isFinite ||
        viewport.isEmpty) {
      throw ArgumentError.value(viewport, 'viewport');
    }

    final scaleX = viewport.width / worldBounds.width;
    final scaleY = viewport.height / worldBounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    return Rect.fromCenter(
      center: viewport.center,
      width: worldBounds.width * scale,
      height: worldBounds.height * scale,
    );
  }
}
