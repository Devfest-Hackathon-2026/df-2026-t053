import 'package:uuid/uuid_value.dart';

import '../models/models.dart';

abstract interface class ShotRepository() {
  Future<Shot?> findByPlaySessionId(UuidValue playSessionId);

  /// 保存して、id 付きの撮影結果を返す。同じプレイへの 2 行目は
  /// `DuplicateEntityException`。撮影結果は更新しない。
  Future<Shot> insert(Shot shot);
}
