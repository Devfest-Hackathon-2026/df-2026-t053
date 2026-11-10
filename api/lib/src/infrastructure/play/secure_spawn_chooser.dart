import 'dart:math';

import '../../domain/ports/spawn_chooser.dart';

/// 暗号論的乱数で開始点を一様に選ぶ。再送や素材の再試行で引き直さないのは、
/// 保存済みのセッションを返す側（StartPlay）の責務。
class SecureSpawnChooser() implements SpawnChooser {
  final Random _random = Random.secure();

  @override
  int choose(int count) {
    if (count <= 0) throw ArgumentError.value(count, 'count', '1 以上にする');
    return _random.nextInt(count);
  }
}
