/// 万博フォトハントの GCP 初期設定。インフラ担当が手元から適用する（CI からは適用しない）。
///
/// 部品のファイルは resource を返す関数だけを持ち、`add(...)` はこのファイルだけが呼ぶ。
library;

import 'package:terradart_google/provider.dart';
import 'package:terradart_google/iam.dart';
import 'package:terradart_google/storage.dart';

import 'apis.dart';
import 'budget.dart';
import 'env.dart';
import 'identity.dart';
import 'state_bucket.dart';

final class BootstrapStack({required Env env}) extends Stack {
  this
    : super(
        providers: [
          GoogleProvider(
            project: env.projectId,
            region: env.region,
            // 予算 API は利用者の ADC だと quota project が要る。請求先は mise の apply タスクが
            // GOOGLE_BILLING_PROJECT で渡す（provider がこの環境変数を読む）。
            userProjectOverride: true,
          ),
        ],
        backend: switch (env.stateBucket) {
          final bucket? => GcsBackend(
            bucket: bucket,
            prefix: 'bootstrap/${env.name}',
          ),
          null => const LocalBackend(),
        },
      ) {
    // ===== API ==============================================================
    final apis = [
      for (final service in buildProjectServices(env.projectId)) add(service),
    ];

    // ===== tfstate ==========================================================
    final stateBucket = add(
      buildStateBucket(
        name: env.tfstateBucketName,
        location: env.region,
        dependsOn: apis,
      ),
    );

    // ===== SA とプロジェクト単位の IAM ======================================
    GoogleServiceAccount account(ServiceAccountRole role) =>
        add(buildServiceAccount(role, env.projectId, dependsOn: apis));
    final accounts = ServiceAccounts(
      ciPlan: account(.ciPlan),
      ciDeploy: account(.ciDeploy),
      api: account(.api),
      migrate: account(.migrate),
    );
    buildProjectIamMembers(
      projectId: env.projectId,
      accounts: accounts,
    ).forEach(add);
    buildActAsMembers(accounts).forEach(add);

    // plan 用 SA は state を読むだけ。apply 用 SA は storage.admin で読み書きできる。
    add(
      GoogleStorageBucketIamMember(
        'tfstate_ci_plan_viewer',
        bucket: stateBucket.ref,
        role: .literal('roles/storage.objectViewer'),
        member: accounts.ciPlan.principal,
      ),
    );

    // ===== GitHub Actions の WIF ============================================
    for (final purpose in WifPurpose.values) {
      final pool = add(buildWifPool(purpose, dependsOn: apis));
      final provider = add(buildWifProvider(purpose, pool));
      add(buildWifBinding(purpose, pool, accounts.of(purpose.serviceAccount)));
      addOutput('wif_${purpose.name}_provider', provider.name);
    }

    // ===== 予算 =============================================================
    if (env.billingAccount case final billingAccount?) {
      add(
        buildBudget(
          billingAccount: billingAccount,
          projectNumber: env.projectNumber,
          monthlyJpy: env.monthlyBudgetJpy,
          dependsOn: apis,
        ),
      );
    }

    // ===== 出力（GitHub の Variables と stack の Env に写す値）==============
    addOutput('tfstate_bucket', stateBucket.name);
    for (final role in ServiceAccountRole.values) {
      addOutput('sa_${role.name}_email', accounts.of(role).email);
    }
  }
}
