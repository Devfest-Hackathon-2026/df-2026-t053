import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:app/model/play/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/api_client/retry.dart';
import 'package:app/provider/auth/provider.dart';
import 'package:app/provider/play/storage.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photohunt_client/photohunt_client.dart' show Client;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';

part 'provider.g.dart';

/// 保留中の撮影の保存先。テストでは一時フォルダへ差し替える。
@riverpod
Future<Directory> Function() playSupportDirectory(Ref ref) =>
    getApplicationSupportDirectory;

/// UUID v4 を発行する。開始と撮影で別々に発行し、再送では変えない。
UuidValue _newRequestId() {
  final random = math.Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = bytes[6] & 0x0f | 0x40;
  bytes[8] = bytes[8] & 0x3f | 0x80;
  return UuidValue.fromList(bytes);
}

/// プレイの開始・撮影・結果照会と、保留中の撮影の端末記録を担当する。
/// SDK例外を画面で扱える失敗へ変換する。
@Riverpod(keepAlive: true)
class PlayNotifier extends _$PlayNotifier {
  @override
  PlayState build() {
    _client = ref.watch(apiClientProvider);
    ref.watch(playControllerProvider.notifier);
    _attempt++;
    _startRequest = null;
    _creating = null;
    _sending = null;
    ref.onDispose(() => _attempt++);
    return const PlayState();
  }

  late Client _client;
  int _attempt = 0;
  CreatePlaySessionRequest? _startRequest;
  UuidValue? _shotRequestId;
  Future<PlaySession>? _creating;
  Future<SubmitShotResponse?>? _sending;

  bool _isCurrent(Client client, int attempt) =>
      ref.mounted && identical(_client, client) && attempt == _attempt;

  /// 出題版とモードを固定してセッションを作成する。作成中の連打は
  /// 進行中の作成へ合流し、応答不明の再試行では同じrequestIdを使う。
  Future<PlaySession> createSession({
    required int revisionId,
    required PlayMode mode,
    int? spawnPointId,
  }) {
    if (mode == .unknown || state.pendingShot != null) {
      return Future.error(const PlayFailure(.rejected));
    }
    final start = _startRequest;
    if (start != null &&
        (start.revisionId != revisionId ||
            start.mode != mode ||
            start.spawnPointId != spawnPointId)) {
      return Future.error(const PlayFailure(.requestIdReused));
    }
    final creating = _creating;
    if (creating != null) {
      return creating;
    }
    final future = _createSession(
      revisionId: revisionId,
      mode: mode,
      spawnPointId: spawnPointId,
    );
    _creating = future;
    unawaited(
      future.then(
        (_) => _clearCreating(future),
        onError: (_) => _clearCreating(future),
      ),
    );
    return future;
  }

  void _clearCreating(Future<PlaySession> future) {
    if (identical(_creating, future)) {
      _creating = null;
    }
  }

  void _clearSending(Future<SubmitShotResponse?> future) {
    if (identical(_sending, future)) {
      _sending = null;
    }
  }

