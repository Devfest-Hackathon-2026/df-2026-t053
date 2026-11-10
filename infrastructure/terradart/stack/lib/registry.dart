/// API の image を置く Artifact Registry。
library;

import 'package:terradart_google/artifact_registry.dart';

import 'env.dart';

/// 直近 10 個を切り戻し先として残し、それ以外の 14 日を超えた image を消す（保管料を抑える）。
GoogleArtifactRegistryRepository buildRepository(Env env) =>
    GoogleArtifactRegistryRepository(
      'photohunt',
      repositoryId: .literal(artifactRepositoryId),
      location: .literal(env.region),
      format: .docker,
      description: .literal('万博フォトハントの API image'),
      cleanupPolicies: [
        ArtifactRegistryRepositoryCleanupPolicies(
          id: .literal('keep-recent'),
          action: .keep,
          mostRecentVersions: .new(keepCount: .literal(10)),
        ),
        ArtifactRegistryRepositoryCleanupPolicies(
          id: .literal('delete-old'),
          action: .delete,
          condition: .new(tagState: .any, olderThan: .literal('1209600s')),
        ),
      ],
    );
