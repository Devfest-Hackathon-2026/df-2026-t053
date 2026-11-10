import 'dart:io';

import 'package:photohunt_stack/api_service.dart';
import 'package:photohunt_stack/env.dart';
import 'package:photohunt_stack/jobs.dart';

/// `scripts/deploy.sh` が使う名前を `KEY=VALUE` で出す。名前の正本を `lib/` だけにするため。
///
///   eval "$(dart run bin/describe.dart prod)"
void main(List<String> args) {
  final env = args.isEmpty ? Env.prod : Env.values.byName(args.single);
  final values = {
    'GCP_PROJECT_ID': env.projectId,
    'GCP_REGION': env.region,
    'API_SERVICE': apiServiceName,
    'MIGRATE_JOB': ApiJob.migrate.jobName,
    'SEED_JOB': ApiJob.seed.jobName,
    'DB_BUCKET': env.dbBucket,
    'DB_WRITER_OWNER_OBJECT': dbWriterOwnerObject,
    'IMAGE_REPOSITORY': env.imageRepository,
  };
  for (final MapEntry(:key, :value) in values.entries) {
    if (!RegExp(r'^[A-Za-z0-9._/:@-]+$').hasMatch(value)) {
      throw StateError('$key に使えない文字がある: $value');
    }
    stdout.writeln('$key=$value');
  }
}
