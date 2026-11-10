import '../../domain/ports/start_rate_limiter.dart';

/// 単調に増える経過時間。壁時計（`DateTime.now`）は巻き戻ることがあるので使わない。
Duration Function() _monotonicClock() {
  final stopwatch = Stopwatch()..start();
  return () => stopwatch.elapsed;
}

/// アカウントごとの新規開始を、直近 [window] で [limit] 回までに制限する（メモリ上）。
///
/// 補助的な制限で、再起動で消えてよい。本番の API は 1 インスタンスで、要求を共通ゲート
/// で 1 件ずつ処理する。開発・テストでは要求が並行し得るが、Dart の 1 つの isolate の中で
/// 同期的に読み書きするので、記録が壊れることはない（上限をわずかに超えることはあり得る）。
class InMemoryStartRateLimiter({
  final int limit = 10,
  final Duration window = const Duration(minutes: 1),

  /// 単調に増える経過時間（テストで差し替える）。省略時は Stopwatch。
  Duration Function()? elapsed,
}) implements StartRateLimiter {
  final Duration Function() _elapsed = elapsed ?? _monotonicClock();

  /// アカウントごとの、記録した時点（古い順）。
  final Map<int, List<Duration>> _records = {};

  /// 最後に、使われていないアカウントの記録を捨てた時点。
  Duration _lastSweep = Duration.zero;

  @override
  int? retryAfter(int userProfileId) {
    final now = _elapsed();
    final records = _records[userProfileId];
    if (records == null) return null;
    _dropExpired(records, now);
    if (records.length < limit) return null;
    // 最も古い記録が窓から出るまで。切り上げて、少なくとも 1 秒を返す。
    final wait = records.first + window - now;
    final seconds = (wait.inMilliseconds / 1000).ceil();
    return seconds < 1 ? 1 : seconds;
  }

  @override
  void record(int userProfileId) {
    final now = _elapsed();
    _records.putIfAbsent(userProfileId, () => []).add(now);
    // 窓に 1 回だけ、使われていないアカウントの記録を捨てる（毎回の全件走査を避ける）。
    if (now - _lastSweep >= window) {
      _lastSweep = now;
      _records.removeWhere((_, records) {
        _dropExpired(records, now);
        return records.isEmpty;
      });
    }
  }

  void _dropExpired(List<Duration> records, Duration now) =>
      records.removeWhere((t) => now - t >= window);
}
