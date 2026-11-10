import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_scene/scene.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  PerspectiveProjection projection() =>
      PerspectiveProjection(fovRadiansY: vm.radians(60), near: 1, far: 8000);

  test('範囲内の垂直画角だけを投影へ反映し、nearとfarは維持する', () {
    final applied = projection();
    applyShotVerticalFov(applied, 47);
    expect(applied.fovRadiansY, vm.radians(47));
    expect(applied.near, 1);
    expect(applied.far, 8000);

    for (final degrees in <double?>[null, 0, 180, -10, 180.1]) {
      final unchanged = projection();
      applyShotVerticalFov(unchanged, degrees);
      expect(unchanged.fovRadiansY, vm.radians(60));
      expect(unchanged.far, 8000);
    }

    final lower = projection();
    applyShotVerticalFov(lower, 0.1);
    expect(lower.fovRadiansY, vm.radians(0.1));
    final upper = projection();
    applyShotVerticalFov(upper, 179.9);
    expect(upper.fovRadiansY, vm.radians(179.9));
  });
}
