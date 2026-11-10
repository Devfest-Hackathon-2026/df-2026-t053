import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

part 'model.freezed.dart';

/// 取得済みの出題と不変版。開始はこの版のIDをそのまま指定する。
@freezed
abstract class ChallengeState with _$ChallengeState {
  const factory ChallengeState({int? challengeId, ChallengeRevision? revision}) =
      _ChallengeState;
}

enum ChallengeFailureKind {
  notFound,
  unavailable,
  temporarilyUnavailable,
  maintenance,
  authentication,
  rejected,
}

/// ProviderからViewModelへ渡す失敗データ。表示文言はViewModelが決める。
@freezed
abstract class ChallengeFailure with _$ChallengeFailure implements Exception {
  const factory ChallengeFailure(ChallengeFailureKind kind) = _ChallengeFailure;
}
