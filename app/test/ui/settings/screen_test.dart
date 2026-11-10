import 'package:app/model/profile/model.dart';

import 'dart:async';

import 'package:app/provider/api_client/provider.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/settings/screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import 'support.dart';

Widget settings(
  TestProfiles profiles, {
  double textScale = 1,
  List<Credit> credits = const [],
}) => ProviderScope(
  overrides: [apiClientProvider.overrideWithValue(profiles.client)],
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: SettingsScreen(onClose: () {}, credits: credits),
  ),
);

void main() {
  testWidgets('受け取った出典名とHTTPSリンクを表示し、未確認の利用条件を補わない', (tester) async {
    await tester.pumpWidget(
      settings(
        TestProfiles(),
        credits: [
          Credit(name: '写真：テスト撮影者', url: 'https://example.com/photo'),
          Credit(name: '3Dモデル：テスト提供元'),
          Credit(name: '不正なURLの出典', url: 'javascript:alert(1)'),
          Credit(name: '認証付きURLの出典', url: 'https://secret@example.com/source'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('写真：テスト撮影者'), findsOneWidget);
    expect(find.text('https://example.com/photo'), findsOneWidget);
    expect(find.text('3Dモデル：テスト提供元'), findsOneWidget);
    expect(find.text('javascript:alert(1)'), findsNothing);
    expect(find.text('https://secret@example.com/source'), findsNothing);
    expect(find.textContaining('素材のクレジットと利用条件は確認中'), findsNothing);
    expect(find.byType(SelectableText), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('現在名を非同期表示し、保存応答まで成功を表示しない', (tester) async {
    final profiles = TestProfiles();
    final response = Completer<Profile>();
    profiles.save = (_) => response.future;
    await tester.pumpWidget(settings(profiles));
    await tester.pumpAndSettle();
    expect(find.text('旅人0042'), findsOneWidget);
    expect(find.text('出典・利用案内'), findsOneWidget);
    expect(find.textContaining('素材のクレジットと利用条件は確認中'), findsOneWidget);
    expect(find.text('ニックネーム（ランキングに公開されます）'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '　新しい旅人 ');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
    await tester.tap(find.widgetWithText(AppButton, '保存'));
    await tester.pump();
    expect(find.text('保存中…'), findsOneWidget);
    expect(find.text('保存しました'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    response.complete(Profile(nickname: '新しい旅人', anonymous: true));
    await tester.pumpAndSettle();
    expect(find.text('保存しました'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '新しい旅人',
    );
    expect(profiles.saves, ['新しい旅人']);
  });

  testWidgets('取得失敗の再読み込みと、保存失敗の入力保持・再試行', (tester) async {
    final profiles = TestProfiles()
      ..load = () async => throw const ProfileFailure(.unavailable);
    await tester.pumpWidget(settings(profiles));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.text('旅人4821'), findsNothing);
    profiles.load = () async => Profile(nickname: '現在の名前', anonymous: true);
    await tester.tap(find.widgetWithText(AppButton, '再読み込み'));
    await tester.pumpAndSettle();
    profiles.save = (_) async => throw const ProfileFailure(.unavailable);
    await tester.enterText(find.byType(TextField), '保存したい名前');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
    await tester.tap(find.widgetWithText(AppButton, '保存'));
    await tester.pumpAndSettle();
    expect(find.text('保存しました'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '保存したい名前',
    );
    expect(find.text('プロフィールを利用できません。時間をおいて再試行してください'), findsOneWidget);
    profiles.save = (name) async => Profile(nickname: name, anonymous: true);
    await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
    await tester.tap(find.widgetWithText(AppButton, '保存'));
    await tester.pumpAndSettle();
    expect(find.text('保存しました'), findsOneWidget);
    expect(profiles.saves, ['保存したい名前', '保存したい名前']);
  });

  testWidgets('型付きの入力エラーを欄に表示し、サーバーの内部説明を表示しない', (tester) async {
    final profiles = TestProfiles()
      ..save = (_) async => throw const ProfileFailure(
        .invalidNickname,
        nicknameReason: 'CONTROL_CHARACTER',
      );
    await tester.pumpWidget(settings(profiles));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '不正な入力');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
    await tester.tap(find.widgetWithText(AppButton, '保存'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
      '改行・制御文字・表示できない文字は使えません',
    );
    expect(find.text('保存しました'), findsNothing);
  });

  for (final size in [const Size(320, 640), const Size(800, 350)]) {
    testWidgets('文字2倍・長い名前でもスクロールして保存できる $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final profiles = TestProfiles();
      await tester.pumpWidget(
        settings(
          profiles,
          textScale: 2,
          credits: [
            Credit(
              name: '写真：${'あ' * 20}',
              url: 'https://example.com/${'source' * 20}',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), 'あ' * 20);
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
      await tester.tap(find.widgetWithText(AppButton, '保存'));
      await tester.pumpAndSettle();
      expect(profiles.saves, ['あ' * 20]);
      expect(find.text('保存しました'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
