/// サービスアカウント、プロジェクト単位の IAM、GitHub Actions 用の WIF。
///
/// SA の作成とプロジェクト単位の付与はこのパッケージだけで行う。stack はリソース単位の
/// 付与だけを行うので、CI 用の SA に SA 作成・プロジェクト IAM の権限は要らない
/// （docs/infrastructure.md 5.1・6）。
library;

import 'package:terradart_google/iam.dart';

import 'env.dart';

/// 作る SA。`accountId` は stack の `Env` が同じ規則でメールアドレスを組み立てる。
enum ServiceAccountRole(final String accountId, final String displayName) {
  /// PR の plan（読み取りだけ）。
  ciPlan('sa-ci-plan', 'GitHub Actions の plan（読み取りだけ）'),

  /// stack の plan・apply と配備。
  ciDeploy('sa-ci-deploy', 'GitHub Actions の stack 適用と配備'),

  /// Cloud Run サービス photohunt-api の実行。
  api('sa-api', 'Cloud Run photohunt-api の実行'),

  /// Cloud Run Job photohunt-migrate・photohunt-seed の実行。
  migrate('sa-migrate', 'Cloud Run Job migrate・seed の実行');

  /// プロジェクト単位で付与するロール。
  List<String> get projectRoles => switch (this) {
    ciPlan => const [
      'roles/viewer',
      'roles/iam.securityReviewer', // IAM の付与状況を plan で読む
    ],
    ciDeploy => const [
      'roles/run.admin',
      'roles/artifactregistry.admin',
      'roles/storage.admin',
      'roles/secretmanager.admin',
      'roles/monitoring.editor',
      // ログベースのアラート（起動失敗の通知）は、Logging の notification rule も作る。
      // roles/monitoring.editor には logging.notificationRules.create が含まれない。
      'roles/logging.configWriter',
    ],
    api => const [
      'roles/aiplatform.user', // Vertex AI（#78）。migrate には付けない
    ],
    migrate => const [],
  };
}

/// 作った SA。役割ごとに 1 つずつ持つ（欠けることがない）。
final class ServiceAccounts({
  required final GoogleServiceAccount ciPlan,
  required final GoogleServiceAccount ciDeploy,
  required final GoogleServiceAccount api,
  required final GoogleServiceAccount migrate,
}) {
  GoogleServiceAccount of(ServiceAccountRole role) => switch (role) {
    .ciPlan => ciPlan,
    .ciDeploy => ciDeploy,
    .api => api,
    .migrate => migrate,
  };
}

GoogleServiceAccount buildServiceAccount(
  ServiceAccountRole role,
  String projectId, {
  List<TfAddressed> dependsOn = const [],
}) => GoogleServiceAccount(
  role.name,
  dependsOn: dependsOn,
  project: .literal(projectId),
  accountId: .literal(role.accountId),
  displayName: .literal(role.displayName),
);

List<GoogleProjectIamMember> buildProjectIamMembers({
  required String projectId,
  required ServiceAccounts accounts,
}) => [
  for (final role in ServiceAccountRole.values)
    for (final r in role.projectRoles)
      GoogleProjectIamMember(
        '${role.name}_${_slug(r)}',
        project: .literal(projectId),
        role: .literal(r),
        member: accounts.of(role).principal,
      ),
];

/// ci-deploy が Cloud Run・Job に実行 SA を設定できるようにする（actAs）。
List<GoogleServiceAccountIamMember> buildActAsMembers(
  ServiceAccounts accounts,
) => [
  for (final runtime in [ServiceAccountRole.api, ServiceAccountRole.migrate])
    GoogleServiceAccountIamMember(
      'ci_deploy_act_as_${runtime.name}',
      serviceAccount: accounts.of(runtime).ref,
      role: .literal('roles/iam.serviceAccountUser'),
      member: accounts.ciDeploy.principal,
    ),
];

/// WIF の pool の用途。pool ごとに provider の条件が違う。
///
/// SA への workloadIdentityUser は pool 単位の principalSet になるので、条件の緩い
/// plan 用と、main の deploy.yml だけを通す deploy 用を別の pool にする（docs/infrastructure.md 6）。
enum WifPurpose({
  required final String poolId,
  required final ServiceAccountRole serviceAccount,
  required final String condition,
}) {
  plan(
    poolId: 'gh-plan',
    serviceAccount: .ciPlan,
    condition: "assertion.repository_id == '$githubRepositoryId'",
  ),
  deploy(
    poolId: 'gh-deploy',
    serviceAccount: .ciDeploy,
    condition:
        "assertion.repository_id == '$githubRepositoryId'"
        " && assertion.ref == 'refs/heads/main'"
        " && assertion.workflow_ref.startsWith("
        "'$githubRepositoryFullName/$githubDeployWorkflow@')",
  ),
}

GoogleIamWorkloadIdentityPool buildWifPool(
  WifPurpose purpose, {
  List<TfAddressed> dependsOn = const [],
}) => GoogleIamWorkloadIdentityPool(
  'wif_${purpose.name}',
  dependsOn: dependsOn,
  workloadIdentityPoolId: .literal(purpose.poolId),
  displayName: .literal('GitHub Actions ${purpose.name}'),
);

GoogleIamWorkloadIdentityPoolProvider buildWifProvider(
  WifPurpose purpose,
  GoogleIamWorkloadIdentityPool pool,
) => GoogleIamWorkloadIdentityPoolProvider(
  'wif_${purpose.name}_github',
  workloadIdentityPoolId: pool.ref,
  workloadIdentityPoolProviderId: .literal('github'),
  displayName: .literal('GitHub Actions'),
  attributeMapping: .literal({
    'google.subject': 'assertion.sub',
    'attribute.repository_id': 'assertion.repository_id',
    'attribute.ref': 'assertion.ref',
    'attribute.workflow_ref': 'assertion.workflow_ref',
  }),
  attributeCondition: .literal(purpose.condition),
  trustSource: const .oidc(
    .new(issuerUri: .literal('https://token.actions.githubusercontent.com')),
  ),
);

/// pool の全員（provider の条件を通った GitHub のジョブ）に SA の借用を許す。
GoogleServiceAccountIamMember buildWifBinding(
  WifPurpose purpose,
  GoogleIamWorkloadIdentityPool pool,
  GoogleServiceAccount serviceAccount,
) => GoogleServiceAccountIamMember(
  'wif_${purpose.name}_user',
  serviceAccount: serviceAccount.ref,
  role: .literal('roles/iam.workloadIdentityUser'),
  member: .principalSet(pool.ref, '*'),
);

String _slug(String role) =>
    role.replaceFirst('roles/', '').replaceAll(RegExp('[^A-Za-z0-9]'), '_');
