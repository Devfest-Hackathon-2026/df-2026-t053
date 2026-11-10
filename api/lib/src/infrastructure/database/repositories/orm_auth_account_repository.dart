import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AnonymousAccount;

import '../../../domain/repositories/auth_account_repository.dart';

class OrmAuthAccountRepository(final DatabaseSession session)
    implements AuthAccountRepository {
  @override
  Future<bool> isAnonymous(UuidValue authUserId) async =>
      await AnonymousAccount.db.count(
        session,
        where: (t) => t.authUserId.equals(authUserId),
      ) >
      0;
}
