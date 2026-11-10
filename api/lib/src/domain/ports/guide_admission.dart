import 'package:uuid/uuid_value.dart';

abstract interface class GuideAdmission() {
  /// 受理時に回数を消費する。失敗・取消でも返却しない。
  GuideLease acquire(UuidValue userId);
}

abstract interface class GuideLease() {
  void release();
}

class const GuideRateLimitedException(final int retryAfterSeconds)
    implements Exception;
