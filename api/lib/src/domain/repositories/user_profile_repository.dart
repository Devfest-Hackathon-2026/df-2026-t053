import 'package:uuid/uuid_value.dart';

import '../models/models.dart';

abstract interface class UserProfileRepository() {
  Future<UserProfile?> findByAuthUserId(UuidValue authUserId);

  /// 保存して、id 付きのプロフィールを返す。
  /// auth_user_id が重複したら `ProfileAlreadyExistsException`。
  Future<UserProfile> insert(UserProfile profile);

  /// ニックネームを更新して返す。プロフィールがなければ null。
  Future<UserProfile?> updateNickname(int id, String nickname);
}
