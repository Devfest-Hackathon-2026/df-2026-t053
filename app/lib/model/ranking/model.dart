import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

part 'model.freezed.dart';

enum RankingFailureKind {
  authentication,
  unavailable,
  temporarilyUnavailable,
  maintenance,
  revisionNotFound,
  rejected,
}

@freezed
abstract class RankingFailure with _$RankingFailure implements Exception {
  const factory RankingFailure(RankingFailureKind kind) = _RankingFailure;
}

@freezed
abstract class RankingState with _$RankingState {
  const factory RankingState({
    required ExplorationMode mode,
    int? revisionId,
    @Default('') String challengeTitle,
    @Default(true) bool isLoading,
    @Default(false) bool noPublishedChallenge,
    @Default(<RankingEntry>[]) List<RankingEntry> entries,
    RankingEntry? myEntry,
    DateTime? fetchedAt,
    String? errorMessage,
  }) = _RankingState;
}
