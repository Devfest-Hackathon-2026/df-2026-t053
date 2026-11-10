/// TerraDart の state を置くバケット。
library;

import 'package:terradart_google/storage.dart';

/// 非公開・バージョニング有効。state の誤削除・破損から戻せるようにする。
GoogleStorageBucket buildStateBucket({
  required String name,
  required String location,
  List<TfAddressed> dependsOn = const [],
}) => GoogleStorageBucket(
  'tfstate',
  dependsOn: dependsOn,
  name: .literal(name),
  location: .literal(location),
  storageClass: .standard,
  uniformBucketLevelAccess: .literal(true),
  publicAccessPrevention: .literal('enforced'),
  forceDestroy: .literal(false),
  versioning: const .new(enabled: .literal(true)),
  labels: .literal({'app': 'photohunt', 'component': 'tfstate'}),
);
