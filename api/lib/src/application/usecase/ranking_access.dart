import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// 両読み取りで同じ検査順を使う。プロフィールの作成・復旧は認証フローが扱う。
Future<int> requireRankingProfile({
  required RankingRepository rankings,
  required UserProfileRepository profiles,
  required UuidValue authUserId,
  required int revisionId,
  required PlayMode mode,
}) async {
  if (mode == .unknown) throw const RankingException(.invalidRequest);
  if (!await rankings.publishedRevisionExists(revisionId)) {
    throw const RankingException(.revisionNotFound);
  }
  final profile = await profiles.findByAuthUserId(authUserId);
  final id = profile?.id;
  if (id == null) throw const RankingException(.profileNotInitialized);
  return id;
}
