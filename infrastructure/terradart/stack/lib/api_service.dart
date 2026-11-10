/// Cloud Run サービス photohunt-api（docs/specs.md「リソースと実行構成」）。
library;

import 'package:terradart_google/cloud_run.dart';
import 'package:terradart_google/secret_manager.dart';

import 'env.dart';
import 'release.dart';
import 'runtime_env.dart';
import 'secrets.dart';

const String apiServiceName = 'photohunt-api';

/// トラフィックは TerraDart で管理しない（`ignoreChanges`）。apply は新しいリビジョンを
/// 作るだけで、切り替えは保守経由のデプロイ手順が `gcloud` で行う（docs/infrastructure.md 8.5）。
GoogleCloudRunV2Service buildApiService({
  required Env env,
  required Release release,
  required List<EnvVar> runtimeEnv,
  required Map<ServerpodSecret, GoogleSecretManagerSecret> secrets,

  /// 起動に要る権限の付与（secret・DB バケット）。Cloud Run はデプロイ時に実行 SA の
  /// secret の権限を検査し、起動時には DB バケットで所有権の取得と復元を行うので、付与の後に作る。
  required List<TfAddressed> dependsOn,
}) => GoogleCloudRunV2Service(
  'api',
  dependsOn: dependsOn,
  name: .literal(apiServiceName),
  location: .literal(env.region),
  ingress: .all,
  deletionProtection: .literal(true),
  template: CloudRunV2ServiceTemplate(
    serviceAccount: .literal(env.apiServiceAccount),
    executionEnvironment: .gen2,
    maxInstanceRequestConcurrency: .literal(10),
    timeout: .literal('120s'),
    // 単一 writer。最大 1 でも置換時には重なるので、排他は writer 所有権で行う。
    scaling: .new(minInstanceCount: .literal(0), maxInstanceCount: .literal(1)),
    labels: .literal({
      'app': 'photohunt',
      'mode': release.maintenanceMode ? 'maintenance' : 'normal',
    }),
    containers: [
      .new(
        image: .literal(release.apiImage),
        ports: .new(containerPort: .literal(8080)),
        resources: .new(
          limits: .literal({'cpu': '1', 'memory': '1Gi'}),
          // インスタンスベース課金。Litestream がリクエスト外でも複製できるようにする。
          cpuIdle: .literal(false),
          startupCpuBoost: .literal(true),
        ),
        // Serverpod は所有権の取得・復元・Litestream の準備が終わってから待ち受けを始めるので、
        // TCP の接続を準備完了とみなす。上限は 5 秒 × 48 回 = 240 秒。
        startupProbe: .new(
          tcpSocket: .new(port: .literal(8080)),
          periodSeconds: .literal(5),
          timeoutSeconds: .literal(3),
          failureThreshold: .literal(48),
        ),
        env: [
          for (final (:name, :value) in runtimeEnv)
            .new(name: .literal(name), source: .value(value)),
          for (final MapEntry(key: secret, value: resource) in secrets.entries)
            .new(
              name: .literal(secret.variable),
              source: .valueSource(
                .new(
                  secretKeyRef: .new(
                    secret: resource.ref,
                    version: .literal('${secret.versionIn(env)}'),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  ),
  lifecycle: const .new(
    ignoreChanges: .of(['traffic', 'client', 'client_version']),
  ),
);

/// アプリから匿名で呼ぶ公開 API。認可は Serverpod の匿名認証が行う。
GoogleCloudRunV2ServiceIamMember buildPublicInvoker(
  GoogleCloudRunV2Service service,
) => GoogleCloudRunV2ServiceIamMember(
  'api_public',
  service: service.ref,
  role: .literal('roles/run.invoker'),
  member: .allUsers,
);
