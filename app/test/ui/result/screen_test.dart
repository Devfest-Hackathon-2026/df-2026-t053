import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/result/screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/play.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('小さい横画面・文字倍率$scaleで結果をスクロールし全操作に到達する', (tester) async {
      tester.view.physicalSize = const Size(667, 375);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final actions = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(667, 375),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                textScaler: TextScaler.linear(scale),
              ),
              child: ResultScreen(
                mode: .free,
                result: SubmitShotResponse(
                  shot: fakeShot(),
                  reveal: fakeReveal().copyWith(story: '撮影者のエピソード。' * 50),
                  myRankingEntry: fakeRankingEntry(),
                ),
                onRetry: () => actions.add('retry'),
                onModeSelect: () => actions.add('select'),
                onRanking: () => actions.add('ranking'),
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['ランキング', 'モード選択', 'もう一度挑戦']) {
        final button = find.widgetWithText(AppButton, label);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        final rect = tester.getRect(button);
        expect(rect.left, greaterThanOrEqualTo(24));
        expect(rect.right, lessThanOrEqualTo(643));
        await tester.tap(button);
      }
      expect(actions, ['ranking', 'select', 'retry']);
      expect(tester.takeException(), isNull);
    });
  }
}
