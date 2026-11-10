/// DB レプリカ（非公開）と公開素材のバケット、およびバケット単位の IAM。
library;

import 'package:terradart_google/storage.dart';

import 'env.dart';

/// Litestream のレプリカと writer 所有権。匿名では読めない（Public Access Prevention）。
/// 所有権オブジェクトは実行時の排他状態なので、ここでは作らない。
GoogleStorageBucket buildDbBucket(Env env) => GoogleStorageBucket(
  'db',
  name: .literal(env.dbBucket),
  location: .literal(env.region),
  storageClass: .standard,
  uniformBucketLevelAccess: .literal(true),
  publicAccessPrevention: .literal('enforced'),
  forceDestroy: .literal(false),
  labels: .literal({'app': 'photohunt', 'component': 'db'}),
);

/// 許諾済みの写真・会場図。内容ハッシュ付きの不変パスで公開する。
GoogleStorageBucket buildMediaBucket(Env env) => GoogleStorageBucket(
  'media',
  name: .literal(env.mediaBucket),
  location: .literal(env.region),
  storageClass: .standard,
  uniformBucketLevelAccess: .literal(true),
  publicAccessPrevention: .literal('inherited'),
  forceDestroy: .literal(false),
  labels: .literal({'app': 'photohunt', 'component': 'media'}),
);

/// API と Job は、レプリカの読み取り・一覧・作成・削除だけを行う（IAM の変更はできない）。
List<GoogleStorageBucketIamMember> buildDbBucketIamMembers({
  required Env env,
  required GoogleStorageBucket db,
}) => [
  for (final (name, email) in [
    ('api', env.apiServiceAccount),
    ('migrate', env.migrateServiceAccount),
  ])
    GoogleStorageBucketIamMember(
      'db_$name',
      bucket: db.ref,
      role: .literal('roles/storage.objectUser'),
      member: .serviceAccount(email),
    ),
];

List<GoogleStorageBucketIamMember> buildMediaBucketIamMembers({
  required Env env,
  required GoogleStorageBucket media,
}) => [
  GoogleStorageBucketIamMember(
    'media_public',
    bucket: media.ref,
    role: .literal('roles/storage.objectViewer'),
    member: .allUsers,
  ),
  // API の実行 SA（sa-api）には素材の書き込み権限を与えない。人の担当は objectAdmin。
  for (final (i, member) in env.mediaUploaders.indexed)
    GoogleStorageBucketIamMember(
      'media_uploader_$i',
      bucket: media.ref,
      role: .literal('roles/storage.objectAdmin'),
      member: .literal(member),
    ),
];

/// seed Job（sa-migrate）は出題の登録時に素材を置く。内容ハッシュ付きの不変パスへの作成だけで、
/// 上書き・削除はしない（既にあれば公開の読み取りで内容を比べる）ので objectCreator にする。
GoogleStorageBucketIamMember buildMediaSeedIamMember({
  required Env env,
  required GoogleStorageBucket media,
}) => GoogleStorageBucketIamMember(
  'media_seed',
  bucket: media.ref,
  role: .literal('roles/storage.objectCreator'),
  member: .serviceAccount(env.migrateServiceAccount),
);

/// seed の入力（`content/seeds` の写し）。許諾前の素材も含み得るので、匿名では読めない。
/// 実行時の正本は DB なので、ここを上書き・削除しても公開済みの版は変わらない。
GoogleStorageBucket buildSeedsBucket(Env env) => GoogleStorageBucket(
  'seeds',
  name: .literal(env.seedsBucket),
  location: .literal(env.region),
  storageClass: .standard,
  uniformBucketLevelAccess: .literal(true),
  publicAccessPrevention: .literal('enforced'),
  forceDestroy: .literal(false),
  labels: .literal({'app': 'photohunt', 'component': 'seeds'}),
);

/// seed Job（sa-migrate）は seed の入力を読むだけ。
GoogleStorageBucketIamMember buildSeedsReaderIamMember({
  required Env env,
  required GoogleStorageBucket seeds,
}) => GoogleStorageBucketIamMember(
  'seeds_reader',
  bucket: seeds.ref,
  role: .literal('roles/storage.objectViewer'),
  member: .serviceAccount(env.migrateServiceAccount),
);

/// seed の入力を上げる担当（素材の担当と同じ）。
List<GoogleStorageBucketIamMember> buildSeedsUploaderIamMembers({
  required Env env,
  required GoogleStorageBucket seeds,
}) => [
  for (final (i, member) in env.mediaUploaders.indexed)
    GoogleStorageBucketIamMember(
      'seeds_uploader_$i',
      bucket: seeds.ref,
      role: .literal('roles/storage.objectAdmin'),
      member: .literal(member),
    ),
];
