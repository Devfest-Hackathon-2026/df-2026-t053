import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';

part 'model.freezed.dart';

enum AuthStatus { unknown, restoring, signedIn, failed }

/// 認証Providerの状態。トークン自体はSDKのセッション管理へ置き、ここへは
/// 復旧の成否と所有アカウントの識別だけを持つ。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    UuidValue? authUserId,
  }) = _AuthState;
}

enum AuthFailureKind { unavailable }

/// ProviderからViewModelへ渡す失敗データ。表示文言はViewModelが決める。
@freezed
abstract class AuthFailure with _$AuthFailure implements Exception {
  const factory AuthFailure(AuthFailureKind kind) = _AuthFailure;
}
