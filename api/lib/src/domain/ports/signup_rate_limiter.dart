abstract interface class SignupRateLimiter() {
  Future<bool> tryAcquire(String clientKey);
}

class const SignupClientAddressUnavailable() implements Exception;
