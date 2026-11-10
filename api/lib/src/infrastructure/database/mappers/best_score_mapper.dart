import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';
import 'play_mode_mapper.dart';

BestScore bestScoreFromRow(BestScoreRow row) => BestScore(
  id: row.id!,
  userProfileId: row.userProfileId,
  revisionId: row.revisionId,
  mode: playModeFromRow(row.mode, entity: 'best_score'),
  shotId: row.shotId,
  score: row.score,
  achievedAt: row.achievedAt.toUtc(),
);

BestScoreRow bestScoreToRow(BestScore score) => BestScoreRow(
  id: score.id,
  userProfileId: score.userProfileId,
  revisionId: score.revisionId,
  mode: playModeToRow(score.mode),
  shotId: score.shotId,
  score: score.score,
  achievedAt: score.achievedAt.toUtc(),
);
