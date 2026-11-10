import 'package:photohunt_server/src/application/dto/play_result.dart';
import 'package:photohunt_server/src/domain/models/models.dart' as domain;
import 'package:photohunt_server/src/presentation/mappers/play_session_response.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

final _t0 = DateTime.utc(2026, 11, 9, 12);

final _session = domain.PlaySession(
  id: const Uuid().v7obj(),
  requestId: const Uuid().v4obj(),
  revisionId: 10,
  mode: PlayMode.near,
  spawnPointId: 4,
  userProfileId: 1,
  startedAt: _t0,
  expiresAt: _t0.add(const Duration(hours: 2)),
);

const _spawn = domain.SpawnPoint(
  id: 4,
  modeConfigId: 1,
  x: 10,
  y: 0,
  z: -15,
  yawDeg: 200,
  sortOrder: 0,
  label: null,
);

void main() {
  test('未撮影は active で、shot・reveal・myRankingEntry がすべて null', () {
    final dto = playSessionResponse(
      PlayResult.active(session: _session, spawn: _spawn),
    );
    expect(dto.state, PlaySessionState.active);
    expect(dto.spawn.positionX, 10);
    expect(dto.spawn.positionZ, -15);
    expect(dto.spawn.yawDegrees, 200);
    expect(dto.expireTime.difference(dto.createTime), const Duration(hours: 2));
    expect(dto.shot, isNull);
    expect(dto.reveal, isNull);
    expect(dto.myRankingEntry, isNull);
  });

  test('撮影済みは completed で、撮影・正解（版の画角）・撮影時の順位を返す', () {
    final shot = domain.Shot(
      id: 7,
      requestId: const Uuid().v4obj(),
      playSessionId: _session.id,
      x: 1,
      y: 1.6,
      z: 2,
      yawDeg: 3,
      pitchDeg: 4,
      fovDeg: 50,
      distanceM: 0.5,
      yawDiffDeg: 1,
      pitchDiffDeg: 2,
      score: 900,
      rankAtSubmission: 3,
      bestScoreAtSubmission: 950,
      nicknameAtSubmission: '撮影時の名前',
      bestAchieveTimeAtSubmission: _t0,
      createdAt: _t0,
    );
    final dto = playSessionResponse(
      PlayResult.completed(
        session: _session,
        spawn: _spawn,
        shot: shot,
        reveal: const PlayReveal(
          goal: domain.GoalPose(x: 0, y: 1.6, z: -45, yawDeg: 0, pitchDeg: 8),
          story: 'story',
          highlight: 'highlight',
          verticalFovDeg: 48,
        ),
      ),
    );
    expect(dto.state, PlaySessionState.completed);
    expect(dto.shot!.id, 7);
    expect(dto.shot!.camera.verticalFovDegrees, 50);
    expect(dto.reveal!.goalCamera.positionZ, -45);
    expect(dto.reveal!.goalCamera.verticalFovDegrees, 48);
    expect(dto.reveal!.story, 'story');
    expect(dto.myRankingEntry!.rank, 3);
    expect(dto.myRankingEntry!.nickname, '撮影時の名前');
    expect(dto.myRankingEntry!.score, 950);
    expect(dto.myRankingEntry!.mine, isTrue);
  });
}
