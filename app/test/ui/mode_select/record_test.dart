import 'dart:async';

import 'package:app/model/auth/model.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/model/play/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/play/provider.dart';
import 'package:app/ui/mode_select/components/mode_record_summary.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/play.dart';
import '../../support/ranking_client.dart';

class _Auth extends AuthNotifier {
  @override
  AuthState build() => AuthState(status: .signedIn, authUserId: testAuthUserId);
  void clear() => state = const AuthState();
}

class _Challenge extends ChallengeNotifier {
  @override
  ChallengeState build() => ChallengeState(revision: fakeRevision(id: 7));
  void change(int id) => state = ChallengeState(revision: fakeRevision(id: id));
}

class _Play extends PlayNotifier {
  @override
  PlayState build() => const PlayState();
  void finish() =>
      state = PlayState(phase: .completed, result: fakeSubmitShotResponse());
}

void main() {
  late TestRankings data;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<String>> listener;
  final provider = modeRecordViewModelProvider(PlayMode.free);

  setUp(() {
    data = TestRankings();
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(data.client),
        authProvider.overrideWith(_Auth.new),
        challengeProvider.overrideWith(_Challenge.new),
        playProvider.overrideWith(_Play.new),
      ],
    );
    listener = container.listen(provider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test('自己順位101位も取得し、版とモードを固定する', () async {
    expect(await container.read(provider.future), '自己ベスト 900点 ／ 101位');
    expect(data.gets.single.revisionId, 7);
    expect(data.gets.single.mode, PlayMode.free);
    expect(data.lists, isEmpty);
  });

  test('未記録と通信失敗を分け、再試行で回復する', () async {
    await container.read(provider.future);
    data.mine = (_) async => throw noEntry();
    container.read(provider.notifier).reload();
    expect(await container.read(provider.future), '未記録');
    data.mine = (_) async => throw TimeoutException('非公開情報');
    container.read(provider.notifier).reload();
    await expectLater(container.read(provider.future), throwsA(anything));
    expect(container.read(provider.notifier).label, '記録を取得できませんでした');
    data.mine = (_) async => entry(score: 800, rank: 3);
    container.read(provider.notifier).reload();
    expect(await container.read(provider.future), '自己ベスト 800点 ／ 3位');
  });

  test('版変更後に古い応答が届いても上書きしない', () async {
    await container.read(provider.future);
    final old = Completer<RankingEntry>();
    data.mine = (request) => request.revisionId == 7
        ? old.future
        : Future.value(entry(score: 700, rank: 2));
    container.read(provider.notifier).reload();
    await container.pump();
    final challenge = container.read(challengeProvider.notifier);
    if (challenge is! _Challenge) fail('出題overrideが適用されていません');
    challenge.change(8);
    expect(await container.read(provider.future), '自己ベスト 700点 ／ 2位');
    old.complete(entry(score: 1000));
    await container.pump();
    expect(container.read(provider.notifier).label, '自己ベスト 700点 ／ 2位');
  });

  test('認証解除で他人の記録を残さず、RPCも送らない', () async {
    await container.read(provider.future);
    final auth = container.read(authProvider.notifier);
    if (auth is! _Auth) fail('認証overrideが適用されていません');
    auth.clear();
    expect(await container.read(provider.future), '記録を確認する準備中です');
    expect(data.gets, hasLength(1));
  });

  test('撮影結果の更新で最新自己順位を再取得する', () async {
    await container.read(provider.future);
    data.mine = (_) async => entry(score: 950, rank: 1);
    final play = container.read(playProvider.notifier);
    if (play is! _Play) fail('プレイoverrideが適用されていません');
    play.finish();
    expect(await container.read(provider.future), '自己ベスト 950点 ／ 1位');
    expect(data.gets, hasLength(2));
  });

  test('Client overrideで再取得し、古い応答を採用しない', () async {
    await container.read(provider.future);
    final old = Completer<RankingEntry>();
    data.mine = (_) => old.future;
    container.read(provider.notifier).reload();
    await container.pump();
    final next = TestRankings()..mine = (_) async => entry(score: 600, rank: 4);
    container.updateOverrides([
      apiClientProvider.overrideWithValue(next.client),
      authProvider.overrideWith(_Auth.new),
      challengeProvider.overrideWith(_Challenge.new),
      playProvider.overrideWith(_Play.new),
    ]);
    expect(await container.read(provider.future), '自己ベスト 600点 ／ 4位');
    old.complete(entry(score: 1000));
    await container.pump();
    expect(container.read(provider.notifier).label, '自己ベスト 600点 ／ 4位');
  });

  test('表示を破棄した後の応答でProviderが復活しない', () async {
    await container.read(provider.future);
    final pending = Completer<RankingEntry>();
    data.mine = (_) => pending.future;
    container.read(provider.notifier).reload();
    await container.pump();
    expect(container.read(provider.notifier).label, '記録を確認しています');
    listener.close();
    await container.pump();
    pending.complete(entry());
    await container.pump();
    expect(container.read(provider.exists), isFalse);
  });

  testWidgets('カード用表示はモード別に記録と未記録を表示する', (tester) async {
    data.mine = (request) async {
      if (request.mode == .near) throw noEntry();
      return entry(score: 950, rank: 101);
    };
    container.read(provider.notifier).reload();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ModeRecordSummary(mode: .free),
                ModeRecordSummary(mode: .near),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('自己ベスト 950点 ／ 101位'), findsOneWidget);
    expect(find.text('未記録'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
