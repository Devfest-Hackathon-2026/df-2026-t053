import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app/model/challenge/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/api_client/retry.dart';
import 'package:photohunt_client/photohunt_client.dart' show Client;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';

part 'provider.g.dart';

/// 公開出題の取得と版の保持を担当する。SDK例外を画面で扱える失敗へ変換する。
@Riverpod(keepAlive: true)
class ChallengeNotifier extends _$ChallengeNotifier {
  @override
  ChallengeState build() {
    _client = ref.watch(apiClientProvider);
    return const ChallengeState();
  }

  // Clientのoverrideで初期状態が同値でも、利用側の取得世代を更新する。
  @override
  bool updateShouldNotify(ChallengeState previous, ChallengeState next) => true;

  late Client _client;
  int _generation = 0;

  /// 読み込んだ不変版。未取得なら例外にする（nullで開始へ進ませない）。
  ChallengeRevision get currentRevision {
    final revision = state.revision;
    if (revision == null) {
      throw StateError('出題版が未取得です');
    }
    return revision;
  }

  // ランキング画面は自分で再試行を管理するため、一覧単体では再試行しない。
  Future<ListChallengesResponse> listChallenges() {
    final client = _client;
    return _call(
      client,
      () => client.challenge
          .listChallenges(ListChallengesRequest())
          .timeout(const Duration(seconds: 10)),
    );
  }

  /// 公開中の出題から現在の不変版を読み込み、保持する。
  Future<ChallengeRevision> loadCurrent() async {
    final generation = ++_generation;
    final client = _client;
    final loaded = await _call(client, () async {
      final list = await retryOnUnavailable(
        () => client.challenge
            .listChallenges(ListChallengesRequest())
            .timeout(const Duration(seconds: 10)),
        shouldContinue: () => _isCurrent(client),
      );
      if (list.challenges.isEmpty) {
        throw const ChallengeFailure(.notFound);
      }
      if (list.challenges.length != 1) {
        throw const ChallengeFailure(.rejected);
      }
      final challenge = list.challenges.single;
      final detail = await retryOnUnavailable(
        () => client.challenge
            .getChallenge(GetChallengeRequest(challengeId: challenge.id))
            .timeout(const Duration(seconds: 10)),
        shouldContinue: () => _isCurrent(client),
      );
      final revisionId = detail.currentRevisionId;
      if (revisionId == null) {
        // 公開終了の出題は、版がない場合と同じ扱いで開始できない。
        throw const ChallengeFailure(.notFound);
      }
      final revision = await retryOnUnavailable(
        () => client.challenge
            .getChallengeRevision(
              GetChallengeRevisionRequest(revisionId: revisionId),
            )
            .timeout(const Duration(seconds: 10)),
        shouldContinue: () => _isCurrent(client),
      );
      if (revision.id != revisionId || revision.challengeId != challenge.id) {
        throw const ChallengeFailure(.rejected);
      }
      return (challengeId: challenge.id, revision: revision);
    });
    if (!_isCurrent(client) || generation != _generation) {
      throw const ChallengeFailure(.rejected);
    }
    state = ChallengeState(
      challengeId: loaded.challengeId,
      revision: loaded.revision,
    );
    return loaded.revision;
  }

  /// 復旧時は公開中の新版でなく、撮影記録に結び付いた不変版を使う。
  Future<ChallengeRevision> loadRevision(int revisionId) async {
    final client = _client;
    final generation = ++_generation;
    final revision = await _call(
      client,
      () => client.challenge
          .getChallengeRevision(
            GetChallengeRevisionRequest(revisionId: revisionId),
          )
          .timeout(const Duration(seconds: 10)),
    );
    if (!_isCurrent(client) ||
        generation != _generation ||
        revision.id != revisionId) {
      throw const ChallengeFailure(.rejected);
    }
    state = ChallengeState(
      challengeId: revision.challengeId,
      revision: revision,
    );
    return revision;
  }

  bool _isCurrent(Client client) => ref.mounted && identical(_client, client);

  Future<T> _call<T>(Client client, Future<T> Function() action) async {
    try {
      try {
        return await action();
      } on ApiException catch (error) {
        // プロフィール欠落時はSDKで認証更新を一度だけ強制し、同じ要求を
        // 一度だけ再実行する。再び欠落しても作り直さない。
        if (error.code != .failedPrecondition ||
            error.reason != 'PROFILE_NOT_INITIALIZED') {
          rethrow;
        }
        if (!_isCurrent(client)) {
          throw const ChallengeFailure(.authentication);
        }
        final authentication = client.authKeyProvider;
        if (authentication is! RefresherClientAuthKeyProvider) {
          throw const ChallengeFailure(.authentication);
        }
        final result = await authentication.refreshAuthKey(force: true);
        if (result != RefreshAuthKeyResult.success) {
          throw ChallengeFailure(
            result == RefreshAuthKeyResult.failedOther
                ? .unavailable
                : .authentication,
          );
        }
        if (!_isCurrent(client)) {
          throw const ChallengeFailure(.authentication);
        }
        return await action();
      }
    } catch (error, stackTrace) {
      log('出題の取得に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (error is ChallengeFailure) rethrow;
      if (error is ServerpodClientUnauthorized) {
        throw const ChallengeFailure(.authentication);
      }
      if (error is ApiException) {
        if (error.code == .notFound) {
          throw const ChallengeFailure(.notFound);
        }
        if (error.code == .unavailable) {
          throw ChallengeFailure(
            error.reason == 'MAINTENANCE' || error.reason == 'SCHEMA_TOO_NEW'
                ? .maintenance
                : .temporarilyUnavailable,
          );
        }
        if (error.code == .failedPrecondition &&
            error.reason == 'PROFILE_NOT_INITIALIZED') {
          throw const ChallengeFailure(.authentication);
        }
      }
      if (error is TimeoutException ||
          error is SocketException ||
          error is ServerpodClientException) {
        throw const ChallengeFailure(.unavailable);
      }
      throw const ChallengeFailure(.rejected);
    }
  }
}