  Future<PlaySession> _createSession({
    required int revisionId,
    required PlayMode mode,
    int? spawnPointId,
  }) async {
    final client = _client;
    final attempt = ++_attempt;
    final request = _startRequest ??= CreatePlaySessionRequest(
      revisionId: revisionId,
      mode: mode,
      requestId: _newRequestId(),
      spawnPointId: spawnPointId,
    );
    state = state.copyWith(phase: .creating);
    try {
      final session = await _call(
        client,
        () => retryOnUnavailable(
          () => client.play
              .createPlaySession(request)
              .timeout(const Duration(seconds: 10)),
          shouldContinue: () => _isCurrent(client, attempt),
        ),
      );
      if (!_isCurrent(client, attempt)) {
        throw const PlayFailure(.rejected);
      }
      if (session.revisionId != revisionId ||
          session.mode != mode ||
          session.state == .unknown ||
          (spawnPointId != null && session.spawnPointId != spawnPointId)) {
        throw const PlayFailure(.rejected);
      }
      _startRequest = null;
      ref.read(playControllerProvider.notifier).beginSession(session.id);
      if (session.state == .completed) {
        // 同じrequestIdで撮影済みセッションが返った場合は結果へ進む。
        final result = _resultFrom(session);
        state = PlayState(phase: .completed, session: session, result: result);
        return session;
      }
      if (session.expireTime.isBefore(DateTime.now().toUtc())) {
        state = PlayState(phase: .sessionExpired, session: session);
        throw const PlayFailure(.sessionExpired);
      }
      state = PlayState(phase: .active, session: session);
      return session;
    } on PlayFailure catch (failure) {
      if (_isCurrent(client, attempt) && failure.kind != .unavailable) {
        _startRequest = null;
      }
      if (_isCurrent(client, attempt) && state.phase == .creating) {
        state = state.copyWith(phase: .idle);
      }
      rethrow;
    }
  }

  /// シャッターで固定した姿勢を送信する。端末記録を保存してから送る。
  /// 結果が不明な場合は例外にせず null を返し、状態を結果不明へ移す。
  Future<SubmitShotResponse?> submitShot(ShotInput shot) {
    final sending = _sending;
    if (sending != null) return sending;
    final session = state.session;
    final authUserId = ref.read(authProvider).authUserId;
    if (session == null || state.phase != .active) {
      return Future.error(const PlayFailure(.rejected));
    }
    if (authUserId == null) {
      return Future.error(const PlayFailure(.authentication));
    }
    final pending = PendingShot(
      authUserId: authUserId.toString(),
      playSessionId: session.id.toString(),
      revisionId: session.revisionId,
      shot: shot.copyWith(),
      requestId: (_shotRequestId ??= _newRequestId()).toString(),
    );
    // ファイルI/Oより前に状態と姿勢を固定し、保存中の連打も合流させる。
    state = state.copyWith(phase: .submitting, pendingShot: pending);
    final client = _client;
    final attempt = _attempt;
    final future = _persistAndSend(pending, client, attempt);
    _sending = future;
    unawaited(
      future.then(
        (_) => _clearSending(future),
        onError: (_) => _clearSending(future),
      ),
    );
    return future;
  }

  Future<SubmitShotResponse?> _persistAndSend(
    PendingShot pending,
    Client client,
    int attempt,
  ) async {
    try {
      await _savePending(pending);
    } catch (error, stackTrace) {
      log('撮影を端末に保存できませんでした', error: error.runtimeType, stackTrace: stackTrace);
      if (_isCurrent(client, attempt)) {
        state = state.copyWith(phase: .active, pendingShot: null);
        _shotRequestId = null;
      }
      throw const PlayFailure(.rejected);
    }
    if (!_isCurrent(client, attempt)) return null;
    _checkOwner(pending);
    return _sendShotInternal(pending);
  }

  void _checkOwner(PendingShot pending) {
    final auth = ref.read(authProvider);
    if (auth.status != .signedIn ||
        auth.authUserId?.toString() != pending.authUserId) {
      state = state.copyWith(phase: .pendingAuthMismatch);
      throw const PlayFailure(.authentication);
    }
  }

  /// 結果不明の撮影を、固定した姿勢とrequestIdのまま再送する。
  Future<SubmitShotResponse?> resendShot() async {
    final pending = state.pendingShot;
    if (pending == null || state.phase != .submitUnknown) {
      return null;
    }
    _checkOwner(pending);
    state = state.copyWith(phase: .submitting);
    return _sendShot(pending);
  }

