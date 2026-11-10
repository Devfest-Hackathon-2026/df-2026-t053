import 'package:uuid/uuid_value.dart';

/// 認証ユーザーに 1 対 1 のプロフィール。[id] は保存前だけ null。
class const UserProfile({
  required final int? id,
  required final UuidValue authUserId,
  required final String nickname,
  required final DateTime createdAt,
});
