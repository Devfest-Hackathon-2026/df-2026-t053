import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:app/model/challenge/model.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/model/ranking/model.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/ranking/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderSubscription;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_model.g.dart';

@riverpod
class RankingViewModel extends _$RankingViewModel {
  var _generation = 0;
  ProviderSubscription<Object?>? _rankingSubscription;
  Timer? _retryTimer;
  Completer<void>? _retryWait;

  /// nullはホームから公開中の版を開く場合。結果からは撮影した版を渡す。
  @override
  RankingState build({int? revisionId, ExplorationMode initialMode = .free}) {
    ref.watch(challengeProvider);
    _cancelPending();
    ref.onDispose(_cancelPending);
    final generation = ++_generation;
    unawaited(Future<void>.microtask(() => _load(generation)));
    return RankingState(mode: initialMode, revisionId: revisionId);
  }

  String get revisionLabel => switch (state.revisionId) {
    final id? =>
      state.challengeTitle.isEmpty
          ? '出題版 $id'
          : '${state.challengeTitle} ／ 出題版 $id',
    null => '公開中の出題',
  };

  String get myRankLabel => switch (state.myEntry) {
    final entry? => '${entry.rank} 位 ／ ${entry.score}点',
    null => '未記録',
  };

  String formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}/${two(local.month)}/${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  Future<void> reload() async {
    if (state.isLoading) return;
    _cancelPending();
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      noPublishedChallenge: false,
    );
    await _load(++_generation);
  }

  Future<void> switchMode(ExplorationMode mode) async {
    if (state.mode == mode) return;
    _cancelPending();
    state = RankingState(
      mode: mode,
      revisionId: state.revisionId,
      challengeTitle: state.challengeTitle,
    );
    await _load(++_generation);
  }

  bool _current(int generation) => ref.mounted && generation == _generation;

  void _cancelPending() {
    ++_generation;
    _rankingSubscription?.close();
    _rankingSubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryWait?.complete();
    _retryWait = null;
  }

  Future<void> _load(int generation) async {
    if (!_current(generation)) return;
    final mode = switch (state.mode) {
      .free => PlayMode.free,
      .near => PlayMode.near,
    };
    var target = state.revisionId;
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        if (!_current(generation)) return;
        if (target == null) {
          final response = await ref
              .read(challengeProvider.notifier)
              .listChallenges();
          if (!_current(generation)) return;
          if (response.challenges.isEmpty) {
            state = state.copyWith(
              isLoading: false,
              noPublishedChallenge: true,
            );
            return;
          }
          // 提出版は最大1件。欠落・複数件を適当な版へ置き換えない。
          if (response.challenges.length != 1) {
            throw StateError('Unexpected published challenge count');
          }
          final challenge = response.challenges.single;
          target = challenge.currentRevisionId;
          if (target == null || target <= 0) {
            throw StateError('Missing published revision');
          }
          state = state.copyWith(
            revisionId: target,
            challengeTitle: challenge.title,
            noPublishedChallenge: false,
          );
        }
        if (target <= 0) throw const RankingFailure(.revisionNotFound);
        final provider = rankingProvider(target, mode);
        _rankingSubscription?.close();
        _rankingSubscription = ref.listen(provider, (_, _) {});
        final ranking = ref.read(provider.notifier);
        final response = await ranking.listRankingEntries();
        if (!_current(generation)) return;
        final mine = await ranking.getMyRankingEntry();
        if (!_current(generation)) return;
        // 一覧と本人取得の両方が成功してから同じ画面へ反映する。
        state = state.copyWith(
          entries: [for (final entry in response.entries) entry.copyWith()],
          myEntry: mine?.copyWith(),
          fetchedAt: DateTime.now(),
          isLoading: false,
          noPublishedChallenge: false,
          errorMessage: null,
        );
        return;
      } catch (error, stackTrace) {
        if (!_current(generation)) return;
        final transient =
            error is RankingFailure && error.kind == .temporarilyUnavailable ||
            error is ChallengeFailure && error.kind == .temporarilyUnavailable;
        if (transient && attempt < 3) {
          final wait = Completer<void>();
          _retryWait = wait;
          _retryTimer = Timer(
            Duration(milliseconds: (1000 << attempt) + Random().nextInt(201)),
            () {
              _retryWait = null;
              _retryTimer = null;
              wait.complete();
            },
          );
          await wait.future;
          continue;
        }
        log(
          'ランキング画面を更新できませんでした',
          error: error.runtimeType,
          stackTrace: stackTrace,
        );
        state = state.copyWith(isLoading: false, errorMessage: _message(error));
        return;
      }
    }
  }

  String _message(Object error) => switch (error) {
    RankingFailure(kind: .authentication) ||
    ChallengeFailure(kind: .authentication) => '認証を確認できません。開始画面に戻ってから再試行してください',
    RankingFailure(kind: .maintenance) ||
    ChallengeFailure(kind: .maintenance) => 'メンテナンス中です。時間をおいて再試行してください',
    RankingFailure(kind: .revisionNotFound) => 'この出題版が見つかりません。開始画面に戻ってください',
    RankingFailure(kind: .unavailable || .temporarilyUnavailable) ||
    ChallengeFailure(
      kind: .unavailable || .temporarilyUnavailable,
    ) => 'ランキングを取得できません。通信状況を確認して再試行してください',
    _ => 'ランキングを表示できません。時間をおいて再試行してください',
  };
}
