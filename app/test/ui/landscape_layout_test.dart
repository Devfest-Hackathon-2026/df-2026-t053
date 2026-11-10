import 'package:app/ui/mode_select/screen.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:app/ui/result/screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../support/play.dart';

class _ReadySelection extends ModeSelectViewModel {
  @override
  ModeSelectState build() => const ModeSelectState(boot: .ready);
}

Widget _app({
  required Widget home,
  required double textScale,
  List overrides = const [],
}) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  ),
);

void main() {
  const sizes = [Size(667, 375), Size(844, 390)];
  const textScales = [1.0, 1.5, 2.0];

  for (final size in sizes) {
    for (final textScale in textScales) {
      final label =
          '${size.width.toInt()}x${size.height.toInt()}・文字$textScale倍';

      testWidgets('結果画面は横画面（$label）でも表示が溢れない', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _app(
            textScale: textScale,
            home: ResultScreen(
              mode: .free,
              result: fakeSubmitShotResponse(score: 1000),
              onRetry: () {},
              onModeSelect: () {},
              onRanking: () {},
              onClose: () {},
            ),
          ),
        );
        await tester.pump();

        if (textScale == 1) {
          expect(find.byType(Scrollable), findsNothing);
          for (final label in [
            '1000',
            'お手本との距離',
            '向きのずれ（左右）',
            '向きのずれ（上下）',
            '撮影時の順位',
            'ランキング',
            'モード選択',
            'もう一度挑戦',
          ]) {
            final rect = tester.getRect(find.text(label));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.top, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(size.width));
            expect(rect.bottom, lessThanOrEqualTo(size.height));
          }
          for (final text in find.byType(RichText).evaluate()) {
            final rect = tester.getRect(find.byWidget(text.widget));
            expect(rect.bottom, lessThanOrEqualTo(size.height));
          }
        }

        expect(tester.takeException(), isNull);
      });

      testWidgets('モード選択画面は横画面（$label）でも表示が溢れない', (tester) async {
        var rankingsOpened = 0;
        var settingsOpened = 0;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _app(
            textScale: textScale,
            overrides: [
              modeSelectViewModelProvider.overrideWith(_ReadySelection.new),
            ],
            home: ModeSelectScreen(
              onStartPlay: (_, _) {},
              onOpenRanking: () => rankingsOpened++,
              onOpenSettings: () => settingsOpened++,
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        await tester.tap(find.text('ランキング'));
        await tester.tap(find.text('設定'));
        expect(rankingsOpened, 1);
        expect(settingsOpened, 1);
        await tester.tap(find.text('遊び方'));
        await tester.pump();
        expect(find.text('遊び方'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
