import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:app/ui/components/help_panel.dart';
import 'package:app/ui/components/preparing_overlay.dart';
import 'package:app/ui/mode_select/components/boot_overlay.dart';
import 'package:app/ui/mode_select/components/spot_select_panel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

void main() {
  testWidgets('横画面・文字2倍で説明・出題・準備・起動失敗を操作できる', (tester) async {
    tester.view.physicalSize = const Size(667, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget frame(Widget child) => MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(667, 320),
          padding: EdgeInsets.symmetric(horizontal: 24),
          textScaler: TextScaler.linear(2),
        ),
        child: Scaffold(body: child),
      ),
    );

    await tester.pumpWidget(
      frame(
        Center(
          child: AppDialog(
            title: '遊び方',
            onClose: () {},
            child: const HelpPanel(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('通信：', findRichText: true));
    expect(tester.takeException(), isNull);

    SpawnEntrance? selected;
    final west = SpawnEntrance(id: 8, label: '西ゲート');
    await tester.pumpWidget(
      frame(
        SpotSelectPanel(
          entrances: [
            SpawnEntrance(id: 7, label: '東ゲート'),
            west,
          ],
          onEntrance: (entrance) => selected = entrance,
          onClose: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('西ゲート'));
    await tester.tap(find.text('西ゲート'));
    expect(selected, west);
    expect(tester.takeException(), isNull);

    var cancelled = false;
    await tester.pumpWidget(
      frame(PreparingOverlay(progress: 0.5, onCancel: () => cancelled = true)),
    );
    await tester.pump();
    await tester.ensureVisible(find.text('キャンセル'));
    await tester.tap(find.text('キャンセル'));
    expect(cancelled, isTrue);
    expect(tester.takeException(), isNull);

    var retried = false;
    await tester.pumpWidget(
      frame(
        ModeSelectBootOverlay(
          failed: true,
          message: '接続に失敗しました。' * 10,
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(AppButton, '最初から読み直す'));
    await tester.tap(find.text('最初から読み直す'));
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });
}
