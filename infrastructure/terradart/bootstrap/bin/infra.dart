import 'package:photohunt_bootstrap/env.dart';
import 'package:photohunt_bootstrap/stack.dart';
import 'package:terradart_core/terradart_core.dart';

/// `tf-out/prod/main.tf.json` を書く。`terradart plan`・`apply` が最初に実行する。
Future<void> main(List<String> args) =>
    runEnvironments(args, Env.values, (env) => BootstrapStack(env: env));
