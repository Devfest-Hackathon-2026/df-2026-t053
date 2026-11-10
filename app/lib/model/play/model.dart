import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

part 'model.freezed.dart';
part 'model.g.dart';

enum PlayPhase {
  idle,
  creating,
  active,
  submitting,
  submitUnknown,
  completed,
  sessionExpired,
  pendingAuthMismatch,
}

/// プレイProviderの状態。正式な点数はサーバーの結果DTOだけを持ち、
/// 端末で採点した値へ置き換えない。
@freezed
abstract class PlayState with _$PlayState {
  const factory PlayState({
    @Default(PlayPhase.idle) PlayPhase phase,
    PlaySession? session,
    SubmitShotResponse? result,
    PendingShot? pendingShot,
  }) = _PlayState;
}

/// 撮影を送る直前に端末のアプリ専用領域へ記録する保留中の撮影。
/// 中断した撮影の結果確認用であり、歩行状態の保存ではない。
@freezed
abstract class PendingShot with _$PendingShot {
  const factory PendingShot({
    required String authUserId,
    required String playSessionId,
    required int revisionId,
    required ShotInput shot,
    required String requestId,
  }) = _PendingShot;

  factory PendingShot.fromJson(Map<String, Object?> json) =>
      _$PendingShotFromJson(json);
}

enum PlayFailureKind {
  sessionExpired,
  invalidCamera,
  requestIdReused,
  revisionNotPlayable,
  rateLimited,
  notFound,
  notOwner,
  alreadySubmitted,
  unavailable,
  maintenance,
  authentication,
  rejected,
  poseNotReady,
}

/// ProviderからViewModelへ渡す失敗データ。表示文言はViewModelが決める。
@freezed
abstract class PlayFailure with _$PlayFailure implements Exception {
  const factory PlayFailure(PlayFailureKind kind, {int? retryAfterSeconds}) =
      _PlayFailure;
}
