import 'dart:io';

import 'package:photohunt_stack/env.dart';
import 'package:photohunt_stack/release.dart';
import 'package:photohunt_stack/stack.dart';
import 'package:terradart_core/terradart_core.dart';

/// `tf-out/prod/main.tf.json` を書く。`terradart plan`・`apply` が最初に実行する。
///
/// 配備のたびに変わる値は Terraform 変数にせず、環境変数 `API_IMAGE`・`RELEASE_ID`・
/// `MAINTENANCE_MODE` から読む（docs/infrastructure.md 5.3）。
/// `PHOTOHUNT_SYNTH_PLACEHOLDER=1` は資格情報なしの検査（`mise //infrastructure/terradart:test`）
/// だけが使い、存在しない image を指す。plan・apply のタスクは必ず空にする。
Future<void> main(List<String> args) => runEnvironments(
  args,
  Env.values,
  (env) => PhotohuntStack(env: env, release: _release(env)),
);

Release _release(Env env) {
  final environment = Platform.environment;
  if (environment['PHOTOHUNT_SYNTH_PLACEHOLDER'] == '1') {
    return Release.placeholder(env);
  }
  try {
    return Release.fromEnvironment(environment, env);
  } on ReleaseException catch (e) {
    stderr.writeln('error: $e');
    exit(64);
  }
}