  /// 結果不明の撮影を照会する。completed なら保存済み結果を返し、
  /// active かつ期限内なら結果不明のまま、期限切れなら期限切れを返す。
  Future<SubmitShotResponse?> checkShotResult() async {
    final pending = state.pendingShot;
    if (pending != null) _checkOwner(pending);
    final session = state.session;
    final playSessionId = pending?.playSessionId ?? session?.id.toString();
    if (playSessionId == null) {
      return null;
    }
    final client = _client;
    final attempt = ++_attempt;
    final fetched = await _call(
      client,
      () => retryOnUnavailable(
        () => client.play
            .getPlaySession(
              GetPlaySessionRequest(
                playSessionId: UuidValue.fromString(playSessionId),
              ),
            )
            .timeout(const Duration(seconds: 10)),
        shouldContinue: () => _isCurrent(client, attempt),
      ),
    );
    if (!_isCurrent(client, attempt)) {
      return null;
    }
    if (pending != null) _checkOwner(pending);
    if (fetched.id.toString() != playSessionId ||
        (pending != null && fetched.revisionId != pending.revisionId) ||
        fetched.state == .unknown ||
        fetched.mode == .unknown) {
      throw const PlayFailure(.rejected);
    }
    if (fetched.state == .completed) {
      return _completeWith(_resultFrom(fetched), fetched);
    }
    if (fetched.state == .active &&
        fetched.expireTime.isBefore(DateTime.now().toUtc())) {
      state = state.copyWith(phase: .sessionExpired, session: fetched);
      return null;
    }
    state = state.copyWith(phase: .submitUnknown, session: fetched);
    return null;
  }

  /// 起動時に保留中の撮影を復旧する。認証を復旧できた場合だけ照会し、
  /// 他アカウントの記録は送らず、結果を確認してから記録を消す。
  Future<void> restorePending() async {
    final client = _client;
    final attempt = _attempt;
    final pending = await _loadPending();
    if (pending == null || !_isCurrent(client, attempt)) {
      return;
    }
    state = state.copyWith(pendingShot: pending);
    final authUserId = ref.read(authProvider).authUserId;
    if (authUserId == null || authUserId.toString() != pending.authUserId) {
      // 認証情報を失った・別アカウントの記録は引き継がない。
      state = state.copyWith(phase: .pendingAuthMismatch);
      return;
    }
    _shotRequestId = UuidValue.fromString(pending.requestId);
    try {
      final result = await checkShotResult();
      if (result != null) {
        return;
      }
      final session = state.session;
      if (session != null && state.phase == .submitUnknown) {
        ref.read(playControllerProvider.notifier).beginSession(session.id);
      }
    } on PlayFailure {
      // 照会できない場合も記録は保持し、結果不明として案内する。
      if (ref.mounted) {
        state = state.copyWith(phase: .submitUnknown);
      }
    }
  }

  /// 保留中の撮影を明示操作で破棄する。
  Future<void> discardPending() async {
    _attempt++;
    _creating = null;
    _sending = null;
    _startRequest = null;
    await _deletePending();
    _shotRequestId = null;
    ref.read(playControllerProvider.notifier).endSession();
    if (ref.mounted) {
      state = const PlayState();
    }
  }

  /// 探索終了。未撮影セッションは記録として残るが、端末側の保持は解く。
  /// 保留中の撮影がある場合は記録を消さない。
  void clearSession() {
    _attempt++;
    _creating = null;
    _sending = null;
    _startRequest = null;
    ref.read(playControllerProvider.notifier).endSession();
    final pending = state.pendingShot;
    state = pending == null
        ? const PlayState()
        : PlayState(phase: .submitUnknown, pendingShot: pending);
  }

  /// 送信中の連打は進行中の送信へ合流し、二重撮影にしない。
  Future<SubmitShotResponse?> _sendShot(PendingShot pending) {
    final sending = _sending;
    if (sending != null) {
      return sending;
    }
    final future = _sendShotInternal(pending);
    _sending = future;
    unawaited(
      future.then(
        (_) => _clearSending(future),
        onError: (_) => _clearSending(future),
      ),
    );
    return future;
  }

