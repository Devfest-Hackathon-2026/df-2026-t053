import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/auth_account_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../dto/profile_result.dart';

/// テストが [GetMyProfile.execute] を差し替える。本番は null。
Future<ProfileResult> Function(UuidValue authUserId)?
getMyProfileExecuteForTest;

class GetMyProfile(
  final UserProfileRepository profiles,
  final AuthAccountRepository accounts,
) {
  Future<ProfileResult> execute(UuidValue authUserId) async {
    final replacement = getMyProfileExecuteForTest;
    if (replacement != null) return replacement(authUserId);
    final profile = await profiles.findByAuthUserId(authUserId);
    if (profile == null) throw const ProfileMissingException();
    return ProfileResult(
      nickname: profile.nickname,
      anonymous: await accounts.isAnonymous(authUserId),
    );
  }
}
