// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;

import 'spawn_point.dart';

/// 版ごとのモード設定。[spawnPoints] は sortOrder の昇順。
/// [spawnPoints] は変更できないコピーで持つ（渡した元のリストを変えても影響しない）。
class ModeConfig({
  required final int id,
  required final int revisionId,
  required final PlayMode mode,
  required final WalkableArea walkable,
  required List<SpawnPoint> spawnPoints,
}) {
  final List<SpawnPoint> spawnPoints = List.unmodifiable(spawnPoints);
}
