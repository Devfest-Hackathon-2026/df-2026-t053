import 'package:serverpod/serverpod.dart';

import '../../../domain/ports/shot_transaction.dart';
import 'orm_best_score_repository.dart';
import 'orm_challenge_repository.dart';
import 'orm_play_session_repository.dart';
import 'orm_shot_repository.dart';
import 'orm_user_profile_repository.dart';

class OrmShotTransaction(final DatabaseSession session)
    implements ShotTransaction {
  // Serverpod 4.1.1 の SQLite transaction は sqlite_async.writeTransaction
  // （BEGIN IMMEDIATE）を使う。すべての repository に同じ tx を渡す。
  @override
  Future<T> run<T>(Future<T> Function(ShotRepositories) action) =>
      session.db.transaction(
        (tx) => action(
          ShotRepositories(
            challenges: OrmChallengeRepository(session, transaction: tx),
            sessions: OrmPlaySessionRepository(session, transaction: tx),
            shots: OrmShotRepository(session, transaction: tx),
            profiles: OrmUserProfileRepository(session, transaction: tx),
            bestScores: OrmBestScoreRepository(session, transaction: tx),
          ),
        ),
      );
}