  Future<SubmitShotResponse?> _sendShotInternal(PendingShot pending) async {
    final client = _client;
    final attempt = ++_attempt;
    try {
      final response = await _call(
        client,
        () => retryOnUnavailable(() {
          _checkOwner(pending);
          return client.play
              .submitShot(
                SubmitShotRequest(
                  playSessionId: UuidValue.fromString(pending.playSessionId),
                  camera: pending.shot,
                  requestId: UuidValue.fromString(pending.requestId),
                ),
              )
              .timeout(const Duration(seconds: 15));
        }, shouldContinue: () => _isCurrent(client, attempt)),
      );
      if (!_isCurrent(client, attempt)) {
        return null;
      }
      _checkOwner(pending);
      // 起動時の照会が不通だった場合は、版・モードも照会で確定してから表示する。
      if (state.session == null) return await checkShotResult();
      return await _completeWith(response, state.session);
    } on PlayFailure catch (failure) {
      if (!_isCurrent(client, attempt)) {
        return null;
      }
      switch (failure.kind) {
        case .alreadySubmitted:
          // 別IDで撮影済み。確定結果を照会して表示する。
          return await checkShotResult();
        case .sessionExpired:
          // 期限切れは未保存が確定しているため、記録を消して案内する。
          await _deletePending();
          if (!_isCurrent(client, attempt)) return null;
          _shotRequestId = null;
          if (ref.mounted) {
            state = state.copyWith(phase: .sessionExpired);
          }
          rethrow;
        case .invalidCamera:
          // 入力拒否が確定した場合だけ、未撮影・期限内を確認して探索へ戻す。
          return _verifyRejected(pending, failure);
        case .unavailable:
          // 保存の成否が不明。姿勢とrequestIdを保持して結果確認へ回す。
          state = state.copyWith(phase: .submitUnknown);
          return null;
        default:
          if (state.phase != .pendingAuthMismatch) {
            state = state.copyWith(phase: .submitUnknown);
          }
          rethrow;
      }
    }
  }

  Future<SubmitShotResponse?> _verifyRejected(
    PendingShot pending,
    PlayFailure failure,
  ) async {
    final client = _client;
    final attempt = _attempt;
    final PlaySession fetched;
    try {
      fetched = await _call(
        client,
        () => client.play
            .getPlaySession(
              GetPlaySessionRequest(
                playSessionId: UuidValue.fromString(pending.playSessionId),
              ),
            )
            .timeout(const Duration(seconds: 10)),
      );
    } on PlayFailure {
      // 確認できない場合は結果不明として扱い、記録を保持する。
      if (_isCurrent(client, attempt)) {
        state = state.copyWith(phase: .submitUnknown);
      }
      return null;
    }
    if (!_isCurrent(client, attempt)) {
      return null;
    }
    _checkOwner(pending);
    if (fetched.id.toString() != pending.playSessionId ||
        fetched.revisionId != pending.revisionId ||
        fetched.mode == .unknown) {
      state = state.copyWith(phase: .submitUnknown);
      return null;
    }
    if (fetched.state == .completed) {
      return _completeWith(_resultFrom(fetched), fetched);
    }
    if (fetched.state == .active &&
        fetched.expireTime.isBefore(DateTime.now().toUtc())) {
      await _deletePending();
      _shotRequestId = null;
      state = state.copyWith(phase: .sessionExpired, session: fetched);
      throw const PlayFailure(.sessionExpired);
    }
    if (fetched.state != .active) {
      state = state.copyWith(phase: .submitUnknown);
      return null;
    }
    await _deletePending();
    if (!_isCurrent(client, attempt)) return null;
    _shotRequestId = null;
    state = state.copyWith(phase: .active, session: fetched, pendingShot: null);
    throw failure;
  }

