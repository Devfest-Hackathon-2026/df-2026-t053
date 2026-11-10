import 'dart:async';

import 'package:app/model/challenge/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/api_client.dart';
import '../../support/play.dart';

void main() {
  ProviderContainer containerWith(TestApiClient client) {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    return container;
  }

  TestApiClient clientWith({
    Future<ListChallengesResponse> Function(ListChallengesRequest)?
    listChallenges,
    Future<Challenge> Function(GetChallengeRequest)? getChallenge,
    Future<ChallengeRevision> Function(GetChallengeRevisionRequest)?
    getChallengeRevision,
  }) => TestApiClient(
    getProfile: (_) async => throw StateError('未設定'),
    setNickname: (_) async => throw StateError('未設定'),
    refreshAuthentication: () async {},
    listChallenges: listChallenges,
    getChallenge: getChallenge,
    getChallengeRevision: getChallengeRevision,
  );

  Challenge challenge({int? currentRevisionId = 1}) =>
      Challenge(id: 1, title: '万博フォトハント', currentRevisionId: currentRevisionId);

  test('公開出題から現在の不変版を取得して保持する', () async {
    final container = containerWith(
      clientWith(
        listChallenges: (_) async =>
            ListChallengesResponse(challenges: [challenge()]),
        getChallenge: (request) async {
          expect(request.challengeId, 1);
          return challenge();
        },
        getChallengeRevision: (request) async {
          expect(request.revisionId, 1);
          return fakeRevision();
        },
      ),
    );
    final revision = await container
        .read(challengeProvider.notifier)
        .loadCurrent();
    expect(revision.id, 1);
    expect(container.read(challengeProvider).challengeId, 1);
    expect(container.read(challengeProvider.notifier).currentRevision.id, 1);
  });

  test('公開出題がなければ notFound で失敗する', () async {
    final container = containerWith(
      clientWith(
        listChallenges: (_) async =>
            ListChallengesResponse(challenges: const []),
      ),
    );
    await expectLater(
      container.read(challengeProvider.notifier).loadCurrent(),
      throwsA(
        isA<ChallengeFailure>().having(
          (e) => e.kind,
          'kind',
          ChallengeFailureKind.notFound,
        ),
      ),
    );
  });

  test('公開終了の出題は版がない場合と同じ notFound にする', () async {
    final container = containerWith(
      clientWith(
        listChallenges: (_) async =>
            ListChallengesResponse(challenges: [challenge()]),
        getChallenge: (_) async => challenge(currentRevisionId: null),
      ),
    );
    await expectLater(
      container.read(challengeProvider.notifier).loadCurrent(),
      throwsA(
        isA<ChallengeFailure>().having(
          (e) => e.kind,
          'kind',
          ChallengeFailureKind.notFound,
        ),
      ),
    );
  });

  test('unavailable は自動再試行して取得する', () async {
    var calls = 0;
    final container = containerWith(
      clientWith(
        listChallenges: (_) async {
          calls++;
          if (calls == 1) {
            throw ApiException(
              code: .unavailable,
              reason: 'TEMPORARILY_UNAVAILABLE',
              message: '一時的に利用できません',
            );
          }
          return ListChallengesResponse(challenges: [challenge()]);
        },
        getChallenge: (_) async => challenge(),
        getChallengeRevision: (_) async => fakeRevision(),
      ),
    );
    final revision = await container
        .read(challengeProvider.notifier)
        .loadCurrent();
    expect(revision.id, 1);
    expect(calls, 2);
  });
  test('同じClientの古い版応答を新しい版へ混ぜない', () async {
    final old = Completer<ChallengeRevision>();
    var calls = 0;
    final container = containerWith(
      clientWith(
        listChallenges: (_) async =>
            ListChallengesResponse(challenges: [challenge()]),
        getChallenge: (_) async => challenge(currentRevisionId: calls + 1),
        getChallengeRevision: (_) {
          calls++;
          return calls == 1 ? old.future : Future.value(fakeRevision(id: 2));
        },
      ),
    );
    final notifier = container.read(challengeProvider.notifier);
    final first = notifier.loadCurrent();
    final rejected = expectLater(first, throwsA(isA<ChallengeFailure>()));
    while (calls == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    await notifier.loadCurrent();
    old.complete(fakeRevision());
    await rejected;
    expect(container.read(challengeProvider).revision?.id, 2);
  });

  for (final failure in [
    ApiException(
      code: .notFound,
      reason: 'CHALLENGE_NOT_FOUND',
      message: '非公開',
    ),
    TimeoutException('非公開'),
  ]) {
    test('単一出題の失敗を型付きエラーに変換する ${failure.runtimeType}', () async {
      final container = containerWith(
        clientWith(
          listChallenges: (_) async =>
              ListChallengesResponse(challenges: [challenge()]),
          getChallenge: (_) async => throw failure,
        ),
      );
      await expectLater(
        container.read(challengeProvider.notifier).loadCurrent(),
        throwsA(isA<ChallengeFailure>()),
      );
      expect(container.read(challengeProvider).revision, isNull);
    });
  }
}
