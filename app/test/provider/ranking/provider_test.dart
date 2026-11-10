import 'dart:async';

import 'package:app/model/ranking/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/ranking/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_client/serverpod_client.dart';

import '../../support/ranking_client.dart';

ApiException missingProfile() => ApiException(
  code: .failedPrecondition,
  reason: ApiErrorReasons.profileNotInitialized,
  message: '秘密',
);

void main() {
  late TestRankings data;
  late ProviderContainer container;
  final provider = rankingProvider(7, PlayMode.near);
  RankingNotifier notifier() => container.read(provider.notifier);

  setUp(() {
    data = TestRankings();
    container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(data.client)],
    );
    container.listen(provider, (_, _) {});
  });
  tearDown(() => container.dispose());

  for (final count in [0, 1, 100]) {
    test('一覧$count件を同じ版・モードの応答として受け取る', () async {
      data.list = (_) async => ListRankingEntriesResponse(
        entries: [for (var i = 0; i < count; i++) entry(rank: i + 1)],
      );
      final response = await notifier().listRankingEntries();
      expect(response.entries.length, count);
      expect(response.entries.map((e) => e.rank), [
        for (var i = 1; i <= count; i++) i,
      ]);
      expect(data.lists.single.revisionId, 7);
      expect(data.lists.single.mode, PlayMode.near);
    });
  }

  test('公開DTOをそのまま返し、一覧と本人取得は同じ版・モードを要求する', () async {
    final response = ListRankingEntriesResponse(entries: [entry()]);
    data.list = (_) async => response;
    expect(await notifier().listRankingEntries(), same(response));
    expect((await notifier().getMyRankingEntry())?.rank, 101);
    expect(data.lists.single.revisionId, 7);
    expect(data.lists.single.mode, PlayMode.near);
    expect(data.gets.single.revisionId, 7);
    expect(data.gets.single.mode, PlayMode.near);
  });

  test('本人未記録だけnullになり、版なし・未認証・未知の失敗を区別する', () async {
    data.mine = (_) async => throw noEntry();
    expect(await notifier().getMyRankingEntry(), isNull);
    final failures = <(Object, RankingFailureKind)>[
      (
        ApiException(
          code: .notFound,
          reason: ApiErrorReasons.revisionNotFound,
          message: '秘密',
        ),
        .revisionNotFound,
      ),
      (
        ApiException(code: .notFound, reason: 'UNKNOWN', message: '秘密'),
        .rejected,
      ),
      (ServerpodClientUnauthorized(), .authentication),
      (TimeoutException('秘密'), .unavailable),
      (StateError('秘密'), .rejected),
    ];
    for (final (error, kind) in failures) {
      data.mine = (_) async => throw error;
      await expectLater(
        notifier().getMyRankingEntry(),
        throwsA(isA<RankingFailure>().having((e) => e.kind, 'kind', kind)),
      );
    }
  });

  test('欠落プロフィールは一度だけ認証更新して同じ要求を再実行する', () async {
    data.list = (_) async {
      if (data.lists.length == 1) throw missingProfile();
      return ListRankingEntriesResponse(entries: []);
    };
    await notifier().listRankingEntries();
    expect(data.refreshes, 1);
    expect(data.forceRefreshes, [true]);
    expect(data.lists.map((r) => (r.revisionId, r.mode)), [
      (7, PlayMode.near),
      (7, PlayMode.near),
    ]);
    data.mine = (_) async => throw missingProfile();
    await expectLater(
      notifier().getMyRankingEntry(),
      throwsA(
        isA<RankingFailure>().having(
          (e) => e.kind,
          'kind',
          RankingFailureKind.authentication,
        ),
      ),
    );
    expect(data.gets.length, 2);
    expect(data.refreshes, 2);
  });

  test('認証更新中の破棄は旧要求の再送を止める', () async {
    final refresh = Completer<void>();
    data.refresh = () => refresh.future;
    data.list = (_) async => throw missingProfile();
    final pending = notifier().listRankingEntries();
    final check = expectLater(pending, throwsA(isA<RankingFailure>()));
    await Future<void>.delayed(Duration.zero);
    container.invalidate(provider);
    await container.pump();
    refresh.complete();
    await check;
    expect(data.lists.length, 1);
  });

  testWidgets('認証更新が10秒を超えたら、遅れて完了しても再送しない', (tester) async {
    final refresh = Completer<void>();
    data.refresh = () => refresh.future;
    data.list = (_) async => throw missingProfile();
    final pending = notifier().listRankingEntries();
    final check = expectLater(
      pending,
      throwsA(
        isA<RankingFailure>().having(
          (e) => e.kind,
          'kind',
          RankingFailureKind.unavailable,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    await check;
    refresh.complete();
    await tester.pump();
    expect(data.lists.length, 1);
  });
}
