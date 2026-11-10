import 'package:photohunt_shared/photohunt_shared.dart'
    show PointXZ, isInsideWalkable;
import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/play_session_repository.dart';
import '../../domain/repositories/shot_repository.dart';
import '../../domain/repositories/structure_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/services/nearby_structure_selector.dart';
import '../dto/guide_text_result.dart';

class PrepareNearbyGuide(
  final ChallengeRepository challenges,
  final PlaySessionRepository sessions,
  final ShotRepository shots,
  final StructureRepository structures,
  final UserProfileRepository profiles,
  final DateTime Function() now,
) {
  Future<List<GuideMaterial>> execute(
    UuidValue userId,
    UuidValue playId, {
    required double x,
    required double z,
    required double yaw,
  }) async {
    final play = await sessions.findById(playId);
    if (play == null) throw const PlayException(.sessionNotFound);
    final profileId = (await profiles.findByAuthUserId(userId))?.id;
    if (profileId == null) throw const PlayException(.profileNotInitialized);
    if (play.userProfileId != profileId) {
      throw const PlayException(.notSessionOwner);
    }
    if (await shots.findByPlaySessionId(playId) != null) {
      throw const GuidePreconditionException(.completed);
    }
    if (!now().isBefore(play.expiresAt)) {
      throw const GuidePreconditionException(.expired);
    }
    if (!x.isFinite || !z.isFinite || !yaw.isFinite || yaw < 0 || yaw >= 360) {
      throw const InvalidGuidePoseException();
    }
    final revision = await challenges.findRevision(play.revisionId);
    if (revision == null) {
      throw const CorruptedDataException(
        entity: 'play_session',
        field: 'revision_id',
        message: 'プレイの版がありません',
      );
    }
    final modes = revision.modes.where((m) => m.mode == play.mode);
    if (modes.length != 1) {
      throw const CorruptedDataException(
        entity: 'mode_config',
        field: 'mode',
        message: 'モードの設定が不正です',
      );
    }
    if (!isInsideWalkable(modes.single.walkable, PointXZ(x: x, z: z))) {
      throw const InvalidGuidePoseException();
    }
    final selected = const NearbyStructureSelector().select(
      revisionId: revision.id,
      positionX: x,
      positionZ: z,
      yawDegrees: yaw,
      structures: await structures.listByRevision(revision.id),
    );
    return [
      for (final s in selected)
        GuideMaterial(
          structureId: s.id,
          name: s.name,
          facts: s.facts,
          fallbackText: s.fallbackText,
          sources: s.sources,
          direction: switch (s.direction) {
            .front => .front,
            .left => .left,
            .right => .right,
            .behind => .behind,
            .none => .none,
          },
          distanceMeters: s.distanceMeters,
        ),
    ];
  }
}
