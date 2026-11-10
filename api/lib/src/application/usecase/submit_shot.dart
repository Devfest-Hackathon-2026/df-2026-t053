import 'package:photohunt_shared/photohunt_shared.dart'
    show PointXZ, isInsideWalkable;
import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/ports/shot_transaction.dart';
import '../../domain/services/shot_scorer.dart';
import '../dto/play_result.dart';
import 'play_result_loader.dart';
import 'start_play.dart';

class SubmitShot(
  final ShotTransaction _transaction,
  final DateTime Function() _now,
) {
  Future<PlayResult> execute(
    UuidValue authUserId, {
    required UuidValue playSessionId,
    required UuidValue requestId,
    required ScoringPose camera,
  }) => _transaction.run((r) async {
    final session = await r.sessions.findById(playSessionId);
    if (session == null) throw const PlayException(.sessionNotFound);
    final profile = await r.profiles.findByAuthUserId(authUserId);
    final profileId = profile?.id;
    if (profile == null || profileId == null) {
      throw const PlayException(.profileNotInitialized);
    }
    if (session.userProfileId != profileId) {
      throw const PlayException(.notSessionOwner);
    }
    final pose = validateShotCamera(camera);
    if (!isUuidV4(requestId)) throw const PlayException(.invalidRequest);
    final existing = await r.shots.findByPlaySessionId(session.id);
    if (existing != null) {
      if (existing.requestId != requestId) {
        throw const ShotException(.alreadySubmitted);
      }
      if (existing.x != pose.positionX ||
          existing.z != pose.positionZ ||
          existing.yawDeg != pose.yawDegrees ||
          existing.pitchDeg != pose.pitchDegrees) {
        throw const PlayException(.requestIdReused);
      }
      return loadPlayResult(session, challenges: r.challenges, shots: r.shots);
    }
    // SQLite と同じミリ秒精度で順位を計算し、保存後と同じ時刻を返す。
    final now = DateTime.fromMillisecondsSinceEpoch(
      _now().millisecondsSinceEpoch,
      isUtc: true,
    );
    if (!now.isBefore(session.expiresAt)) {
      throw const ShotException(.sessionExpired);
    }
    final revision = await r.challenges.findRevisionWithSecrets(
      session.revisionId,
    );
    final secrets = revision?.secrets;
    final spawn = await r.challenges.findSpawnPoint(session.spawnPointId);
    if (revision == null || secrets == null || spawn == null) {
      throw const CorruptedDataException(
        entity: 'play_session',
        field: 'revision_id',
        message: '版・正解・開始点がありません',
      );
    }
    final modes = revision.modes.where((m) => m.mode == session.mode);
    if (modes.length != 1 || modes.single.id != spawn.modeConfigId) {
      throw const CorruptedDataException(
        entity: 'play_session',
        field: 'spawn_point_id',
        message: '開始点と版・モードが一致しません',
      );
    }
    if (!isInsideWalkable(
      modes.single.walkable,
      PointXZ(x: pose.positionX, z: pose.positionZ),
    )) {
      throw const ShotException(
        .invalidCamera,
        fields: ['camera.positionX', 'camera.positionZ'],
      );
    }
    final goal = secrets.goal;
    final score = const ShotScorer().score(
      scoringVersion: revision.scoringVersion,
      camera: pose,
      goal: ScoringPose(
        positionX: goal.x,
        positionZ: goal.z,
        yawDegrees: goal.yawDeg,
        pitchDegrees: goal.pitchDeg,
      ),
    );
    final oldBest = await r.bestScores.find(
      profileId,
      revision.id,
      session.mode,
    );
    final improved = oldBest == null || score.score > oldBest.score;
    final bestScore = improved ? score.score : oldBest.score;
    final achievedAt = improved ? now : oldBest.achievedAt;
    // 改善前の本人行は新しい点数より低いので上位件数に入らない。
    // 同点・悪化なら保存済み自己ベストの順位をそのまま計算できる。
    final rank = await r.bestScores.rankOf(
      revisionId: revision.id,
      mode: session.mode,
      score: bestScore,
      achievedAt: achievedAt,
      userProfileId: profileId,
    );
    final shot = await r.shots.insert(
      Shot(
        id: null,
        requestId: requestId,
        playSessionId: session.id,
        x: pose.positionX,
        y: spawn.y + revision.eyeHeightM,
        z: pose.positionZ,
        yawDeg: pose.yawDegrees,
        pitchDeg: pose.pitchDegrees,
        fovDeg: revision.shotFovDeg,
        distanceM: score.distanceMeters,
        yawDiffDeg: score.yawDiffDegrees,
        pitchDiffDeg: score.pitchDiffDegrees,
        score: score.score,
        rankAtSubmission: rank,
        bestScoreAtSubmission: bestScore,
        nicknameAtSubmission: profile.nickname,
        bestAchieveTimeAtSubmission: achievedAt,
        createdAt: now,
      ),
    );
    if (improved) {
      final shotId = shot.id;
      if (shotId == null) throw StateError('保存済みの撮影 ID がありません');
      await r.bestScores.upsert(
        BestScore(
          id: oldBest?.id,
          userProfileId: profileId,
          revisionId: revision.id,
          mode: session.mode,
          shotId: shotId,
          score: score.score,
          achievedAt: now,
        ),
      );
    }
    return PlayResult.completed(
      session: session,
      spawn: spawn,
      shot: shot,
      reveal: PlayReveal(
        goal: goal,
        story: secrets.story,
        highlight: secrets.highlight,
        verticalFovDeg: revision.shotFovDeg,
      ),
    );
  });
}

/// 入力の範囲検証は再送でも行い、歩行領域の検査は新規撮影だけに行う。
ScoringPose validateShotCamera(ScoringPose camera) {
  final fields = <String>[];
  for (final entry in {
    'positionX': camera.positionX,
    'positionZ': camera.positionZ,
    'yawDegrees': camera.yawDegrees,
    'pitchDegrees': camera.pitchDegrees,
  }.entries) {
    if (!entry.value.isFinite) fields.add('camera.${entry.key}');
  }
  if (camera.yawDegrees.isFinite &&
      (camera.yawDegrees < 0 || camera.yawDegrees >= 360)) {
    fields.add('camera.yawDegrees');
  }
  if (camera.pitchDegrees.isFinite && camera.pitchDegrees.abs() > 65) {
    fields.add('camera.pitchDegrees');
  }
  if (fields.isNotEmpty) throw ShotException(.invalidCamera, fields: fields);
  double zero(double value) => value == 0 ? 0.0 : value;
  return ScoringPose(
    positionX: zero(camera.positionX),
    positionZ: zero(camera.positionZ),
    yawDegrees: zero(camera.yawDegrees),
    pitchDegrees: zero(camera.pitchDegrees),
  );
}
