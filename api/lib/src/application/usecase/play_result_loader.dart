import '../../domain/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/shot_repository.dart';
import '../dto/play_result.dart';

/// 保存済みのプレイから結果を組み立てる。開始の再送・取得・撮影（#29）で共通に使う。
///
/// 撮影済みなら、正解・解説を含む版を読んで [PlayReveal] を入れる。版や秘密が欠けて
/// いれば [CorruptedDataException]（壊れたデータを素通しで応答にしない）。
Future<PlayResult> loadPlayResult(
  PlaySession session, {
  required ChallengeRepository challenges,
  required ShotRepository shots,
}) async {
  final spawn = await challenges.findSpawnPoint(session.spawnPointId);
  if (spawn == null) {
    throw const CorruptedDataException(
      entity: 'play_session',
      field: 'spawn_point_id',
      message: '保存した開始点がない',
    );
  }
  final shot = await shots.findByPlaySessionId(session.id);
  if (shot == null) return PlayResult.active(session: session, spawn: spawn);

  final revision = await challenges.findRevisionWithSecrets(session.revisionId);
  final secrets = revision?.secrets;
  if (revision == null || secrets == null) {
    throw const CorruptedDataException(
      entity: 'play_session',
      field: 'revision_id',
      message: '撮影済みのプレイの版、または正解・解説がない',
    );
  }
  return PlayResult.completed(
    session: session,
    spawn: spawn,
    shot: shot,
    reveal: PlayReveal(
      goal: secrets.goal,
      story: secrets.story,
      highlight: secrets.highlight,
      verticalFovDeg: revision.shotFovDeg,
    ),
  );
}
