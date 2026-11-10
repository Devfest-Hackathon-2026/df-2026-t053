import 'dart:convert';
import 'dart:io';

import 'package:app/model/photo/model.dart';
import 'package:app/ui/exploration/components/exploration_panels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('写真パネルは代替文と写真全体を出し、失敗時にパスを漏らさない', (tester) async {
    // 1x1 の PNG。デコード待ちでテストを止めないよう、表示は Widget の組み立てだけ見る。
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    final prepared = await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'clue-photo-view-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/photo.png');
      await file.writeAsBytes(bytes);
      return (directory: directory, file: file);
    });
    if (prepared == null) fail('写真ファイルを準備できませんでした');
    final directory = prepared.directory;
    final file = prepared.file;
    const photo = CluePhotoState(
      phase: .ready,
      alt: '柱が並ぶ',
      width: 1,
      height: 1,
    );
    final ready = photo.copyWith(path: file.path);

    await tester.pumpWidget(
      MaterialApp(
        home: ExplorationPhotoPanel(photo: ready, onClose: () {}),
      ),
    );
    expect(find.text('お手本写真'), findsOneWidget);
    expect(find.text('柱が並ぶ'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.contain);

    await tester.pumpWidget(
      MaterialApp(
        home: ExplorationPhotoPanel(
          photo: ready.copyWith(phase: .failed, failure: .unavailable),
          onClose: () {},
        ),
      ),
    );
    // 取得失敗時は、保持していたパスを画面に出さず再試行を案内する。
    expect(find.text('写真を取得できませんでした。接続を確認して再度お試しください。'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.textContaining(directory.path), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: ExplorationPhotoPanel(photo: ready, onClose: () {}),
      ),
    );
    expect(find.text('柱が並ぶ'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
