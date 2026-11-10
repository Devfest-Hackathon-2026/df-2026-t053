import 'package:serverpod/serverpod.dart';

import '../../application/usecase/get_play_session.dart';
import '../../application/usecase/start_play.dart';
import '../../application/usecase/submit_shot.dart';
import '../../infrastructure/database/repositories/orm_shot_transaction.dart';
import '../../domain/ports/start_rate_limiter.dart';
import '../../infrastructure/database/repositories/orm_challenge_repository.dart';
import '../../infrastructure/database/repositories/orm_play_session_repository.dart';
import '../../infrastructure/database/repositories/orm_shot_repository.dart';
import '../../infrastructure/database/repositories/orm_user_profile_repository.dart';
import '../../infrastructure/play/in_memory_start_rate_limiter.dart';
import '../../infrastructure/play/secure_spawn_chooser.dart';

/// 開始の頻度制限は、プロセス内で 1 つを共有する（再起動で消えてよい補助的な制限）。
final StartRateLimiter _startRateLimiter = InMemoryStartRateLimiter();
final SecureSpawnChooser _spawnChooser = SecureSpawnChooser();

StartPlay startPlayUseCase(Session session) => StartPlay(
  OrmChallengeRepository(session),
  OrmPlaySessionRepository(session),
  OrmShotRepository(session),
  OrmUserProfileRepository(session),
  _startRateLimiter,
  _spawnChooser,
  DateTime.now,
  () => const Uuid().v7obj(),
);

GetPlaySession getPlaySessionUseCase(Session session) => GetPlaySession(
  OrmChallengeRepository(session),
  OrmPlaySessionRepository(session),
  OrmShotRepository(session),
  OrmUserProfileRepository(session),
);

SubmitShot submitShotUseCase(Session session) =>
    SubmitShot(OrmShotTransaction(session), DateTime.now);
