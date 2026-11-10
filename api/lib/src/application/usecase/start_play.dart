import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:uuid/uuid_value.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/models.dart';
import '../../domain/ports/spawn_chooser.dart';
import '../../domain/ports/start_rate_limiter.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../../domain/repositories/play_session_repository.dart';
import '../../domain/repositories/shot_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../dto/play_result.dart';
import 'play_result_loader.dart';

/// requestId は、操作ごとにクライアントが作る UUID v4（docs/specs.md「共通エラーと再試行」）。
/// nil UUID や、ほかの版（同じ値を使い回しやすい v1 など）は受け付けない。
bool isUuidV4(UuidValue value) {
  final text = value.uuid.toLowerCase();
  // xxxxxxxx-xxxx-4xxx-[89ab]xxx-xxxxxxxxxxxx
  return text.length == 36 &&
      text[14] == '4' &&
      const {'8', '9', 'a', 'b'}.contains(text[19]);
}

/// 未撮影のプレイの有効期間（createTime から）。docs/specs.md「出題版・開始・結果の再取得」。
const Duration kPlaySessionLifetime = Duration(hours: 2);

/// プレイを開始する。処理順は docs/specs.md「出題版・開始・結果の再取得」のとおり。
///
/// 1. 入力を検証する。
/// 2. 同じ利用者・同じ requestId の作成済みセッションがあれば、版の公開状態の再評価
///    やレート制限より先に、それを返す（再送は回数を消費しない）。
/// 3. 新規の場合だけレート制限を確認する。
/// 4. 現在の公開版であることを確認する（サーバーが最新版へ差し替えない）。
/// 5. 開始点を選び、保存する。自由探索は指定された入口 ID を検証する。
///    周辺探索は唯一の点を選ぶ。
///
/// 本番（production）では、要求は共通ゲートで 1 件ずつ処理されるので、確認と保存の間に
/// 他の要求は入らない。共通ゲートは production でだけ有効で、開発・テストでは要求が並行
/// し得る。その場合も、同じ requestId の並行要求は一意制約で 1 件だけが保存され、負けた
/// 側は保存済みのものを返す（レート制限の回数は、保存できた要求だけが使う）。
/// 一意制約違反（`(user_profile_id, request_id)`）は 500 にせず、保存済みのものを返す。
class StartPlay(
  final ChallengeRepository _challenges,
  final PlaySessionRepository _sessions,
  final ShotRepository _shots,
  final UserProfileRepository _profiles,
  final StartRateLimiter _rateLimiter,
  final SpawnChooser _chooser,
  final DateTime Function() _now,
  final UuidValue Function() _newId,
) {
  Future<PlayResult> execute(
    UuidValue authUserId, {
    required int revisionId,
    required PlayMode mode,
    required UuidValue requestId,
    int? spawnPointId,
  }) async {
    if (mode == PlayMode.unknown || revisionId <= 0 || !isUuidV4(requestId)) {
      throw const PlayException(.invalidRequest);
    }
    final profileId = await _requireProfileId(authUserId);

    final existing = await _sessions.findByRequestId(profileId, requestId);
    if (existing != null) {
      return _replay(existing, revisionId, mode, spawnPointId);
    }

    // 確認だけで、回数は使わない。回数は保存できたときに記録する（失敗した開始は数えない）。
    final retryAfter = _rateLimiter.retryAfter(profileId);
    if (retryAfter != null) {
      throw PlayException(.sessionRateLimited, retryAfterSeconds: retryAfter);
    }

    // 版の行だけを読む（素材・モード・地点などの子データは要らない）。未公開の下書きは、
    // 存在しない版と同じにする（下書きの存在を REVISION_NOT_PLAYABLE で知らせない）。
    final status = await _challenges.findRevisionStatus(revisionId);
    if (status == null || !status.published) {
      throw const PlayException(.revisionNotFound);
    }
    final challenge = await _challenges.findById(status.challengeId);
    if (challenge == null || challenge.currentRevisionId != revisionId) {
      throw const PlayException(.revisionNotPlayable);
    }

    final candidates = await _challenges.listSpawnPoints(revisionId, mode);
    // free は 1 件以上（seed は 2〜32 件で登録する）、near は唯一の点（seed は 1 件で登録する）。
    // これを外れるのはデータの誤りで、near を黙って抽選しない。
    final validCount = mode == PlayMode.near
        ? candidates.length == 1
        : candidates.isNotEmpty;
    if (!validCount) {
      throw CorruptedDataException(
        entity: 'spawn_point',
        field: 'mode_config_id',
        message: '${mode.name} の開始点の数が前提と違う（${candidates.length} 件）',
      );
    }
    // 候補は、この版・モードの mode_config に属する開始点だけを問い合わせて得ている。
    // そこから選ぶので、選んだ開始点は必ずこの版・モードに属する。
    final spawn = _chooseSpawn(mode, candidates, spawnPointId);

    final startedAt = _now().toUtc();
    try {
      final saved = await _sessions.insert(
        PlaySession(
          id: _newId(),
          requestId: requestId,
          revisionId: revisionId,
          mode: mode,
          spawnPointId: spawn.id,
          userProfileId: profileId,
          startedAt: startedAt,
          expiresAt: startedAt.add(kPlaySessionLifetime),
        ),
      );
      _rateLimiter.record(profileId);
      return PlayResult.active(session: saved, spawn: spawn);
    } on DuplicateEntityException catch (error) {
      // 同じ requestId の並行要求に負けた。保存済みのものを、再送と同じ判定で返す。
      if (error.entity != 'play_session' ||
          error.constraint != 'play_session_profile_request_uk') {
        rethrow;
      }
      final winner = await _sessions.findByRequestId(profileId, requestId);
      if (winner == null) rethrow;
      return _replay(winner, revisionId, mode, spawnPointId);
    }
  }

  /// 自由探索は指定された入口 ID の開始点だけを受け付ける。
  /// 周辺探索はクライアントの ID を受け付けず、唯一の点を選ぶ。
  SpawnPoint _chooseSpawn(
    PlayMode mode,
    List<SpawnPoint> candidates,
    int? spawnPointId,
  ) {
    if (mode == .near) {
      if (spawnPointId != null) throw const PlayException(.invalidRequest);
      return candidates[_chooser.choose(candidates.length)];
    }
    if (spawnPointId == null) throw const PlayException(.invalidRequest);
    for (final candidate in candidates) {
      if (candidate.id == spawnPointId) return candidate;
    }
    throw const PlayException(.invalidRequest);
  }

  /// 作成済みのセッションを返す。入力が違えば [PlayFailure.requestIdReused]。
  /// 版が現在の公開版でなくても、そのまま返す（公開状態は再評価しない）。撮影済みなら
  /// 撮影結果と正解・解説も返す（端末は結果へ進む）。
  Future<PlayResult> _replay(
    PlaySession existing,
    int revisionId,
    PlayMode mode,
    int? spawnPointId,
  ) async {
    // 自由探索は ID の欠落も別 ID も再送の不一致。周辺探索は ID を付けた再送だけを拒否する。
    final mismatched = mode == .free
        ? spawnPointId != existing.spawnPointId
        : spawnPointId != null;
    if (existing.revisionId != revisionId ||
        existing.mode != mode ||
        mismatched) {
      throw const PlayException(.requestIdReused);
    }
    return loadPlayResult(existing, challenges: _challenges, shots: _shots);
  }

  Future<int> _requireProfileId(UuidValue authUserId) async {
    final id = (await _profiles.findByAuthUserId(authUserId))?.id;
    if (id == null) throw const PlayException(.profileNotInitialized);
    return id;
  }
}
