import 'dart:io';

import 'package:photohunt_server/migrate.dart';

/// migration Job の CLI（#34）。使い方と終了コードは `lib/migrate.dart` を参照。
Future<void> main(List<String> args) async {
  try {
    exit(await runMigrate(args, Platform.environment));
  } on Object catch (e) {
    stderr.writeln('migrate: $e');
    exit(1);
  }
}
