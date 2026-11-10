import 'package:uuid/uuid_value.dart';

import '../models/models.dart';

abstract interface class PlaySessionRepository() {
  Future<PlaySession?> findById(UuidValue id);

  /// 同じ本人・同じ requestId の開始済みプレイ。再送の判定に使う。
  Future<PlaySession?> findByRequestId(int userProfileId, UuidValue requestId);

  /// `(user_profile_id, request_id)` が重複したら `DuplicateEntityException`。
  Future<PlaySession> insert(PlaySession session);
}
