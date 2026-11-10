import 'dart:ui';

import 'package:app/model/position.dart';
import 'package:app/usecase/map/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = Rect.fromLTRB(-100, -50, 100, 50);
  final projection = MapProjectionUseCase();

  test('fits a north-up map in a tall viewport with an offset', () {
    const viewport = Rect.fromLTWH(10, 20, 200, 300);
    expect(
      projection.fittedMapRect(bounds, viewport),
      const Rect.fromLTWH(10, 120, 200, 100),
    );
    expect(
      projection.worldToMap(
        const Position(x: -100, y: -50),
        worldBounds: bounds,
        viewport: viewport,
      ),
      const Offset(10, 120),
    );
    expect(
      projection.worldToMap(
        const Position(x: 100, y: 50),
        worldBounds: bounds,
        viewport: viewport,
      ),
      const Offset(210, 220),
    );
  });

  test('keeps out-of-bounds positions outside the fitted map', () {
    expect(
      projection.worldToMap(
        const Position(x: 110, y: 0),
        worldBounds: bounds,
        viewport: const Rect.fromLTWH(0, 0, 400, 100),
      ),
      const Offset(310, 50),
    );
  });
}
