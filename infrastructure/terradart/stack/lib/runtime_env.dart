/// Cloud Run サービスと Job に共通で渡す環境変数（docs/specs.md「設定値」）。
///
/// サービスと Job で同じ DB 系の設定を使うことが、writer 所有権と復元の前提になる。
library;

import 'package:terradart_core/terradart_core.dart';

import 'env.dart';
import 'release.dart';

/// 名前と値の組。
typedef EnvVar = ({String name, TfArg<String> value});

/// [maintenanceMode] はサービスだけが使う。Job は保守経由のデプロイ中に実行されるので、保守モードの
/// apply で定義が変わらないよう、常に false を渡す。
List<EnvVar> buildRuntimeEnv({
  required Env env,
  required Release release,
  required bool maintenanceMode,
}) {
  final guide = env.guide;
  if (guide.enabled && guide.missingForGemini.isNotEmpty) {
    throw StateError(
      'Env.guide を有効にするには ${guide.missingForGemini.join(', ')} が要る',
    );
  }
  String orEmpty(String? value) => value ?? '';
  return [
    for (final (name, value) in <(String, String)>[
      ('RELEASE_ID', release.releaseId),
      ('MAINTENANCE_MODE', '$maintenanceMode'),
      ('DB_REPLICA_BUCKET', env.dbBucket),
      ('DB_REPLICA_PREFIX', dbReplicaPrefix),
      ('DB_WRITER_OWNER_OBJECT', dbWriterOwnerObject),
      ('LITESTREAM_SOCKET_PATH', '/var/run/litestream.sock'),
      ('ASSET_BUCKET', env.mediaBucket),
      ('ASSET_BASE_URL', env.assetBaseUrl),
      ('ANON_SIGNUP_LIMIT_PER_HOUR', '100'),
      ('GUIDE_BACKEND', 'gemini'),
      ('GUIDES_ENABLED', '${guide.enabled}'),
      ('VERTEX_PROJECT_ID', env.projectId),
      ('VERTEX_LOCATION', 'global'),
      ('GEMINI_TEXT_MODEL', orEmpty(guide.textModel)),
      ('GEMINI_TEXT_THINKING_LEVEL', orEmpty(guide.textThinkingLevel)),
      ('GEMINI_TTS_MODEL', orEmpty(guide.ttsModel)),
      ('GUIDE_PROMPT_VERSION', guide.promptVersion),
      ('GUIDE_VOICE_ID', orEmpty(guide.voiceId)),
    ])
      (name: name, value: TfArg.literal(value)),
  ];
}
