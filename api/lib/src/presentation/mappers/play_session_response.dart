// サーバー内部のドメインモデルと同名の公開 DTO があるので、ドメインには接頭辞を付ける。
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../application/dto/play_result.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/models.dart' as domain;

/// ユースケースの結果を公開 DTO の [PlaySession] にする。
///
/// 未撮影（active）は shot・reveal・myRankingEntry をすべて null にする。撮影済み
/// （completed）は 3 つとも返す。#29（撮影・採点）が、同じ組み立てで撮影直後の応答も作る。
/// 正解・解説はユースケースが読んで [PlayResult.reveal] に入れる（この層は版を読まない）。
PlaySession playSessionResponse(PlayResult result) {
  final session = result.session;
  final spawn = result.spawn;
  final shot = result.shot;
  final reveal = result.reveal;
  return PlaySession(
    id: session.id,
    revisionId: session.revisionId,
    mode: session.mode,
    spawnPointId: session.spawnPointId,
    spawn: Spawn(
      positionX: spawn.x,
      positionY: spawn.y,
      positionZ: spawn.z,
      yawDegrees: spawn.yawDeg,
    ),
    state: result.completed ? .completed : .active,
    createTime: session.startedAt,
    expireTime: session.expiresAt,
    shot: shot == null ? null : _shot(shot),
    reveal: reveal == null ? null : _reveal(reveal),
    myRankingEntry: shot == null ? null : _ranking(shot),
  );
}

CameraPose _camera(
  double x,
  double y,
  double z,
  double yaw,
  double pitch,
  double fov,
) => CameraPose(
  positionX: x,
  positionY: y,
  positionZ: z,
  yawDegrees: yaw,
  pitchDegrees: pitch,
  verticalFovDegrees: fov,
);

Shot _shot(domain.Shot shot) => Shot(
  id:
      shot.id ??
      (throw const CorruptedDataException(
        entity: 'shot',
        field: 'id',
        message: '保存されていない撮影結果',
      )),
  camera: _camera(
    shot.x,
    shot.y,
    shot.z,
    shot.yawDeg,
    shot.pitchDeg,
    shot.fovDeg,
  ),
  score: shot.score,
  distanceMeters: shot.distanceM,
  yawDiffDegrees: shot.yawDiffDeg,
  pitchDiffDegrees: shot.pitchDiffDeg,
  createTime: shot.createdAt,
);

Reveal _reveal(PlayReveal reveal) => Reveal(
  goalCamera: _camera(
    reveal.goal.x,
    reveal.goal.y,
    reveal.goal.z,
    reveal.goal.yawDeg,
    reveal.goal.pitchDeg,
    reveal.verticalFovDeg,
  ),
  story: reveal.story,
  highlight: reveal.highlight,
);

/// 撮影時に保存した値（最新の順位は ranking で取得する）。
RankingEntry _ranking(domain.Shot shot) => RankingEntry(
  rank: shot.rankAtSubmission,
  nickname: shot.nicknameAtSubmission,
  score: shot.bestScoreAtSubmission,
  achieveTime: shot.bestAchieveTimeAtSubmission,
  mine: true,
);

/// 撮影直後と再送は getPlaySession と同じ保存済みスナップショットを返す。
SubmitShotResponse submitShotResponse(PlayResult result) {
  final shot = result.shot;
  final reveal = result.reveal;
  if (shot == null || reveal == null) {
    throw StateError('撮影が完了していません');
  }
  return SubmitShotResponse(
    shot: _shot(shot),
    reveal: _reveal(reveal),
    myRankingEntry: _ranking(shot),
  );
}
