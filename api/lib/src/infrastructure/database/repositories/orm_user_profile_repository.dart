import 'package:serverpod/serverpod.dart';

import '../../../domain/exceptions.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/user_profile_mapper.dart';
import '../unique_violation.dart';

class OrmUserProfileRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements UserProfileRepository {
  @override
  Future<UserProfile?> findByAuthUserId(UuidValue authUserId) async {
    final row = await UserProfileRow.db.findFirstRow(
      _session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: _transaction,
    );
    return row == null ? null : userProfileFromRow(row);
  }

  @override
  Future<UserProfile> insert(UserProfile profile) async {
    try {
      return await translateUniqueViolation(() async {
        final row = await UserProfileRow.db.insertRow(
          _session,
          userProfileToRow(profile),
          transaction: _transaction,
        );
        return userProfileFromRow(row);
      });
    } on DuplicateEntityException catch (error) {
      if (error.entity == 'user_profile' &&
          error.constraint == 'user_profile_auth_user_uk') {
        throw const ProfileAlreadyExistsException();
      }
      rethrow;
    }
  }

  @override
  Future<UserProfile?> updateNickname(int id, String nickname) async {
    final rows = await UserProfileRow.db.updateWhere(
      _session,
      columnValues: (t) => [t.nickname(nickname)],
      where: (t) => t.id.equals(id),
      transaction: _transaction,
    );
    return rows.isEmpty ? null : userProfileFromRow(rows.single);
  }
}
