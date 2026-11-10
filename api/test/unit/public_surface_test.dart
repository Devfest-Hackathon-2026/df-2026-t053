import 'dart:io';

import 'package:test/test.dart';

/// DB の行（`*Row`、serverOnly）は生成 client に出ない。
/// endpoint から行を直接返す経路がないことの確認。
void main() {
  test('生成 client の protocol に DB の行の型がない', () {
    final protocol = File('client/lib/src/protocol/protocol.dart');
    final source = protocol.readAsStringSync();
    expect(source, isNot(matches(RegExp(r'\b\w+Row\b'))));
    for (final table in ['challenge', 'shot', 'best_score', 'play_session']) {
      expect(source, isNot(contains("'$table'")));
    }
  });

  test('すべてのテーブルが serverOnly: true で定義されている', () {
    final dir = Directory('lib/src/infrastructure/database/tables');
    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.spy.yaml'),
    );
    expect(files, hasLength(14));
    for (final f in files) {
      final text = f.readAsStringSync();
      expect(text, contains('\nserverOnly: true\n'), reason: f.path);
      expect(text, contains('\ntable: '), reason: f.path);
    }
  });
}
