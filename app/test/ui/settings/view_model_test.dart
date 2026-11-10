import 'dart:async';

import 'package:app/model/profile/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/ui/settings/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import 'support.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late TestProfiles profiles;
  late ProviderContainer container;
  SettingsViewModel vm() => container.read(settingsViewModelProvider.notifier);
  SettingsState state() => container.read(settingsViewModelProvider);

  void start() => container.listen(settingsViewModelProvider, (_, _) {});

  setUp(() {
    profiles = TestProfiles();
    container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(profiles.client)],
    );
  });
  tearDown(() => container.dispose());

  test('取得中は架空の名前を出さず、取得した現在名を表示する', () async {
    start();
    expect(state().isLoading, isTrue);
    expect(state().nickname, isEmpty);
    expect(vm().canSave, isFalse);
    await flush();
    expect(state().nickname, '旅人0042');
    expect(state().profile?.nickname, '旅人0042');
    expect(vm().canSave, isFalse);
  });

  test('取得失敗のあと手動で再読み込みできる', () async {
    profiles.load = () async => throw const ProfileFailure(.unavailable);
    start();
    await flush();
    expect(state().errorMessage, isNotNull);
    expect(state().profile, isNull);
    profiles.load = () async => Profile(nickname: '復旧', anonymous: true);
    await vm().reload();
    expect(state().nickname, '復旧');
    expect(state().errorMessage, isNull);
    expect(profiles.loads, 2);
  });

  test('保存中は連打・編集を拒否し、応答後だけ保存済みを表示する', () async {
    start();
    await flush();
    final completer = Completer<Profile>();
    profiles.save = (_) => completer.future;
    vm().updateNickname('　新しい旅人 ');
    final pending = vm().save();
    expect(state().isSaving, isTrue);
    expect(state().saved, isFalse);
    await vm().save();
    vm().updateNickname('割り込み');
    expect(state().nickname, '　新しい旅人 ');
    expect(profiles.saves, ['新しい旅人']);
    completer.complete(Profile(nickname: '新しい旅人', anonymous: true));
    await pending;
    expect(state().nickname, '新しい旅人');
    expect(state().saved, isTrue);
    expect(vm().canSave, isFalse);
    vm().updateNickname('次の名前');
    expect(state().saved, isFalse);
  });

  test('保存失敗では現在名と入力を保持し、同じ内容を再試行できる', () async {
    start();
    await flush();
    profiles.save = (_) async => throw const ProfileFailure(.unavailable);
    vm().updateNickname('保存したい名前');
    await vm().save();
    expect(state().nickname, '保存したい名前');
    expect(state().profile?.nickname, '旅人0042');
    expect(state().saved, isFalse);
    expect(state().errorMessage, isNotNull);
    expect(vm().canSave, isTrue);
    profiles.save = (name) async => Profile(nickname: name, anonymous: true);
    await vm().save();
    expect(state().saved, isTrue);
    expect(state().errorMessage, isNull);
    expect(profiles.saves, ['保存したい名前', '保存したい名前']);
  });

  testWidgets('保存が10秒で失敗した後の旧成功応答は、再試行した新しい名前を上書きしない', (tester) async {
    start();
    await tester.pump();
    final old = Completer<Profile>();
    profiles.save = (_) => old.future;
    vm().updateNickname('期限切れの名前');
    final pending = vm().save();
    await tester.pump(const Duration(seconds: 10));
    await pending;
    expect(state().saved, isFalse);
    expect(state().isSaving, isFalse);
    expect(state().profile?.nickname, '旅人0042');
    expect(state().nickname, '期限切れの名前');
    expect(state().errorMessage, isNotNull);
    profiles.save = (name) async => Profile(nickname: name, anonymous: true);
    vm().updateNickname('新しく保存した名前');
    await vm().save();
    old.complete(Profile(nickname: '期限切れの名前', anonymous: true));
    await tester.pump();
    expect(state().nickname, '新しく保存した名前');
    expect(state().profile?.nickname, '新しく保存した名前');
    expect(state().saved, isTrue);
  });

  test('空白と21書記素を送らず、20個のZWJ絵文字は送信できる', () async {
    start();
    await flush();
    for (final name in ['　 ', 'あ' * 21]) {
      vm().updateNickname(name);
      await vm().save();
      expect(state().nicknameError, isNotNull);
      expect(profiles.saves, isEmpty);
    }
    final emojis = '👨‍👩‍👧‍👦' * 20;
    vm().updateNickname(emojis);
    await vm().save();
    expect(profiles.saves, [emojis]);
    expect(state().nicknameError, isNull);
  });

  test('サーバーの入力エラーを入力欄へ表示し、編集時に解除する', () async {
    start();
    await flush();
    profiles.save = (_) async => throw const ProfileFailure(
      .invalidNickname,
      nicknameReason: 'FORMAT_CHARACTER',
    );
    vm().updateNickname('不正な文字');
    await vm().save();
    expect(state().nicknameError, contains('制御文字'));
    expect(state().errorMessage, isNull);
    expect(state().saved, isFalse);
    vm().updateNickname('修正後');
    expect(state().nicknameError, isNull);
  });

  test('未知の失敗理由を生表示せず、ViewModelが安全な文言へ変換する', () async {
    start();
    await flush();
    profiles.save = (_) async =>
        throw const ProfileFailure(.invalidNickname, nicknameReason: '秘密の内部説明');
    vm().updateNickname('変更した名前');
    await vm().save();
    expect(state().nicknameError, 'ニックネームの長さ・文字を確認してください');
    expect(state().nicknameError, isNot(contains('秘密')));
    expect(state().saved, isFalse);
  });

  test('接続先の切替後に到着した旧取得応答を捨てる', () async {
    final oldResponse = Completer<Profile>();
    profiles.load = () => oldResponse.future;
    start();
    await flush();
    final next = TestProfiles()
      ..load = () async => Profile(nickname: '次の利用者', anonymous: true);
    container.updateOverrides([
      apiClientProvider.overrideWithValue(next.client),
    ]);
    await flush();
    expect(state().nickname, '次の利用者');
    oldResponse.complete(Profile(nickname: '古い利用者', anonymous: true));
    await flush();
    expect(state().nickname, '次の利用者');
  });

  test('破棄した画面の保存応答で再作成した画面を更新しない', () async {
    start();
    await flush();
    final response = Completer<Profile>();
    profiles.save = (_) => response.future;
    vm().updateNickname('古い保存');
    final pending = vm().save();
    container.invalidate(settingsViewModelProvider);
    await flush();
    expect(state().nickname, '旅人0042');
    response.complete(Profile(nickname: '古い保存', anonymous: true));
    await pending;
    expect(state().nickname, '旅人0042');
    expect(state().saved, isFalse);
  });

  test('認証接続の切替前に送った保存応答を新しい利用者へ反映しない', () async {
    start();
    await flush();
    final response = Completer<Profile>();
    profiles.save = (_) => response.future;
    vm().updateNickname('古い利用者の改名');
    final pending = vm().save();
    final next = TestProfiles()
      ..load = () async => Profile(nickname: '次の利用者', anonymous: true);
    container.updateOverrides([
      apiClientProvider.overrideWithValue(next.client),
    ]);
    await flush();
    response.complete(Profile(nickname: '古い利用者の改名', anonymous: true));
    await pending;
    expect(state().nickname, '次の利用者');
    expect(state().saved, isFalse);
    expect(next.saves, isEmpty);
  });
}
