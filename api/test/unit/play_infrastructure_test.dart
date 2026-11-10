import 'package:photohunt_server/src/infrastructure/play/in_memory_start_rate_limiter.dart';
import 'package:photohunt_server/src/infrastructure/play/secure_spawn_chooser.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryStartRateLimiter', () {
    late Duration now;
    late InMemoryStartRateLimiter limiter;
    setUp(() {
      now = const Duration(hours: 1);
      limiter = InMemoryStartRateLimiter(elapsed: () => now);
    });

    /// 開始を 1 回試す。通れば記録して null、制限中なら retryAfter を返す。
    int? start(int profile) {
      final wait = limiter.retryAfter(profile);
      if (wait == null) limiter.record(profile);
      return wait;
    }

    test('1 分に 10 回までは通り、11 回目は retryAfterSeconds を返して記録しない', () {
      for (var i = 0; i < 10; i++) {
        expect(start(1), isNull, reason: '${i + 1} 回目');
        now += const Duration(seconds: 1);
      }
      // 最初の記録は 10 秒前。窓（60 秒）から出るまで 50 秒。
      expect(start(1), 50);
      // 拒否は記録しない。待てば通る。
      now += const Duration(seconds: 50);
      expect(start(1), isNull);
    });

    test('確認だけでは回数を使わない', () {
      for (var i = 0; i < 100; i++) {
        expect(limiter.retryAfter(1), isNull);
      }
    });

    test('アカウントごとに数える', () {
      for (var i = 0; i < 10; i++) {
        expect(start(1), isNull);
      }
      expect(start(1), isNotNull);
      expect(start(2), isNull);
    });

    test('窓を過ぎれば古い記録は数えない', () {
      for (var i = 0; i < 10; i++) {
        start(1);
      }
      now += const Duration(seconds: 60);
      expect(start(1), isNull);
    });

    test('使われていないアカウントの記録は、窓に 1 回の掃除で捨てる', () {
      for (var profile = 0; profile < 1000; profile++) {
        start(profile);
      }
      now += const Duration(minutes: 2);
      start(5000); // 掃除が走る
      // 掃除の後も、制限は正しく働く（古い記録は数えない）。
      for (var i = 0; i < 10; i++) {
        expect(start(1), isNull);
      }
      expect(start(1), isNotNull);
    });

    test('既定の時計は単調に増える（壁時計の巻き戻りの影響を受けない）', () {
      final real = InMemoryStartRateLimiter();
      for (var i = 0; i < 10; i++) {
        expect(real.retryAfter(1), isNull);
        real.record(1);
      }
      final wait = real.retryAfter(1);
      expect(wait, isNotNull);
      expect(wait, inInclusiveRange(1, 60));
    });

    test('retryAfterSeconds は 1 秒以上', () {
      for (var i = 0; i < 10; i++) {
        start(1);
      }
      now += const Duration(milliseconds: 59990);
      expect(start(1), 1);
    });
  });

  group('SecureSpawnChooser', () {
    test('範囲内で、すべての添字が選ばれ得る', () {
      final chooser = SecureSpawnChooser();
      final seen = <int>{};
      for (var i = 0; i < 500; i++) {
        final index = chooser.choose(4);
        expect(index, inInclusiveRange(0, 3));
        seen.add(index);
      }
      expect(seen, {0, 1, 2, 3});
    });

    test('候補が 1 件なら常に 0、0 件は拒否', () {
      final chooser = SecureSpawnChooser();
      expect(chooser.choose(1), 0);
      expect(() => chooser.choose(0), throwsArgumentError);
    });
  });
}
