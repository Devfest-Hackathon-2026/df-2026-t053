import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

void main() {
  final bounds = MapBounds(minX: -20, minZ: 10, maxX: 60, maxZ: 50);

  test('bounds の四隅が (0,0)/(1,0)/(0,1)/(1,1) になる', () {
    expect(toMapUv(bounds, -20, 10), (u: 0.0, v: 0.0));
    expect(toMapUv(bounds, 60, 10), (u: 1.0, v: 0.0));
    expect(toMapUv(bounds, -20, 50), (u: 0.0, v: 1.0));
    expect(toMapUv(bounds, 60, 50), (u: 1.0, v: 1.0));
  });

  test('中央が (0.5, 0.5)', () {
    expect(toMapUv(bounds, 20, 30), (u: 0.5, v: 0.5));
  });

  test('X は右、Z は下に増える', () {
    expect(toMapUv(bounds, 0, 10).u, 0.25);
    expect(toMapUv(bounds, -20, 20).v, 0.25);
  });

  test('範囲外の値を端へ吸着させない', () {
    final uv = toMapUv(bounds, 100, 0);
    expect(uv.u, 1.5);
    expect(uv.v, -0.25);
  });

  group('latLonToMapUv', () {
    test('夢洲北西端付近で (u, v) が概ね (0, 0) 近傍になる', () {
      final uv = latLonToMapUv(kYumeshimaNwLat, kYumeshimaNwLon);
      expect(uv.u, closeTo(-0.023, 0.01));
      expect(uv.v, closeTo(-0.003, 0.01));
    });

    test('日本館の緯度経度がクロップ補正込みで会場東側に正しく投影される', () {
      // 日本館: lat 34.648305, lon 135.387793 -> px 約 2725.9, py 約 1877.3
      final uv = latLonToMapUv(34.648305, 135.387793);
      expect(uv.u, closeTo(0.868, 0.005));
      expect(uv.v, closeTo(0.759, 0.005));
    });
  });

  group('worldXzToMapUv', () {
    test('大屋根リング中心 (-4.2, 0.2) が画像上のリング中心 (1928, 1716) に投影される', () {
      final uv = worldXzToMapUv(-4.2, 0.2);
      expect(uv.u, closeTo(1928.0 / 3139.0, 0.001));
      expect(uv.v, closeTo(1716.0 / 2472.0, 0.001));
    });
  });
}
