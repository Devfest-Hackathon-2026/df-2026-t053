/// 予算通知。Vertex AI の従量課金には上限がないため、通知を受けて人が
/// GUIDES_ENABLED=false にする（#78、docs/infrastructure.md 10）。
library;

import 'package:terradart_google/billing.dart';

/// このプロジェクトの費用だけを対象に、50%・90%・100% で課金アカウントの管理者へメールする。
GoogleBillingBudget buildBudget({
  required String billingAccount,
  required String projectNumber,
  required int monthlyJpy,

  /// Billing Budget API の有効化（bootstrap 自身が有効にする）。有効になる前に作ると失敗する。
  required List<TfAddressed> dependsOn,
}) => GoogleBillingBudget(
  'monthly',
  dependsOn: dependsOn,
  billingAccount: .literal(billingAccount),
  displayName: .literal('photohunt monthly'),
  amount: .specifiedAmount(
    .new(currencyCode: .literal('JPY'), units: .literal('$monthlyJpy')),
  ),
  budgetFilter: .new(projects: .literal(['projects/$projectNumber'])),
  thresholdRules: [
    for (final percent in const [0.5, 0.9, 1.0])
      BillingBudgetThresholdRules(thresholdPercent: .literal(percent)),
  ],
);
