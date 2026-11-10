import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';

import 'src/generated/protocol.dart';
import 'src/presentation/di/guide_transport_dependencies.dart';
import 'src/domain/ports/persistence_gate.dart';
import 'src/presentation/middleware/guide_stream.dart';
import 'src/infrastructure/config/anonymous_signup_settings.dart';
import 'src/infrastructure/config/replication_settings.dart';
import 'src/infrastructure/database/replication/litestream_confirmer.dart';
import 'src/infrastructure/database/replication/passthrough_executor.dart';
import 'src/infrastructure/database/replication/serial_persistence_gate.dart';
import 'src/presentation/di/challenge_dependencies.dart';
import 'src/presentation/di/guide_dependencies.dart';
import 'src/presentation/middleware/guide_transport.dart';
import 'src/presentation/middleware/persistence_middleware.dart';
import 'src/presentation/di/profile_dependencies.dart';
import 'src/presentation/di/configured_endpoints.dart';

/// 引数から Serverpod を組み立てる。認証だけを設定し、起動はしない。
///
/// 統合テストは起動前に返る [Serverpod] を使う。
Serverpod createServer(
  List<String> args, {
  AnonymousSignupSettings? anonymousSignupSettings,
}) {
  final settings =
      anonymousSignupSettings ??
      AnonymousSignupSettings.fromEnvironment(Platform.environment);
  final pod = Serverpod(args, Protocol(), ConfiguredEndpoints(settings));

  _ensureSqliteDirectory(pod.config.database);

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // 認証トークンは JWT。署名鍵とペッパーは passwords.yaml から読む。
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // 制限はendpointで作成トランザクションの前に判定する（SQLiteの入れ子を避ける）。
      AnonymousIdpConfig(
        perIpAddressRateLimit: null,
        onAfterAnonymousAccountCreated:
            (session, {required authUserId, required transaction}) async {
              await ensureUserProfileUseCase(
                session,
                transaction: transaction,
              ).execute(authUserId);
            },
      ),
    ],
  );

  pod.server.addMiddleware(guideTransportMiddleware(createGuideTransport));
  final persistence = _installPersistenceGate(pod);
  configureGuideStreaming(
    pod,
    gate: persistence?.gate,
    maintenance: persistence?.maintenance,
  );
  // 素材の公開 URL の基底（ASSET_BASE_URL）を起動時に検証する。誤りなら起動しない。
  configureAssetUrls(pod);
  // ガイドの設定（GUIDE_BACKEND・Vertex AI のプロジェクトとロケーション・Gemini のモデル）を
  // 起動時に検証する。
  configureGuides(pod);

  return pod;
}

/// RPC 1 件の全体を共通ゲートの中で実行する（SQLite 更新 → GCS 複製確認 → 応答）。
///
/// 複製を前提にするのは production だけ。development / test は Litestream なしで動く。
/// migration Job（`--role=maintenance`）は自分で所有権と複製を扱うので接続しない。
({PersistenceGate gate, MaintenanceState? maintenance})?
_installPersistenceGate(Serverpod pod) {
  if (pod.runMode != ServerpodRunMode.production) return null;
  if (pod.config.role.name == 'maintenance') return null;
  final database = pod.config.database;
  if (database is! SqliteDatabaseConfig) {
    throw const ConfigurationException('production の DB は SQLite だけです');
  }

  final settings = ReplicationSettings.fromEnvironment(
    Platform.environment,
    dbPath: database.filePath,
  );

  final gate = SerialPersistenceGate(
    executor: const PassthroughExecutor(),
    confirmer: LitestreamConfirmer(
      socketPath: settings.litestreamSocketPath,
      dbPath: settings.dbPath,
    ),
    // 複製を確認できず、未複製のローカル状態が残る恐れがある。受付を止めて落とし、
    // supervisor が Litestream を止めて所有権を解放する。次の起動で GCS から復旧する。
    onUnrecoverable: () {
      stderr.writeln('複製を確認できないため停止します（GCS から復旧します）');
      exit(75);
    },
  );

  final maintenance = settings.maintenanceMode
      ? MaintenanceState(settings.maintenanceReason)
      : null;
  pod.server.addMiddleware(
    persistenceGateMiddleware(
      gate: gate,
      // Cloud Run の要求上限（120 秒）より短く、複製確認の待ちもこの内側に収める。
      requestDeadline: const Duration(seconds: 100),
      maxRequestSize: pod.config.maxRequestSize,
      maintenance: maintenance,
    ),
  );
  return (gate: gate, maintenance: maintenance);
}

/// SQLite の保存先ディレクトリを作る。clone 直後の `./data` などで、
/// Serverpod が DB ファイルを開けずに落ちないようにする。
void _ensureSqliteDirectory(DatabaseConfig? database) {
  if (database is! SqliteDatabaseConfig) return;
  if (database.filePath == ':memory:') return;
  File(database.filePath).parent.createSync(recursive: true);
}

/// 起動処理。`bin/main.dart` はこれを呼ぶだけにする。
Future<void> run(List<String> args) async {
  final pod = createServer(args);
  await pod.start();
}
