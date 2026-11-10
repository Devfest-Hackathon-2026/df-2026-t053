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
import 'package:uuid/uuid_value.dart';

/// 1 回のプレイ。[id] はサーバーが生成する UUID で、認証の代わりにはならない。
class const PlaySession({
  required final UuidValue id,
  required final UuidValue requestId,
  required final int revisionId,
  required final PlayMode mode,
  required final int spawnPointId,
  required final int userProfileId,
  required final DateTime startedAt,
  required final DateTime expiresAt,
});
