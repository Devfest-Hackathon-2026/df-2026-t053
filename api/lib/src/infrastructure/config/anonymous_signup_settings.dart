import 'runtime_environment.dart';

/// 匿名作成は通常100件/時。ローカルemulator環境だけ上限を緩められる。
class const AnonymousSignupSettings({
  final int limitPerHour = 100,
  final bool cloudRun = false,
}) {
  void validate() {
    if (limitPerHour <= 0) {
      throw const FormatException('匿名作成の上限は正の整数です');
    }
  }

  factory fromEnvironment(Map<String, String> env) {
    final raw = env['ANON_SIGNUP_LIMIT_PER_HOUR'];
    final limit = raw == null ? 100 : int.tryParse(raw);
    if (limit == null) {
      throw const FormatException('ANON_SIGNUP_LIMIT_PER_HOUR は正の整数です');
    }
    final local = isLocalEmulator(env);
    if (limit > 100 && !local) {
      throw const FormatException('匿名作成制限を緩められるのはローカル環境だけです');
    }
    return AnonymousSignupSettings(
      limitPerHour: limit,
      cloudRun: isCloudRun(env),
    )..validate();
  }
}
