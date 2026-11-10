import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/auth_account_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/services/nickname.dart';
import '../dto/profile_result.dart';

class UpdateNickname(
  final UserProfileRepository profiles,
  final AuthAccountRepository accounts,
) {
  Future<ProfileResult> execute(UuidValue authUserId, String input) async {
    final nickname = normalizeNickname(input);
    final current = await profiles.findByAuthUserId(authUserId);
    if (current == null) throw const ProfileMissingException();
    final id = current.id;
    if (id == null) throw const ProfileMissingException();
    if (current.nickname != nickname) {
      final updated = await profiles.updateNickname(id, nickname);
      if (updated == null) throw const ProfileMissingException();
    }
    return ProfileResult(
      nickname: nickname,
      anonymous: await accounts.isAnonymous(authUserId),
    );
  }
}
