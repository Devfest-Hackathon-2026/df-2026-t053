/// stack を適用する環境。クラウドは prod だけ（docs/infrastructure.md 4）。
///
/// プロジェクト ID・バケット名は INF-01 で確定した値。
enum Env({
  required final String projectId,

  /// Litestream のレプリカと writer 所有権を置く非公開バケット。
  required final String dbBucket,

  /// 許諾済みの写真・会場図を置く公開バケット。
  required final String mediaBucket,

  /// seed の入力（`content/seeds` の写し）を置く非公開バケット。seed Job が [seedsMountPath] に
  /// 読み取り専用でマウントする。出題の更新に image の再ビルドを要さない（docs/specs.md「リポジトリ内の責務」）。
  required final String seedsBucket,

  /// Secret Manager の版。Cloud Run と Job は固定した版だけを参照する。
  required final int jwtHmacKeyVersion,
  required final int jwtRefreshPepperVersion,

  required final GuideConfig guide,

  /// media バケットへの書き込みを許す IAM member。
  required final List<String> mediaUploaders,

  /// 起動失敗・5xx の通知先。null なら監視の resource を作らない。
  required final String? alertEmail,
}) {
  prod(
    projectId: 'gdg-hack-514011',
    dbBucket: 'photohunt-db-prod',
    mediaBucket: 'photohunt-media-prod',
    seedsBucket: 'photohunt-seeds-prod',
    // `gcloud secrets versions add` で入れた版。値は state に残さない。
    jwtHmacKeyVersion: 1,
    jwtRefreshPepperVersion: 1,
    guide: GuideConfig(
      // D07（#134）で Vertex AI（global）の文生成と TTS を確認した値。文生成は費用を優先して
      // flash-lite にする。事実の欠落が問題になったら gemini-3.8-flash＋low に戻す。
      enabled: true,
      textModel: 'gemini-3.5-flash-lite',
      textThinkingLevel: 'minimal',
      ttsModel: 'gemini-3.8-flash-lite-tts',
      voiceId: 'Kore',
      promptVersion: 'v2',
    ),
    // 素材と seed の入力をアップロードする担当（`group:...` / `user:...`）。
    mediaUploaders: [],
    // 起動失敗・5xx の通知先。null なら監視の resource を作らない。
    alertEmail: null,
  );

  String get region => 'asia-northeast1';

  /// bootstrap が作る tfstate バケット。
  String get stateBucket => '$projectId-tfstate';

  /// bootstrap が作る SA（`bootstrap/lib/identity.dart` の accountId と同じ規則）。
  String serviceAccountEmail(String accountId) =>
      '$accountId@$projectId.iam.gserviceaccount.com';

  String get apiServiceAccount => serviceAccountEmail('sa-api');
  String get migrateServiceAccount => serviceAccountEmail('sa-migrate');

  /// API の image を置く Artifact Registry の repository のパス。
  String get imageRepository =>
      '$region-docker.pkg.dev/$projectId/$artifactRepositoryId';

  /// 公開素材の URL の基点。アプリと API の `ASSET_BASE_URL` に使う。
  String get assetBaseUrl => 'https://storage.googleapis.com/$mediaBucket/';
}

/// Artifact Registry の repository ID。
const String artifactRepositoryId = 'photohunt';

/// DB レプリカの prefix。変えると空の DB へ切り替わるのと同じなので、データ移行として扱う。
const String dbReplicaPrefix = 'litestream/v1';

/// writer 所有権のオブジェクト。レプリカとは別 prefix。apply では作らない。
const String dbWriterOwnerObject = 'owner/writer.json';

/// seed Job が seed の入力を読む場所。ローカルの compose と同じ（`../../content` を `/content` にマウント）
/// なので、seed の引数（`--dir /content/seeds/<slug>/r<n>`）は本番とローカルで同じになる。
const String seedsMountPath = '/content/seeds';

/// AI ガイドの設定（docs/specs.md「設定値」、#78）。
final class const GuideConfig({
  required final bool enabled,

  /// 未設定（null）はガイドを止めている間だけ許す。有効にするときは [missingForGemini] が空であること。
  required final String? textModel,
  required final String? textThinkingLevel,
  required final String? ttsModel,
  required final String? voiceId,
  required final String promptVersion,
}) {
  /// ガイドを有効にするのに足りない設定。API の起動時の検査と同じ項目。
  List<String> get missingForGemini => [
    if (textModel == null) 'GEMINI_TEXT_MODEL',
    if (textThinkingLevel == null) 'GEMINI_TEXT_THINKING_LEVEL',
    if (ttsModel == null) 'GEMINI_TTS_MODEL',
    if (voiceId == null) 'GUIDE_VOICE_ID',
  ];
}
