import 'dart:async';

import 'package:app/provider/api_client/provider.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/ranking/screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/ranking_client.dart';

Widget ranking(
  TestRankings data, {
  double textScale = 1,
  int? revisionId,
  VoidCallback? onClose,
}) => ProviderScope(
  overrides: [apiClientProvider.overrideWithValue(data.client)],
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child ?? const SizedBox.shrink(),
    ),
    home: RankingScreen(revisionId: revisionId, onClose: onClose ?? () {}),
  ),
);

void main() {
  testWidgets('読み込み中は仮順位を表示せず、取得後に版・最新順位・取得時刻を表示する', (tester) async {
    final data = TestRankings();
    final response = Completer<ListRankingEntriesResponse>();
    data.list = (_) => response.future;
    await tester.pumpWidget(ranking(data));
    await tester.pump();
    expect(find.text('ランキングを取得中…'), findsOneWidget);
    expect(find.text('未記録'), findsNothing);
    expect(find.textContaining('842'), findsNothing);
    response.complete(ListRankingEntriesResponse(entries: [entry()]));
    await tester.pumpAndSettle();
    expect(find.text('広場 ／ 出題版 7'), findsOneWidget);
    expect(find.text('最新の順位（取得時点）'), findsOneWidget);
    expect(find.textContaining('取得時刻：'), findsOneWidget);
    expect(find.text('101 位 ／ 900点'), findsOneWidget);
    expect(find.textContaining('101位以下は一覧に表示されません'), findsOneWidget);
  });

  testWidgets('失敗を再試行して空一覧・本人未記録を表示する', (tester) async {
    final data = TestRankings()
      ..list = (_) async => throw TimeoutException('非公開の値');
    await tester.pumpWidget(ranking(data));
    await tester.pumpAndSettle();
    expect(find.textContaining('非公開'), findsNothing);
    expect(find.text('未記録'), findsNothing);
    data.list = (_) async => ListRankingEntriesResponse(entries: []);
    data.mine = (_) async => throw noEntry();
    await tester.tap(find.widgetWithText(AppButton, '再試行'));
    await tester.pumpAndSettle();
    expect(find.text('未記録'), findsOneWidget);
    expect(find.text('この出題版・モードのランキングはまだありません'), findsOneWidget);
  });

  testWidgets('画面の版変更後に旧版の応答を表示しない', (tester) async {
    final data = TestRankings();
    final old = Completer<ListRankingEntriesResponse>();
    data.list = (r) => r.revisionId == 3
        ? old.future
        : Future.value(
            ListRankingEntriesResponse(entries: [entry(name: '新しい版')]),
          );
    await tester.pumpWidget(ranking(data, revisionId: 3));
    await tester.pump();
    await tester.pumpWidget(ranking(data, revisionId: 4));
    await tester.pumpAndSettle();
    old.complete(ListRankingEntriesResponse(entries: [entry(name: '古い版')]));
    await tester.pumpAndSettle();
    expect(find.text('出題版 4'), findsOneWidget);
    expect(find.text('新しい版'), findsOneWidget);
    expect(find.text('古い版'), findsNothing);
    expect(data.gets.map((r) => r.revisionId), [4]);
  });

  for (final size in [const Size(320, 640), const Size(800, 350)]) {
    testWidgets('文字2倍・長い名前・100件でも縦横で戻る／更新／末尾へ操作できる $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final data = TestRankings()
        ..list = (_) async => ListRankingEntriesResponse(
          entries: [
            for (var i = 1; i <= 100; i++)
              entry(rank: i, name: 'あ' * 20, mine: i == 1),
          ],
        );
      var closed = false;
      await tester.pumpWidget(
        ranking(data, textScale: 2, onClose: () => closed = true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('100 位'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.widgetWithText(AppButton, '更新'));
      await tester.tap(find.widgetWithText(AppButton, '更新'));
      await tester.pumpAndSettle();
      expect(data.lists.length, 2);
      await tester.tap(find.bySemanticsLabel('戻る'));
      expect(closed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
