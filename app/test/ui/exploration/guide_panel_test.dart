import 'package:app/model/guide/model.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/exploration/components/exploration_guide_panel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../provider/guide/support.dart';

void main() {
  for (final size in [
    const Size(1024, 768),
    const Size(844, 390),
    const Size(390, 844),
  ]) {
    testWidgets('右側パネル・ラベルなし・閉じる一つ $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var closed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExplorationGuidePanel(
              state: GuideState(text: textEvent(), phase: .ready),
              message: '',
              onPlayback: () {},
              onRegenerate: () {},
              onClose: () {
                closed++;
              },
            ),
          ),
        ),
      );
      expect(find.text('AI生成'), findsNothing);
      expect(find.text('この辺りの解説'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text('閉じる'), findsOneWidget);
      expect(find.text('大屋根リング'), findsOneWidget);
      final title = tester.getTopLeft(find.text('大屋根リング'));
      if (size.width >= 600) expect(title.dx, greaterThan(size.width * 0.4));
      await tester.tap(find.text('閉じる'));
      expect(closed, 1);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('準備中は再生不可、長文でも閉じるは常に見える', (tester) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExplorationGuidePanel(
            state: GuideState(
              text: textEvent(text: '長い解説文。' * 300),
              phase: .receiving,
            ),
            message: '音声を準備しています…',
            onPlayback: () {},
            onRegenerate: () {},
            onClose: () {},
          ),
        ),
      ),
    );
    final buttons = tester.widgetList<AppButton>(find.byType(AppButton));
    expect(buttons.singleWhere((b) => b.label == '音声を再生').onTap, isNull);
    expect(find.text('閉じる').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
