import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// 匿名作成と認証更新のフローだけが使う。
class EnsureUserProfile(
  final UserProfileRepository repository, {
  required final String Function() createNickname,
  required final DateTime Function() now,
}) {
  Future<UserProfile> execute(UuidValue authUserId) async {
    final existing = await repository.findByAuthUserId(authUserId);
    if (existing != null) return existing;
    try {
      return await repository.insert(
        UserProfile(
          id: null,
          authUserId: authUserId,
          nickname: createNickname(),
          createdAt: now().toUtc(),
        ),
      );
    } on ProfileAlreadyExistsException {
      final winner = await repository.findByAuthUserId(authUserId);
      if (winner == null) rethrow;
      return winner;
    }
  }
}
