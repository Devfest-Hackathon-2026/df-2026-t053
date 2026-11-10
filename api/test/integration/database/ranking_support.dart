import 'package:photohunt_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

import 'support.dart';

/// 下書きとして作った [fixture] の版を公開する（子の行を入れ終えた後に呼ぶ）。
/// ランキングは下書きの版を notFound にするので、読み取りの前に公開しておく。
Future<void> publishFixture(Session session, Fixture fixture) async {
  await ChallengeRevisionRow.db.updateRow(
    session,
    fixture.revision.copyWith(publishedAt: t0),
  );
}

/// #29の書き込み実装を使わず、既存の制約を満たす保存済みの記録を用意する。
Future<ShotRow> insertRankedScore(
  Session session,
  Fixture fixture, {
  UserProfileRow? profile,
  int score = 500,
  DateTime? achievedAt,
}) async {
  final owner = profile ?? fixture.profile;
  final play = await PlaySessionRow.db.insertRow(
    session,
    PlaySessionRow(
      id: const Uuid().v7obj(),
      requestId: const Uuid().v4obj(),
      revisionId: fixture.revision.id!,
      mode: fixture.modeConfig.mode,
      spawnPointId: fixture.spawn.id!,
      userProfileId: owner.id!,
      startedAt: t0,
      expiresAt: t0.add(const Duration(hours: 2)),
    ),
  );
  final shot = await insertShotRow(session, play, score: score);
  await BestScoreRow.db.insertRow(
    session,
    BestScoreRow(
      userProfileId: owner.id!,
      revisionId: fixture.revision.id!,
      mode: fixture.modeConfig.mode,
      shotId: shot.id!,
      score: score,
      achievedAt: achievedAt ?? t0,
    ),
  );
  return shot;
}
