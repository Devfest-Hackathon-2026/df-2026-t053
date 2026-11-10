import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';

UserProfile userProfileFromRow(UserProfileRow row) => UserProfile(
  id: row.id!,
  authUserId: row.authUserId,
  nickname: row.nickname,
  createdAt: row.createdAt.toUtc(),
);

UserProfileRow userProfileToRow(UserProfile profile) => UserProfileRow(
  id: profile.id,
  authUserId: profile.authUserId,
  nickname: profile.nickname,
  createdAt: profile.createdAt.toUtc(),
);
