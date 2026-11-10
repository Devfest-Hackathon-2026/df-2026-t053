import 'package:photohunt_bootstrap/env.dart';
import 'package:photohunt_bootstrap/stack.dart';
import 'package:test/test.dart';

void main() {
  final json = BootstrapStack(env: Env.prod).synth().tfJson;

  /// synth した JSON から、Terraform の型ごとの resource ブロックを取り出す。
  Map<String, Map<String, Object?>> blocks(String type) =>
      switch (json['resource']) {
        final Map<String, Object?> resources => switch (resources[type]) {
          final Map<String, Object?> byName => {
            for (final MapEntry(:key, :value) in byName.entries)
              if (value case final Map<String, Object?> block) key: block,
          },
          _ => throw StateError('resource $type がない'),
        },
        _ => throw StateError('resource がない'),
      };

  Iterable<Object?> projectRolesOf(String accountName) =>
      blocks('google_project_iam_member').values
          .where(
            (m) =>
                m['member'] == '\${google_service_account.$accountName.member}',
          )
          .map((m) => m['role']);

  test('tfstate バケットは非公開でバージョニングを有効にする', () {
    final bucket = blocks('google_storage_bucket')['tfstate'];
    expect(bucket?['public_access_prevention'], 'enforced');
    expect(bucket?['versioning'], {'enabled': true});
    expect(bucket?['force_destroy'], isFalse);
  });

  test('CI の SA に SA 作成・プロジェクト IAM・所有者の権限を与えない', () {
    for (final account in ['ciPlan', 'ciDeploy']) {
      expect(
        projectRolesOf(account),
        isNot(
          anyOf(
            contains('roles/owner'),
            contains('roles/editor'),
            contains('roles/resourcemanager.projectIamAdmin'),
            contains('roles/iam.serviceAccountAdmin'),
          ),
        ),
        reason: account,
      );
    }
  });

  test('CI の配備用 SA は、ログベースのアラートを作れる', () {
    expect(
      projectRolesOf('ciDeploy'),
      containsAll(['roles/monitoring.editor', 'roles/logging.configWriter']),
    );
  });

  test('Vertex AI の権限は API の実行 SA だけに付ける', () {
    final holders = blocks('google_project_iam_member').values
        .where((m) => m['role'] == 'roles/aiplatform.user')
        .map((m) => m['member']);
    expect(holders, ['\${google_service_account.api.member}']);
  });

  test('deploy の WIF は main の deploy.yml だけを通す', () {
    final providers = blocks('google_iam_workload_identity_pool_provider');
    final deploy = providers['wif_deploy_github']?['attribute_condition'];
    expect(
      deploy,
      contains("assertion.repository_id == '$githubRepositoryId'"),
    );
    expect(deploy, contains("assertion.ref == 'refs/heads/main'"));
    expect(deploy, contains('/$githubDeployWorkflow@'));
    final plan = providers['wif_plan_github']?['attribute_condition'];
    expect(plan, isNot(contains('refs/heads/main')));
  });

  test('pool ごとに 1 つの SA だけを借用させる', () {
    final bindings = blocks('google_service_account_iam_member').values
        .where((m) => m['role'] == 'roles/iam.workloadIdentityUser')
        .map((m) => (m['service_account_id'], m['member']))
        .toList();
    expect(bindings, hasLength(2));
    expect(
      bindings,
      contains((
        '\${google_service_account.ciDeploy.name}',
        'principalSet://iam.googleapis.com/\${google_iam_workload_identity_pool.wif_deploy.name}/*',
      )),
    );
    expect(
      bindings,
      contains((
        '\${google_service_account.ciPlan.name}',
        'principalSet://iam.googleapis.com/\${google_iam_workload_identity_pool.wif_plan.name}/*',
      )),
    );
  });

  test('予算はこのプロジェクトだけを対象に、50%・90%・100% で通知する', () {
    final budget = blocks('google_billing_budget')['monthly'];
    expect(
      budget?['depends_on'],
      contains('google_project_service.api_billingbudgets'),
    );
    expect(budget?['billing_account'], Env.prod.billingAccount);
    expect(budget?['amount'], {
      'specified_amount': {
        'currency_code': 'JPY',
        'units': '${Env.prod.monthlyBudgetJpy}',
      },
    });
    expect(budget?['budget_filter'], {
      'projects': ['projects/${Env.prod.projectNumber}'],
    });
    expect(budget?['threshold_rules'], [
      {'threshold_percent': 0.5},
      {'threshold_percent': 0.9},
      {'threshold_percent': 1.0},
    ]);
  });
}
