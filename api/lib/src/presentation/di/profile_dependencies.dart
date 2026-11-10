import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../application/usecase/ensure_user_profile.dart';
import '../../application/usecase/get_my_profile.dart';
import '../../application/usecase/update_nickname.dart';
import '../../domain/services/nickname.dart';
import '../../infrastructure/auth/profile_repairing_jwt.dart';
import '../../infrastructure/database/repositories/orm_auth_account_repository.dart';
import '../../infrastructure/database/repositories/orm_user_profile_repository.dart';

EnsureUserProfile ensureUserProfileUseCase(
  Session session, {
  Transaction? transaction,
}) => EnsureUserProfile(
  OrmUserProfileRepository(session, transaction: transaction),
  createNickname: () => generateInitialNickname(Random.secure()),
  now: DateTime.now,
);

GetMyProfile getMyProfileUseCase(Session session) => GetMyProfile(
  OrmUserProfileRepository(session),
  OrmAuthAccountRepository(session),
);

UpdateNickname updateNicknameUseCase(Session session) => UpdateNickname(
  OrmUserProfileRepository(session),
  OrmAuthAccountRepository(session),
);

Jwt profileRepairingJwt(Jwt delegate) => ProfileRepairingJwt(
  delegate: delegate,
  ensureProfile: (session, id, tx) async {
    await ensureUserProfileUseCase(session, transaction: tx).execute(id);
  },
);
