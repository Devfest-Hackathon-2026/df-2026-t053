import 'package:serverpod/serverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';

import '../../domain/ports/signup_rate_limiter.dart';
import '../request/signup_client_address.dart';

/// 匿名ログイン。client は `client.anonymousIdp` から呼ぶ。
class AnonymousIdpEndpoint() extends AnonymousIdpBaseEndpoint {
  // endpoint生成後、ConfiguredEndpointsが明示的に注入する。
  // 素のEndpointsを使う生成withServerpodテストツールからのloginは非対応。
  // この経路の検証にはConfiguredEndpointsを組み立てるHTTP統合テストを使う。
  late final SignupRateLimiter Function(Session) createRateLimiter;
  late final SignupClientAddress clientAddress;

  @override
  Future<AuthSuccess> login(Session session, {String? token}) async {
    try {
      final request = session.request;
      final key = clientAddress.key(
        peerAddress: request?.connectionInfo.remote.address.toString(),
        forwardedFor: request?.headers['x-forwarded-for'] ?? const [],
      );
      if (!await createRateLimiter(session).tryAcquire(key)) {
        throw AnonymousAccountBlockedException(reason: .tooManyAttempts);
      }
    } on SignupClientAddressUnavailable {
      session.log('匿名作成の接続元IPを確認できません', level: .error);
      throw ApiException(
        code: .unavailable,
        reason: ApiErrorReasons.temporarilyUnavailable,
        message: '接続元を確認できないため匿名アカウントを作成できません',
      );
    }
    return super.login(session, token: token);
  }
}
