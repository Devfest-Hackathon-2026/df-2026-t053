import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

enum ProfileFailureKind {
  invalidNickname,
  authentication,
  unavailable,
  rejected,
}

/// ProviderからViewModelへ渡す失敗データ。表示文言はViewModelが決める。
@freezed
abstract class ProfileFailure with _$ProfileFailure implements Exception {
  const factory ProfileFailure(
    ProfileFailureKind kind, {
    String? nicknameReason,
  }) = _ProfileFailure;
}
