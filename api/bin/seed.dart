import 'dart:io';

import 'package:photohunt_server/seed.dart';

/// 出題の seed を登録・公開する管理用 CLI（#26）。`api/scripts/seed.sh` が使う。
/// 使い方と終了コードは `lib/seed.dart` を参照。
Future<void> main(List<String> args) async {
  try {
    exit(await runSeed(args, Platform.environment));
  } on Object catch (e) {
    stderr.writeln('seed: $e');
    exit(1);
  }
}
