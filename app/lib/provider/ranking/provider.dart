import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app/model/ranking/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:photohunt_client/photohunt_client.dart' show Client;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';

part 'provider.g.dart';

/// 版・モードを固定したRPC。破棄後は認証更新に伴う再送も止める。
@riverpod
class RankingNotifier extends _$RankingNotifier {
  var _generation = 0;

  @override
  Client build(int revisionId, PlayMode mode) {
    ++_generation;
    ref.onDispose(() => ++_generation);
    return ref.watch(apiClientProvider);
  }

  Future<ListRankingEntriesResponse> listRankingEntries() {
    final client = state;
    return _call(
      client,
      () => client.ranking.listRankingEntries(
        ListRankingEntriesRequest(revisionId: revisionId, mode: mode),
      ),
    );
  }

  /// この版・モードで未プレイの場合だけnullを返す。
  Future<RankingEntry?> getMyRankingEntry() {
    final client = state;
    return _call(client, () async {
      try {
        return await client.ranking.getMyRankingEntry(
          GetMyRankingEntryRequest(revisionId: revisionId, mode: mode),
        );
      } on ApiException catch (error) {
        if (error.code == .notFound &&
            error.reason == ApiErrorReasons.rankingEntryNotFound) {
          return null;
        }
        rethrow;
      }
    });
  }

  Future<T> _call<T>(Client client, Future<T> Function() action) async {
    var active = true;
    final generation = _generation;
    Future<T> request() async {
      try {
        return await action();
      } on ApiException catch (error) {
        if (error.code != .failedPrecondition ||
            error.reason != ApiErrorReasons.profileNotInitialized) {
          rethrow;
        }
        if (!active ||
            !ref.mounted ||
            generation != _generation ||
            !identical(state, client)) {
          throw const RankingFailure(.authentication);
        }
        final authentication = client.authKeyProvider;
        if (authentication is! RefresherClientAuthKeyProvider) {
          throw const RankingFailure(.authentication);
        }
        final result = await authentication.refreshAuthKey(force: true);
        if (result != .success) {
          throw RankingFailure(
            result == .failedOther ? .unavailable : .authentication,
          );
        }
        if (!active ||
            !ref.mounted ||
            generation != _generation ||
            !identical(state, client)) {
          throw const RankingFailure(.authentication);
        }
        return action();
      }
    }

    try {
      return await request().timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      log('ランキングの取得に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (error is RankingFailure) rethrow;
      if (error is ServerpodClientUnauthorized) {
        throw const RankingFailure(.authentication);
      }
      if (error is ApiException) {
        if (error.code == .notFound &&
            error.reason == ApiErrorReasons.revisionNotFound) {
          throw const RankingFailure(.revisionNotFound);
        }
        if (error.code == .failedPrecondition &&
            error.reason == ApiErrorReasons.profileNotInitialized) {
          throw const RankingFailure(.authentication);
        }
        if (error.code == .unavailable) {
          throw RankingFailure(
            error.reason == 'MAINTENANCE' || error.reason == 'SCHEMA_TOO_NEW'
                ? .maintenance
                : .temporarilyUnavailable,
          );
        }
      }
      if (error is TimeoutException ||
          error is SocketException ||
          error is ServerpodClientException) {
        throw const RankingFailure(.unavailable);
      }
      throw const RankingFailure(.rejected);
    } finally {
      // timeoutしても元のFutureは続くため、遅れた認証更新から再送させない。
      active = false;
    }
  }
}
