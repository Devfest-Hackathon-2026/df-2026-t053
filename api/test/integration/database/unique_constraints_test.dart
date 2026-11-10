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
import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:photohunt_server/src/infrastructure/database/unique_violation.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'support.dart';

/// 各一意制約について、2 行目の挿入が DuplicateEntityException になる。
void main() {
  withDatabase('Given 一意制約', (sessionBuilder) {
    late Session s;
    setUp(() => s = sessionBuilder.build());

    test('challenge.slug', () async {
      await insertChallenge(s, slug: 'expo');
      await expectLater(
        translateUniqueViolation(() => insertChallenge(s, slug: 'expo')),
        throwsDuplicate('challenge', 'challenge_slug_uk'),
      );
    });

    test('challenge_revision (challenge_id, revision_no)', () async {
      final c = await insertChallenge(s);
      await insertRevision(s, challenge: c, revisionNo: 1);
      await expectLater(
        translateUniqueViolation(
          () => insertRevision(s, challenge: c, revisionNo: 1),
        ),
        throwsDuplicate(
          'challenge_revision',
          'challenge_revision_challenge_no_uk',
        ),
      );
      // 別の版番号なら入る。
      await insertRevision(s, challenge: c, revisionNo: 2);
    });

    test('mode_config (revision_id, mode)', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      await insertModeConfig(s, revision: r, mode: PlayMode.free);
      await expectLater(
        translateUniqueViolation(
          () => insertModeConfig(s, revision: r, mode: PlayMode.free),
        ),
        throwsDuplicate('mode_config', 'mode_config_revision_mode_uk'),
      );
      await insertModeConfig(s, revision: r, mode: PlayMode.near);
    });

    test('spawn_point (mode_config_id, sort_order)', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      final m = await insertModeConfig(s, revision: r);
      await insertSpawn(s, modeConfig: m, sortOrder: 0);
      await expectLater(
        translateUniqueViolation(
          () => insertSpawn(s, modeConfig: m, sortOrder: 0),
        ),
        throwsDuplicate('spawn_point', 'spawn_point_mode_config_order_uk'),
      );
      await insertSpawn(s, modeConfig: m, sortOrder: 1);
    });

    test('asset.sha256', () async {
      await insertAsset(s, sha256: sha(1));
      await expectLater(
        translateUniqueViolation(() => insertAsset(s, sha256: sha(1))),
        throwsDuplicate('asset', 'asset_sha256_uk'),
      );
    });

    test('pavilion.source_key', () async {
      await insertPavilion(s, sourceKey: 'p1');
      await expectLater(
        translateUniqueViolation(() => insertPavilion(s, sourceKey: 'p1')),
        throwsDuplicate('pavilion', 'pavilion_source_key_uk'),
      );
    });

    test('landmark (revision_id, pavilion_id)', () async {
      final c = await insertChallenge(s);
      final r = await insertRevision(s, challenge: c);
      final p = await insertPavilion(s);
      Future<LandmarkRow> insert() => LandmarkRow.db.insertRow(
        s,
        LandmarkRow(
          revisionId: r.id!,
          pavilionId: p.id!,
          displayName: 'name',
          posX: 1,
          posZ: 2,
        ),
      );
      await insert();
      await expectLater(
        translateUniqueViolation(insert),
        throwsDuplicate('landmark', 'landmark_revision_pavilion_uk'),
      );
    });

    test('user_profile.auth_user_id（nickname は重複できる）', () async {
      final authUserId = const Uuid().v4obj();
      await insertProfile(s, authUserId: authUserId);
      await expectLater(
        translateUniqueViolation(
          () => insertProfile(s, authUserId: authUserId),
        ),
        throwsDuplicate('user_profile', 'user_profile_auth_user_uk'),
      );
      // 同じ nickname の別ユーザーは入る（insertProfile は常に 'nick'）。
      await insertProfile(s);
    });

    test('play_session (user_profile_id, request_id)', () async {
      final f = await insertFixture(s);
      final requestId = const Uuid().v4obj();
      await insertPlaySession(s, f, requestId: requestId);
      await expectLater(
        translateUniqueViolation(
          () => insertPlaySession(s, f, requestId: requestId),
        ),
        throwsDuplicate('play_session', 'play_session_profile_request_uk'),
      );
      // 別ユーザーなら同じ requestId でも入る。
      final other = await insertProfile(s);
      await PlaySessionRow.db.insertRow(
        s,
        PlaySessionRow(
          id: const Uuid().v7obj(),
          requestId: requestId,
          revisionId: f.revision.id!,
          mode: PlayMode.free,
          spawnPointId: f.spawn.id!,
          userProfileId: other.id!,
          startedAt: t0,
          expiresAt: t0,
        ),
      );
    });

    test('shot.play_session_id', () async {
      final f = await insertFixture(s);
      final play = await insertPlaySession(s, f);
      await insertShotRow(s, play);
      await expectLater(
        translateUniqueViolation(() => insertShotRow(s, play)),
        throwsDuplicate('shot', 'shot_play_session_uk'),
      );
    });

    test('best_score (user_profile_id, revision_id, mode) と shot_id', () async {
      final f = await insertFixture(s);
      final play = await insertPlaySession(s, f);
      final shot = await insertShotRow(s, play);
      Future<BestScoreRow> insert({required int shotId, PlayMode? mode}) =>
          BestScoreRow.db.insertRow(
            s,
            BestScoreRow(
              userProfileId: f.profile.id!,
              revisionId: f.revision.id!,
              mode: mode ?? PlayMode.free,
              shotId: shotId,
              score: 500,
              achievedAt: t0,
            ),
          );
      await insert(shotId: shot.id!);

      // 同じ本人・版・モード。
      final play2 = await insertPlaySession(s, f);
      final shot2 = await insertShotRow(s, play2);
      await expectLater(
        translateUniqueViolation(() => insert(shotId: shot2.id!)),
        throwsDuplicate('best_score', 'best_score_profile_revision_mode_uk'),
      );
      // 別モードで同じ shot_id。
      await expectLater(
        translateUniqueViolation(
          () => insert(shotId: shot.id!, mode: PlayMode.near),
        ),
        throwsDuplicate('best_score', 'best_score_shot_uk'),
      );
    });

    test('play_session の主キー（UUID）の重複', () async {
      final f = await insertFixture(s);
      final play = await insertPlaySession(s, f);
      await expectLater(
        translateUniqueViolation(
          () => PlaySessionRow.db.insertRow(
            s,
            PlaySessionRow(
              id: play.id,
              requestId: const Uuid().v4obj(),
              revisionId: f.revision.id!,
              mode: PlayMode.free,
              spawnPointId: f.spawn.id!,
              userProfileId: f.profile.id!,
              startedAt: t0,
              expiresAt: t0,
            ),
          ),
        ),
        throwsDuplicate('play_session', 'play_session_pkey'),
      );
    });
  });
}
