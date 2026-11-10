/// 起動失敗・5xx の通知（docs/infrastructure.md 10）。
///
/// 外形監視（uptime check）は置かない。定期的な要求でインスタンスが常時起動し、
/// 最小 0 の構成と費用の前提が崩れるため。
library;

import 'package:terradart_google/monitoring.dart';

import 'api_service.dart';

GoogleMonitoringNotificationChannel buildEmailChannel(String email) =>
    GoogleMonitoringNotificationChannel(
      'email',
      displayName: .literal('photohunt 運用メール'),
      type: .literal('email'),
      labels: .literal({'email_address': email}),
    );

/// 単一 writer の異常は自動で復旧しないので、`start.sh` のログで人に知らせる。
const List<String> startupFailureMessages = [
  'writer 所有権を取得できないため起動しない',
  '復元に失敗した',
  'Litestream の同期機能が使えない',
  '所有権が残る',
];

GoogleMonitoringAlertPolicy buildStartupFailureAlert(
  GoogleMonitoringNotificationChannel channel,
) => GoogleMonitoringAlertPolicy(
  'startup_failure',
  displayName: .literal('photohunt-api 起動失敗・所有権の残留'),
  combiner: .or,
  severity: .critical,
  conditions: [
    MonitoringAlertPolicyConditions(
      displayName: .literal('start.sh が起動を止めた'),
      conditionMatchedLog: .new(
        filter: .literal(
          'resource.type="cloud_run_revision" '
          'AND resource.labels.service_name="$apiServiceName" '
          'AND (${startupFailureMessages.map((m) => 'textPayload:"$m"').join(' OR ')})',
        ),
      ),
    ),
  ],
  // ログ一致の条件は通知の頻度の上限が必須。
  alertStrategy: .new(
    notificationRateLimit: .new(period: .literal('300s')),
    autoClose: .literal('1800s'),
  ),
  documentation: .new(
    content: .literal(
      'infrastructure/terradart/README.md の runbook「所有権の残留」を確認する。'
      '空の DB で営業を再開しない。',
    ),
    mimeType: .literal('text/markdown'),
  ),
  notificationChannels: .literal([channel.name.interpolation]),
);

GoogleMonitoringAlertPolicy buildServerErrorAlert(
  GoogleMonitoringNotificationChannel channel,
) => GoogleMonitoringAlertPolicy(
  'server_errors',
  displayName: .literal('photohunt-api 5xx'),
  combiner: .or,
  severity: .error,
  conditions: [
    MonitoringAlertPolicyConditions(
      displayName: .literal('5 分間に 5xx が 5 件を超えた'),
      conditionThreshold: .new(
        filter: .literal(
          'resource.type="cloud_run_revision" '
          'AND resource.labels.service_name="$apiServiceName" '
          'AND metric.type="run.googleapis.com/request_count" '
          'AND metric.labels.response_code_class="5xx"',
        ),
        comparison: .greaterThan,
        thresholdValue: .literal(5),
        duration: .literal('0s'),
        aggregations: [
          .new(
            alignmentPeriod: .literal('300s'),
            perSeriesAligner: .sum,
            crossSeriesReducer: .sum,
          ),
        ],
      ),
    ),
  ],
  notificationChannels: .literal([channel.name.interpolation]),
);
