import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../di/profile_dependencies.dart';
import '../mappers/profile_response.dart';

class ProfileEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<Profile> getMyProfile(Session session, GetMyProfileRequest request) =>
      profileResponse(
        session,
        () => getMyProfileUseCase(session).execute(_userId(session)),
      );

  Future<Profile> updateNickname(
    Session session,
    UpdateNicknameRequest request,
  ) => profileResponse(
    session,
    () =>
        updateNicknameUseCase(session)
            .execute(_userId(session), request.nickname),
  );
}

UuidValue _userId(Session session) {
  final id = session.authenticated?.authUserId;
  if (id == null) throw StateError('認証済みのセッションが必要です');
  return id;
}
