import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../domain/ports/signup_rate_limiter.dart';

class DatabaseSignupRateLimiter(
  final Session session,
  final DatabaseRateLimiter limiter,
) implements SignupRateLimiter {
  @override
  Future<bool> tryAcquire(String clientKey) =>
      limiter.tryRecordAttempt(session, key: clientKey);
}
