import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../generated/endpoints.dart';
import '../../infrastructure/auth/database_signup_rate_limiter.dart';
import '../../infrastructure/config/anonymous_signup_settings.dart';
import '../endpoints/anonymous_idp_endpoint.dart';
import '../request/signup_client_address.dart';

/// 生成された引数なしendpointへ、起動時の設定を明示的に注入する。
class ConfiguredEndpoints(final AnonymousSignupSettings settings)
    extends Endpoints {
  @override
  void initializeEndpoints(Server server) {
    super.initializeEndpoints(server);
    final endpoint = connectors['anonymousIdp']?.endpoint;
    if (endpoint is! AnonymousIdpEndpoint) {
      throw StateError('匿名認証endpointが登録されていません');
    }
    settings.validate();
    final limiter = DatabaseRateLimiter(
      RateLimiterConfig(
        domain: 'anonymous',
        source: 'account_creation',
        maxAttempts: settings.limitPerHour,
        timeframe: const Duration(hours: 1),
      ),
    );
    endpoint.clientAddress = SignupClientAddress(cloudRun: settings.cloudRun);
    endpoint.createRateLimiter = (session) =>
        DatabaseSignupRateLimiter(session, limiter);
  }
}
