import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// 更新トークンのローテーションとプロフィール復旧を同じtransactionに収める。
/// 復旧失敗でトークンだけ進み、利用者が認証を失うことを防ぐ。
class ProfileRepairingJwt({
  required final Jwt delegate,
  required final Future<void> Function(Session, UuidValue, Transaction)
  ensureProfile,
}) extends Jwt {
  this : super(config: delegate.config, authUsers: delegate.authUsers);

  @override
  Future<AuthSuccess> refreshAccessToken(
    Session session, {
    required String refreshToken,
    Transaction? transaction,
  }) async {
    // このendpoint用adapterがcommitまで所有する。失効のrollbackを防ぐため、
    // 外部transactionはdelegateを呼ぶ前に拒否する。
    if (transaction != null) {
      throw ArgumentError('ProfileRepairingJwtは外部transactionを受け付けません');
    }
    Future<Object> refresh(Transaction tx) async {
      final AuthSuccess success;
      try {
        success = await delegate.refreshAccessToken(
          session,
          refreshToken: refreshToken,
          transaction: tx,
        );
      } on RefreshTokenExpiredException catch (error, stack) {
        // 期限切れ・不正なsecretによる失効は、認証モジュールと同じくcommitする。
        return _RevokedToken(error, stack);
      } on RefreshTokenInvalidSecretException catch (error, stack) {
        return _RevokedToken(error, stack);
      }
      await ensureProfile(session, success.authUserId, tx);
      return success;
    }

    final result = await session.db.transaction(refresh);
    if (result case _RevokedToken(:final error, :final stack)) {
      Error.throwWithStackTrace(error, stack);
    }
    if (result is AuthSuccess) return result;
    throw StateError('認証更新の結果が不正です');
  }
}

class const _RevokedToken(final Object error, final StackTrace stack);
