import 'dart:math' as math;

import 'package:photohunt_shared/photohunt_shared.dart';

/// 仕様の共通リトライ。自動再試行は unavailable（MAINTENANCE と
/// SCHEMA_TOO_NEW を除く）だけ、初回に加えて最大3回、待機1秒・2秒・4秒に
/// 小さい乱数を加える。呼び出し側が破棄されたら再試行を止める。
Future<T> retryOnUnavailable<T>(
  Future<T> Function() action, {
  required bool Function() shouldContinue,
}) async {
  const delays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];
  final random = math.Random();
  var failures = 0;
  while (true) {
    try {
      return await action();
    } on ApiException catch (error) {
      final retryable =
          error.code == .unavailable &&
          error.reason != 'MAINTENANCE' &&
          error.reason != 'SCHEMA_TOO_NEW';
      if (!retryable || failures >= delays.length || !shouldContinue()) {
        rethrow;
      }
      await Future<void>.delayed(
        delays[failures] + Duration(milliseconds: random.nextInt(250)),
      );
      failures++;
      if (!shouldContinue()) {
        rethrow;
      }
    }
  }
}
