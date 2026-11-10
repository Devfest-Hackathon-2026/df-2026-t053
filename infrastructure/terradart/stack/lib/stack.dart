/// 万博フォトハントの API の実行環境。CI（sa-ci-deploy）が適用する。
///
/// 部品のファイルは resource を返す関数だけを持ち、`add(...)` はこのファイルだけが呼ぶ。
/// SA の作成とプロジェクト単位の IAM は bootstrap が行い、ここではリソース単位の IAM だけを扱う。
library;

import 'package:terradart_google/provider.dart';

import 'api_service.dart';
import 'env.dart';
import 'jobs.dart';
import 'monitoring.dart';
import 'registry.dart';
import 'release.dart';
import 'runtime_env.dart';
import 'secrets.dart';
import 'storage.dart';

final class PhotohuntStack({required Env env, required Release release})
    extends Stack {
  this
    : super(
        providers: [GoogleProvider(project: env.projectId, region: env.region)],
        backend: GcsBackend(
          bucket: env.stateBucket,
          prefix: 'stack/${env.name}',
        ),
      ) {
    // ===== Artifact Registry ===============================================
    add(buildRepository(env));

    // ===== GCS =============================================================
    final db = add(buildDbBucket(env));
    final media = add(buildMediaBucket(env));
    // Cloud Run・Job の起動に要る権限の付与。サービスと Job はこれらの後に作る（下の dependsOn）。
    final runtimeAccess = <TfAddressed>[
      for (final member in buildDbBucketIamMembers(env: env, db: db))
        add(member),
    ];
    buildMediaBucketIamMembers(env: env, media: media).forEach(add);

    // seed の入力。seed Job が読み取り専用でマウントし、素材バケットへ素材を置く。
    final seeds = add(buildSeedsBucket(env));
    buildSeedsUploaderIamMembers(env: env, seeds: seeds).forEach(add);
    final seedAccess = <TfAddressed>[
      add(buildSeedsReaderIamMember(env: env, seeds: seeds)),
      add(buildMediaSeedIamMember(env: env, media: media)),
    ];

    // ===== Secret Manager ==================================================
    final secrets = {
      for (final secret in ServerpodSecret.values)
        secret: add(buildSecret(secret)),
    };
    for (final MapEntry(key: secret, value: resource) in secrets.entries) {
      for (final (accessor, email) in [
        ('api', env.apiServiceAccount),
        // INF-07: Job が起動する Serverpod も production mode で秘密を読むため付与する。
        ('migrate', env.migrateServiceAccount),
      ]) {
        runtimeAccess.add(
          add(
            buildSecretAccessor(
              secret: secret,
              resource: resource,
              accessorName: accessor,
              serviceAccountEmail: email,
            ),
          ),
        );
      }
    }

    final serviceEnv = buildRuntimeEnv(
      env: env,
      release: release,
      maintenanceMode: release.maintenanceMode,
    );
    final jobEnv = buildRuntimeEnv(
      env: env,
      release: release,
      maintenanceMode: false,
    );

    // ===== Cloud Run =======================================================
    final api = add(
      buildApiService(
        env: env,
        release: release,
        runtimeEnv: serviceEnv,
        secrets: secrets,
        dependsOn: runtimeAccess,
      ),
    );
    add(buildPublicInvoker(api));
    for (final job in ApiJob.values) {
      add(
        buildJob(
          job: job,
          env: env,
          release: release,
          runtimeEnv: jobEnv,
          secrets: secrets,
          seeds: seeds,
          dependsOn: [...runtimeAccess, if (job.mountsSeeds) ...seedAccess],
        ),
      );
    }

    // ===== 監視 ============================================================
    if (env.alertEmail case final email?) {
      final channel = add(buildEmailChannel(email));
      add(buildStartupFailureAlert(channel));
      add(buildServerErrorAlert(channel));
    }

    // ===== アプリへ渡す出力 ================================================
    addOutput('api_base_url', api.uri);
    addOutput('asset_base_url', .literal(env.assetBaseUrl));
    addDartDefineOutput(only: ['api_base_url', 'asset_base_url']);
  }
}
