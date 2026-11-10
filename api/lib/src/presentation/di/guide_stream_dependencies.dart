import 'package:serverpod/serverpod.dart';

import '../../application/usecase/explain_nearby.dart';
import '../../application/usecase/prepare_nearby_guide.dart';
import '../../domain/ports/guide_admission.dart';
import '../../infrastructure/database/repositories/orm_challenge_repository.dart';
import '../../infrastructure/database/repositories/orm_play_session_repository.dart';
import '../../infrastructure/database/repositories/orm_shot_repository.dart';
import '../../infrastructure/database/repositories/orm_structure_repository.dart';
import '../../infrastructure/database/repositories/orm_user_profile_repository.dart';
import '../../infrastructure/guide/in_memory_guide_admission.dart';
import '../middleware/guide_stream.dart';
import 'guide_dependencies.dart';

/// 回数制限は再設定（[configureGuideStreaming]）ごとに作り直す。
final _admissions = Expando<GuideAdmission>();

GuideAdmission guideAdmission(Session session) =>
    _admissions[guideStreamContext(session)] ??= InMemoryGuideAdmission();

PrepareNearbyGuide prepareNearbyGuide(Session session) => PrepareNearbyGuide(
  OrmChallengeRepository(session),
  OrmPlaySessionRepository(session),
  OrmShotRepository(session),
  OrmStructureRepository(session),
  OrmUserProfileRepository(session),
  DateTime.now,
);

ExplainNearby explainNearbyUseCase(
  Session session,
  GuideGenerators generators,
) => ExplainNearby(
  text: generators.composeText(),
  speech: generators.speech,
  admission: guideAdmission(session),
  enabled: () => guideGenerators() != null,
);
