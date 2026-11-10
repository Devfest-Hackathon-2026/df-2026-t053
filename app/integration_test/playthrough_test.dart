import 'dart:io';

import 'package:app/provider/photo/provider.dart';
import 'package:app/main.dart' as app;
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/exploration/screen.dart';
import 'package:app/ui/exploration/components/exploration_camera_drag_view.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/ui/mode_select/components/mode_card.dart';
import 'package:app/ui/mode_select/components/spot_select_panel.dart';
import 'package:app/ui/mode_select/screen.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:app/ui/result/screen.dart';
import 'package:app/ui/result/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

// 実APIへプレイと撮影記録を作る。ローカル環境だけを対象に実行する。
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets('両モードの開始・撮影・3D比較・再挑戦', (tester) async {
    const url = String.fromEnvironment('API_BASE_URL');
    final host = Uri.parse(url).host;
    expect(
      ['localhost', '127.0.0.1', '10.0.2.2'],
      contains(host),
      reason: '本番へテスト記録を作らないようローカルAPIを明示してください',
    );
    await app.main();
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ModeSelectScreen)),
    );
    await _until(
      tester,
      () => container.read(modeSelectViewModelProvider).boot == .ready,
    );
    for (final index in [0, 1]) {
      final card = find.byType(ModeCard).at(index);
      await _tap(tester, find.descendant(of: card, matching: find.text('開始')));
      await tester.pump();
      if (index == 0) {
        await _until(
          tester,
          () => find.byType(SpotSelectPanel).evaluate().isNotEmpty,
        );
        final entrances = find.descendant(
          of: find.byType(SpotSelectPanel),
          matching: find.byType(AppButton),
        );
        expect(entrances, findsWidgets);
        await _tap(tester, entrances.first);
      }
      await _until(
        tester,
        () =>
            find.byType(ModeSelectScreen).evaluate().isEmpty &&
            find.byType(ExplorationScreen).evaluate().isNotEmpty &&
            !container.read(explorationViewModelProvider).isLoading,
      );
      expect(container.read(explorationViewModelProvider).loadFailed, isFalse);
      // APIと素材がキャッシュ済みでも、pushの遷移中は前画面が入力を受ける。
      await tester.pump(const Duration(milliseconds: 400));
      await tester.drag(
        find.byType(ExplorationCameraDragView),
        const Offset(36, -18),
      );
      await tester.pump();
      await _tap(tester, find.byIcon(Icons.photo_camera));
      await _until(
        tester,
        () => find.byType(ResultScreen).evaluate().isNotEmpty,
      );
      expect(find.byType(ResultScreen), findsOneWidget);
      final firstResult = container.read(explorationViewModelProvider).result;
      if (firstResult == null) fail('撮影結果がない');
      final photo = container.read(cluePhotoProvider);
      final width = photo.width;
      final height = photo.height;
      if (width == null || height == null) fail('比較写真の寸法がない');
      final comparison = resultComparisonViewModelProvider(
        firstResult,
        width,
        height,
      );
      await _until(
        tester,
        () =>
            container.read(comparison).hasValue ||
            container.read(comparison).hasError,
      );
      expect(container.read(comparison).hasError, isFalse);
      final images = container.read(comparison).requireValue;
      expect(images.shot.width, greaterThan(0));
      expect(images.goal.width, greaterThan(0));
      for (final label in ['自分の撮影（3D）', 'お手本（3D）', '実写写真']) {
        expect(find.text(label), findsOneWidget);
      }
      if (index == 1) await _capture(binding, 'near-comparison');
      await _tap(tester, find.text('もう一度挑戦'));
      await _until(
        tester,
        () =>
            find.byType(ResultScreen).evaluate().isEmpty &&
            !container.read(explorationViewModelProvider).isLoading &&
            container.read(explorationViewModelProvider).panel == .none,
      );
      await _tap(tester, find.byIcon(Icons.photo_camera));
      await _until(
        tester,
        () => find.byType(ResultScreen).evaluate().isNotEmpty,
      );
      final secondResult = container.read(explorationViewModelProvider).result;
      if (secondResult == null) fail('再挑戦後の撮影結果がない');
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(secondResult.shot.id, isNot(firstResult.shot.id));
      await _tap(tester, find.text('モード選択'));
      await _until(
        tester,
        () =>
            find.byType(ModeSelectScreen).evaluate().isNotEmpty &&
            container.read(modeSelectViewModelProvider).boot == .ready,
      );
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}

Future<void> _until(WidgetTester tester, bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(seconds: 90));
  while (!ready()) {
    if (DateTime.now().isAfter(deadline)) fail('画面遷移が90秒以内に完了しない');
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  if (!const bool.fromEnvironment('CAPTURE_PLAYTHROUGH')) return;
  final bytes = await binding.takeScreenshot(name);
  final directory = Directory(
    '${Directory.systemTemp.path}/kasane-playthrough',
  );
  await directory.create(recursive: true);
  await File('${directory.path}/$name.png').writeAsBytes(bytes);
}
