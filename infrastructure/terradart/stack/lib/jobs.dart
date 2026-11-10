/// Cloud Run Job photohunt-migrate・photohunt-seed（docs/specs.md「DBマイグレーション」）。
///
/// API と同じ image・同じ DB 系の環境変数を使い、同じ writer 所有権を取ってから書き込む。
/// 実行は構成の apply から分け、保守経由のデプロイ手順が `gcloud run jobs execute` で行う。
library;

import 'package:terradart_google/cloud_run.dart';
import 'package:terradart_google/secret_manager.dart';
import 'package:terradart_google/storage.dart';

import 'env.dart';
import 'release.dart';
import 'runtime_env.dart';
import 'secrets.dart';

/// Job の種類。
enum ApiJob({
  required final String jobName,
  required final String command,

  /// 実行時に `--args` を渡さないときの引数。
  required final List<String> defaultArgs,

  /// seed の入力（非公開バケット）を [seedsMountPath] に読み取り専用でマウントするか。
  final bool mountsSeeds = false,
}) {
  /// migration Job の CLI（`api/bin/migrate.dart`、#34）。既定は未適用の migration の適用。
  /// 初回だけ `gcloud run jobs execute photohunt-migrate --args=init` で DB を作る。
  migrate(
    jobName: 'photohunt-migrate',
    command: '/app/migrate/bin/migrate',
    defaultArgs: ['apply'],
  ),

  /// 出題の登録・公開。引数は実行時に `--args` で渡す（例 `load,--dir,...,--publish,true`）。
  seed(
    jobName: 'photohunt-seed',
    command: '/app/scripts/seed.sh',
    defaultArgs: [],
    mountsSeeds: true,
  ),
}

/// タスク 1・並列 1・再試行 0・期限 15 分。所有権の衝突を再試行で隠さない。
GoogleCloudRunV2Job buildJob({
  required ApiJob job,
  required Env env,
  required Release release,
  required List<EnvVar> runtimeEnv,
  required Map<ServerpodSecret, GoogleSecretManagerSecret> secrets,

  /// seed の入力のバケット。[ApiJob.mountsSeeds] の Job だけがマウントする。
  required GoogleStorageBucket seeds,

  /// 起動に要る権限の付与（secret・DB バケット。seed は素材バケットと seed の入力も）。
  /// 付与の前に作ると、実行時に権限がない。
  required List<TfAddressed> dependsOn,
}) => GoogleCloudRunV2Job(
  job.name,
  dependsOn: dependsOn,
  name: .literal(job.jobName),
  location: .literal(env.region),
  deletionProtection: .literal(true),
  template: CloudRunV2JobTemplate(
    taskCount: .literal(1),
    parallelism: .literal(1),
    labels: .literal({'app': 'photohunt'}),
    template: CloudRunV2JobTemplateTemplate(
      serviceAccount: .literal(env.migrateServiceAccount),
      executionEnvironment: .gen2,
      maxRetries: .literal(0),
      timeout: .literal('900s'),
      // GCS のボリュームは gen2 の実行環境で使える（上の executionEnvironment）。
      volumes: job.mountsSeeds
          ? [
              .new(
                name: .literal('seeds'),
                source: .gcs(.new(bucket: seeds.ref, readOnly: .literal(true))),
              ),
            ]
          : null,
      containers: [
        .new(
          image: .literal(release.apiImage),
          command: .literal([job.command]),
          args: job.defaultArgs.isEmpty ? null : .literal(job.defaultArgs),
          resources: .new(limits: .literal({'cpu': '1', 'memory': '1Gi'})),
          volumeMounts: job.mountsSeeds
              ? [
                  .new(
                    name: .literal('seeds'),
                    mountPath: .literal(seedsMountPath),
                  ),
                ]
              : null,
          env: [
            for (final (:name, :value) in runtimeEnv)
              .new(name: .literal(name), source: .value(value)),
            for (final MapEntry(key: secret, value: resource)
                in secrets.entries)
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
  ),
  lifecycle: const .new(ignoreChanges: .of(['client', 'client_version'])),
);
