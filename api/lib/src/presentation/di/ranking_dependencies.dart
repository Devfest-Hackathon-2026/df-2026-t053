import 'package:serverpod/serverpod.dart';

import '../../application/usecase/get_my_ranking_entry.dart';
import '../../application/usecase/list_ranking_entries.dart';
import '../../infrastructure/database/repositories/orm_user_profile_repository.dart';
import '../../infrastructure/database/repositories/sqlite_ranking_repository.dart';

ListRankingEntries listRankingEntriesUseCase(Session session) =>
    ListRankingEntries(
      SqliteRankingRepository(session),
      OrmUserProfileRepository(session),
    );

GetMyRankingEntry getMyRankingEntryUseCase(Session session) =>
    GetMyRankingEntry(
      SqliteRankingRepository(session),
      OrmUserProfileRepository(session),
    );
