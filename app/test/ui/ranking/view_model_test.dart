import 'dart:async';

import 'package:app/model/exploration_mode.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/ui/ranking/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/ranking_client.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late TestRankings data;
  late ProviderContainer container;
  final provider = rankingViewModelProvider();
  RankingViewModel vm() => container.read(provider.notifier);
  void start() => container.listen(provider, (_, _) {});

  setUp(() {
    data = TestRankings();
    container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(data.client)],
    );
  });
  tearDown(() => container.dispose());

  test('公開中の版を使い、上位外の自己順位も別に取得する', () async {
    start();
    expect(container.read(provider).fetchedAt, isNull);
    expect(container.read(provider).entries, isEmpty);
    await flush();
    final state = container.read(provider);
    expect(state.revisionId, 7);
    expect(state.entries.single.rank, 1);
    expect(state.myEntry?.rank, 101);
    expect(vm().myRankLabel, '101 位 ／ 900点');
    expect(state.fetchedAt, isNotNull);
    expect(data.lists.single.revisionId, 7);
    expect(data.gets.single.mode, PlayMode.free);
    expect(() => state.entries.clear(), throwsUnsupportedError);
  });

  test('公開中の出題なしはランキングを呼ばず、再取得で回復できる', () async {
    data.challenges = () async => ListChallengesResponse(challenges: []);
    start();
    await flush();
    expect(container.read(provider).noPublishedChallenge, isTrue);
    expect(data.lists, isEmpty);
    data.challenges = () async => ListChallengesResponse(
      challenges: [Challenge(id: 1, title: '公開', currentRevisionId: 8)],
    );
    await vm().reload();
    expect(container.read(provider).noPublishedChallenge, isFalse);
    expect(container.read(provider).revisionId, 8);
  });

  test('公開中なのに版欠落・複数出題なら不整合として止める', () async {
    data.challenges = () async =>
        ListChallengesResponse(challenges: [Challenge(id: 1, title: '不正')]);
    start();
    await flush();
    expect(container.read(provider).errorMessage, isNotNull);
    expect(data.lists, isEmpty);
    data.challenges = () async => ListChallengesResponse(
      challenges: [
        Challenge(id: 1, title: '一', currentRevisionId: 1),
        Challenge(id: 2, title: '二', currentRevisionId: 2),
      ],
    );
    await vm().reload();
    expect(data.lists, isEmpty);
    expect(container.read(provider).errorMessage, isNotNull);
  });

  test('空一覧と本人未記録を正常表示する', () async {
    data.list = (_) async => ListRankingEntriesResponse(entries: []);
    data.mine = (_) async => throw noEntry();
    start();
    await flush();
    expect(container.read(provider).entries, isEmpty);
    expect(container.read(provider).errorMessage, isNull);
    expect(container.read(provider).fetchedAt, isNotNull);
    expect(vm().myRankLabel, '未記録');
  });

  test('更新失敗は取得時刻と前回の一覧・自己ベストを保ち、再試行で現在名へ更新する', () async {
    start();
    await flush();
    final previous = container.read(provider);
    data.mine = (_) async => throw TimeoutException('秘密');
    await vm().reload();
    final failed = container.read(provider);
    expect(failed.fetchedAt, previous.fetchedAt);
    expect(failed.myEntry?.rank, 101);
    expect(failed.errorMessage, isNot(contains('秘密')));
    data.mine = (_) async => entry(name: '更新された名前', rank: 103, mine: true);
    await vm().reload();
    expect(container.read(provider).myEntry?.nickname, '更新された名前');
    expect(container.read(provider).errorMessage, isNull);
  });

  test('モード切替で前の表示を消し、遅い旧応答を捨てる', () async {
    final old = Completer<ListRankingEntriesResponse>();
    data.list = (request) => request.mode == .free
        ? old.future
        : Future.value(
            ListRankingEntriesResponse(entries: [entry(name: 'near')]),
          );
    start();
    await flush();
    final pending = vm().switchMode(.near);
    expect(container.read(provider).fetchedAt, isNull);
    expect(container.read(provider).entries, isEmpty);
    await pending;
    old.complete(ListRankingEntriesResponse(entries: [entry(name: 'free')]));
    await flush();
    expect(container.read(provider).entries.single.nickname, 'near');
    expect(data.gets.map((r) => r.mode), [PlayMode.near]);
    expect(data.lists.map((r) => r.revisionId), [7, 7]);
  });

  test('指定した版・モードは公開中の版で上書きしない', () async {
    final previous = rankingViewModelProvider(
      revisionId: 3,
      initialMode: .near,
    );
    container.listen(previous, (_, _) {});
    await flush();
    expect(data.challengeCalls, 0);
    expect(data.lists.single.revisionId, 3);
    expect(data.gets.single.mode, PlayMode.near);
    expect(container.read(previous).revisionId, 3);
  });

  test('接続Clientのoverride後に旧利用者の応答を表示しない', () async {
    final old = Completer<ListRankingEntriesResponse>();
    data.list = (_) => old.future;
    start();
    await flush();
    final next = TestRankings()
      ..list = (_) async =>
          ListRankingEntriesResponse(entries: [entry(name: '新利用者')]);
    container.updateOverrides([
      apiClientProvider.overrideWithValue(next.client),
    ]);
    await flush();
    old.complete(ListRankingEntriesResponse(entries: [entry(name: '旧利用者')]));
    await flush();
    expect(container.read(provider).entries.single.nickname, '新利用者');
    expect(data.gets, isEmpty);
  });

  test('画面破棄後の応答から本人取得を続行しない', () async {
    final old = Completer<ListRankingEntriesResponse>();
    data.list = (_) => old.future;
    final subscription = container.listen(provider, (_, _) {});
    await flush();
    subscription.close();
    await container.pump();
    old.complete(ListRankingEntriesResponse(entries: [entry()]));
    await flush();
    expect(data.gets, isEmpty);
  });

  testWidgets('一時不可だけ最大3回再試行し、保守・通信切断は自動再試行しない', (tester) async {
    data.list = (_) async => throw ApiException(
      code: .unavailable,
      reason: 'TEMPORARILY_UNAVAILABLE',
      message: '秘密',
    );
    start();
    await tester.pump();
    for (final seconds in [2, 3, 5]) {
      await tester.pump(Duration(seconds: seconds));
    }
    expect(data.lists.length, 4);
    expect(container.read(provider).isLoading, isFalse);
    for (final error in [
      ApiException(code: .unavailable, reason: 'MAINTENANCE', message: '秘密'),
      ApiException(code: .unavailable, reason: 'SCHEMA_TOO_NEW', message: '秘密'),
      TimeoutException('秘密'),
    ]) {
      final before = data.lists.length;
      data.list = (_) async => throw error;
      final load = vm().reload();
      await tester.pump();
      await load;
      await tester.pump(const Duration(seconds: 8));
      expect(data.lists.length, before + 1);
    }
  });

  testWidgets('再試行待ち中のモード変更は旧要求の再送を止める', (tester) async {
    data.list = (r) async {
      if (r.mode == .free) {
        throw ApiException(
          code: .unavailable,
          reason: 'TEMPORARILY_UNAVAILABLE',
          message: '',
        );
      }
      return ListRankingEntriesResponse(entries: []);
    };
    start();
    await tester.pump();
    final changed = vm().switchMode(ExplorationMode.near);
    await tester.pump();
    await changed;
    await tester.pump(const Duration(seconds: 10));
    expect(data.lists.map((r) => r.mode), [PlayMode.free, PlayMode.near]);
  });
}
