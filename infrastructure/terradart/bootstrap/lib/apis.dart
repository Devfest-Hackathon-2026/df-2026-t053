/// 有効にする API。
library;

import 'package:terradart_google/project.dart';

/// bootstrap と stack が使う API。stack の CI 用 SA には API を有効にする権限を与えないため、
/// ここでまとめて有効にする。
const List<String> requiredServices = [
  'aiplatform.googleapis.com', // Vertex AI（#78）
  'artifactregistry.googleapis.com',
  'billingbudgets.googleapis.com',
  'cloudresourcemanager.googleapis.com',
  'iam.googleapis.com',
  'iamcredentials.googleapis.com', // WIF からの SA 借用
  'logging.googleapis.com',
  'monitoring.googleapis.com',
  'run.googleapis.com',
  'secretmanager.googleapis.com',
  'serviceusage.googleapis.com',
  'storage.googleapis.com',
  'sts.googleapis.com', // WIF のトークン交換
];

/// [requiredServices] を有効にする resource。destroy しても API は止めない。
List<GoogleProjectService> buildProjectServices(String projectId) => [
  for (final service in requiredServices)
    GoogleProjectService(
      'api_${service.split('.').first}',
      project: .literal(projectId),
      service: .literal(service),
      disableOnDestroy: .literal(false),
    ),
];
