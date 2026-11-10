import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';

void main() {
  group('forwardVector / rightVector', () {
    test('yaw=0 で前進すると −Z（北）', () {
      final f = forwardVector(0);
      expect(f.x, closeTo(0, 1e-12));
      expect(f.z, closeTo(-1, 1e-12));
    });

    test('yaw=90 で前進すると ＋X（東）', () {
      final f = forwardVector(90);
      expect(f.x, closeTo(1, 1e-12));
      expect(f.z, closeTo(0, 1e-12));
    });

    test('yaw=180 で前進すると ＋Z（南）、yaw=270 で −X（西）', () {
      expect(forwardVector(180).z, closeTo(1, 1e-12));
      expect(forwardVector(270).x, closeTo(-1, 1e-12));
    });

    test('yaw=0 の右は ＋X、yaw=90 の右は ＋Z', () {
      final r0 = rightVector(0);
      expect(r0.x, closeTo(1, 1e-12));
      expect(r0.z, closeTo(0, 1e-12));
      final r90 = rightVector(90);
      expect(r90.x, closeTo(0, 1e-12));
      expect(r90.z, closeTo(1, 1e-12));
    });

    test('前進と右は直交する単位ベクトル', () {
      for (final yaw in [0.0, 33.0, 90.0, 217.5, 359.0]) {
        final f = forwardVector(yaw);
        final r = rightVector(yaw);
        expect(f.x * f.x + f.z * f.z, closeTo(1, 1e-12));
        expect(f.x * r.x + f.z * r.z, closeTo(0, 1e-12));
      }
    });
  });

  group('combineInput', () {
    double length(({double forward, double right}) v) =>
        math.sqrt(v.forward * v.forward + v.right * v.right);

    test('斜めの入力の長さは 1 以下に抑える', () {
      final v = combineInput(1, 1);
      expect(length(v), closeTo(1, 1e-12));
      expect(v.forward, closeTo(math.sqrt1_2, 1e-12));
      expect(v.right, closeTo(math.sqrt1_2, 1e-12));
    });

    test('長さ 1 以下の入力はそのまま', () {
      expect(combineInput(1, 0), (forward: 1.0, right: 0.0));
      expect(combineInput(0.3, -0.4), (forward: 0.3, right: -0.4));
      expect(combineInput(0, 0), (forward: 0.0, right: 0.0));
    });

    test('大きな入力も長さ 1 に収まり、向きは変わらない', () {
      final v = combineInput(-3, 4);
      expect(length(v), closeTo(1, 1e-12));
      expect(v.forward, closeTo(-0.6, 1e-12));
      expect(v.right, closeTo(0.8, 1e-12));
    });
  });
}