  Future<SubmitShotResponse> _completeWith(
    SubmitShotResponse response,
    PlaySession? session,
  ) async {
    // 結果を表示できる状態へ写してから削除する。削除失敗は次回の再照会で回収する。
    _shotRequestId = null;
    state = PlayState(
      phase: .completed,
      session: session ?? state.session,
      result: response,
    );
    try {
      await _deletePending();
    } catch (error, stackTrace) {
      log(
        '確認済み撮影記録を削除できませんでした',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
    }
    return response;
  }

  SubmitShotResponse _resultFrom(PlaySession session) {
    final shot = session.shot;
    final reveal = session.reveal;
    final entry = session.myRankingEntry;
    if (shot == null || reveal == null || entry == null) {
      throw const PlayFailure(.rejected);
    }
    return SubmitShotResponse(
      shot: shot,
      reveal: reveal,
      myRankingEntry: entry,
    );
  }

  // 保存・削除の順を守り、保存途中の明示破棄でも記録を再出現させない。
  Future<void> _storageTail = Future.value();

  Future<T> _withStorage<T>(Future<T> Function(Directory) action) {
    final directory = ref.read(playSupportDirectoryProvider);
    final operation = _storageTail.then((_) async => action(await directory()));
    _storageTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _savePending(PendingShot pending) =>
      _withStorage((directory) => savePendingShot(directory, pending));

  Future<PendingShot?> _loadPending() => _withStorage(loadPendingShot);

  Future<void> _deletePending() => _withStorage(deletePendingShot);

  Future<T> _call<T>(Client client, Future<T> Function() action) async {
    final attempt = _attempt;
    try {
      try {
        return await action();
      } on ApiException catch (error) {
        if (error.code != .failedPrecondition ||
            error.reason != 'PROFILE_NOT_INITIALIZED') {
          rethrow;
        }
        if (!_isCurrent(client, attempt)) {
          throw const PlayFailure(.authentication);
        }
        final authentication = client.authKeyProvider;
        if (authentication is! RefresherClientAuthKeyProvider) {
          throw const PlayFailure(.authentication);
        }
        final result = await authentication.refreshAuthKey(force: true);
        if (result != RefreshAuthKeyResult.success) {
          throw PlayFailure(
            result == RefreshAuthKeyResult.failedOther
                ? .unavailable
                : .authentication,
          );
        }
        if (!_isCurrent(client, attempt)) {
          throw const PlayFailure(.authentication);
        }
        return await action();
      }
    } catch (error, stackTrace) {
      log('プレイの通信に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (error is PlayFailure) rethrow;
      if (error is ServerpodClientUnauthorized) {
        throw const PlayFailure(.authentication);
      }
      if (error is ApiException) {
        throw _convert(error);
      }
      if (error is TimeoutException ||
          error is SocketException ||
          error is ServerpodClientException) {
        throw const PlayFailure(.unavailable);
      }
      throw const PlayFailure(.rejected);
    }
  }

  PlayFailure _convert(ApiException error) {
    return switch (error.code) {
      .invalidArgument => switch (error.reason) {
        'INVALID_CAMERA' => const PlayFailure(.invalidCamera),
        'REQUEST_ID_REUSED' => const PlayFailure(.requestIdReused),
        _ => const PlayFailure(.rejected),
      },
      .notFound => const PlayFailure(.notFound),
      .alreadyExists => const PlayFailure(.alreadySubmitted),
      .permissionDenied => const PlayFailure(.notOwner),
      .failedPrecondition => switch (error.reason) {
        'SESSION_EXPIRED' => const PlayFailure(.sessionExpired),
        'REVISION_NOT_PLAYABLE' => const PlayFailure(.revisionNotPlayable),
        'PROFILE_NOT_INITIALIZED' => const PlayFailure(.authentication),
        _ => const PlayFailure(.rejected),
      },
      .resourceExhausted => PlayFailure(
        .rateLimited,
        retryAfterSeconds: error.retryAfterSeconds,
      ),
      .unavailable => PlayFailure(
        error.reason == 'MAINTENANCE' || error.reason == 'SCHEMA_TOO_NEW'
            ? .maintenance
            : .unavailable,
      ),
      _ => const PlayFailure(.rejected),
    };
  }
}
