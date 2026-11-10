import 'dart:io';

import 'package:photohunt_server/ops.dart';

/// 運用用 CLI。`api/scripts/start.sh` と migration Job（#34）・seed（#26）が使う。
/// 使い方と終了コードは `lib/ops.dart` を参照。
Future<void> main(List<String> args) async {
  try {
    exit(await runOps(args, Platform.environment));
  } on Object catch (e) {
    stderr.writeln('ops: $e');
    exit(1);
  }
}
