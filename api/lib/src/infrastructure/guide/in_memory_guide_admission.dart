import 'package:uuid/uuid_value.dart';

import '../../domain/ports/guide_admission.dart';

/// アプリケーションのWAV保持を2要求に制限する（上限合計20 MiB）。
/// HTTPのJSON/base64とServerpodの送信バッファはこの制限の対象外。
/// WAVは10 MiB以下、chunkは同じbufferのviewを使う。
class InMemoryGuideAdmission({DateTime Function()? now})
    implements GuideAdmission {
  final DateTime Function() _now = now ?? DateTime.now;
  final _users = <UuidValue, _Usage>{};
  int _active = 0;

  @override
  GuideLease acquire(UuidValue userId) {
    final now = _now().toUtc();
    final day = DateTime.utc(now.year, now.month, now.day);
    _users.removeWhere((_, value) => value.day != day);
    final usage = _users[userId];
    if (usage != null) {
      if (usage.count >= 30) {
        throw GuideRateLimitedException(
          day.add(const Duration(days: 1)).difference(now).inSeconds + 1,
        );
      }
      final remaining =
          const Duration(seconds: 10) - now.difference(usage.last);
      if (remaining > Duration.zero) {
        throw GuideRateLimitedException(
          (remaining.inMilliseconds / 1000).ceil(),
        );
      }
    }
    if (_active >= 2) throw const GuideRateLimitedException(1);
    _users[userId] = _Usage(day, now, (usage?.count ?? 0) + 1);
    _active++;
    return _Lease(() => _active--);
  }
}

class const _Usage(final DateTime day, final DateTime last, final int count);

class _Lease(final void Function() _release) implements GuideLease {
  bool _released = false;
  @override
  void release() {
    if (_released) return;
    _released = true;
    _release();
  }
}
