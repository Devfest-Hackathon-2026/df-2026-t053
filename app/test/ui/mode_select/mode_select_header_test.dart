import 'package:app/ui/components/app_icon_button.dart';
import 'package:app/ui/mode_select/components/mode_select_header.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _nickname = '旅人4821';

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  required double textScale,
}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child ?? const SizedBox.shrink(),
      ),
      // 画面と同じく、ヘッダーには横幅いっぱい（左右 18 の余白を除く）を渡す。
      home: Scaffold(
        body: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ModeSelectHeader(
                nickname: _nickname,
                onHelp: () {},
                onRanking: () {},
                onSettings: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Rect _button(WidgetTester tester, String label) => tester.getRect(
  find.ancestor(of: find.text(label), matching: find.byType(AppIconButton)),
);

Rect _chip(WidgetTester tester) => tester.getRect(
  find
      .ancestor(of: find.text(_nickname), matching: find.byType(Container))
      .first,
);

void main() {
  testWidgets('通常の幅では、タイトルは左、名前と操作は右に間を空けずにまとまる', (tester) async {
    await _pump(tester, width: 844, textScale: 1);
    expect(tester.takeException(), isNull);

    final header = tester.getRect(find.byType(ModeSelectHeader));
    final title = tester.getRect(find.text('かさね旅'));
    final chip = _chip(tester);
    final help = _button(tester, '遊び方');
    final ranking = _button(tester, 'ランキング');
    final settings = _button(tester, '設定');

    expect(title.left, header.left);
    expect(settings.right, moreOrLessEquals(header.right));
    // 等間隔に散らばらず、Wrap の間隔（8）で隣り合う。
    expect(help.left - chip.right, moreOrLessEquals(8));
    expect(ranking.left - help.right, moreOrLessEquals(8));
    expect(settings.left - ranking.right, moreOrLessEquals(8));
    // 1 行に収まる。
    for (final rect in [chip, help, ranking]) {
      expect(rect.center.dy, moreOrLessEquals(settings.center.dy));
    }
  });

  for (final width in [667.0, 844.0]) {
    testWidgets('横画面（幅$width・文字2倍）でも、右寄せで折り返してタイトルに重ならない', (tester) async {
      await _pump(tester, width: width, textScale: 2);
      expect(tester.takeException(), isNull);

      final header = tester.getRect(find.byType(ModeSelectHeader));
      final title = tester.getRect(find.text('かさね旅'));
      final controls = [
        _chip(tester),
        for (final label in ['遊び方', 'ランキング', '設定']) _button(tester, label),
      ];
      for (final rect in controls) {
        expect(rect.left, greaterThanOrEqualTo(title.right));
        expect(rect.right, lessThanOrEqualTo(header.right + 0.5));
      }
      // 最後の操作は右端に揃う（折り返した行でも左へ散らない）。
      expect(controls.last.right, moreOrLessEquals(header.right));
    });
  }
}
