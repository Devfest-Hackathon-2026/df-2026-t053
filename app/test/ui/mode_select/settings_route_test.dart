import 'package:app/model/challenge/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/router/router.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:app/ui/settings/screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/api_client.dart';
import '../../support/play.dart';

class _ReadySelection extends ModeSelectViewModel {
  @override
  ModeSelectState build() => const ModeSelectState(boot: .ready);
}

class _RevisionWithCredits extends ChallengeNotifier {
  @override
  ChallengeState build() => ChallengeState(
    challengeId: 1,
    revision: fakeRevision().copyWith(
      credits: [Credit(name: '撮影版の出典', url: 'https://example.com/source')],
    ),
  );
}

void main() {
  testWidgets('ホームから設定へ取得済みcreditsを渡し、同じClientでプロフィールを取得・保存する', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var loads = 0;
    final saves = <String>[];
    final client = TestApiClient(
      getProfile: (_) async {
        loads++;
        return Profile(nickname: '現在の旅人', anonymous: true);
      },
      setNickname: (r) async {
        saves.add(r.nickname);
        return Profile(nickname: r.nickname, anonymous: true);
      },
      refreshAuthentication: () async {},
    );
    router.go('/');
    addTearDown(() => router.go('/'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(client),
          challengeProvider.overrideWith(_RevisionWithCredits.new),
          modeSelectViewModelProvider.overrideWith(_ReadySelection.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('撮影版の出典'), findsOneWidget);
    expect(find.text('https://example.com/source'), findsOneWidget);
    expect(find.text('現在の旅人'), findsOneWidget);
    expect(loads, 1);
    await tester.enterText(find.byType(TextField), '変更後の旅人');
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(AppButton, '保存'));
    await tester.tap(find.widgetWithText(AppButton, '保存'));
    await tester.pumpAndSettle();
    expect(saves, ['変更後の旅人']);
    expect(find.text('保存しました'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
