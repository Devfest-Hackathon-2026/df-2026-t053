import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app/model/profile/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:photohunt_client/photohunt_client.dart' show Client;
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_client/serverpod_client.dart';

part 'provider.g.dart';

/// プロフィールRPCとSDK例外の変換を担当する。画面状態はViewModelへ置く。
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  var _generation = 0;

  @override
  Client build() {
    ++_generation;
    ref.onDispose(() => ++_generation);
    return ref.watch(apiClientProvider);
  }

  Future<Profile> getMyProfile() {
    final client = state;
    return _call(
      client,
      () => client.profile.getMyProfile(GetMyProfileRequest()),
    );
  }

  Future<Profile> updateNickname(String nickname) {
    final client = state;
    return _call(
      client,
      () => client.profile.updateNickname(
        UpdateNicknameRequest(nickname: nickname),
      ),
    );
  }

  Future<Profile> _call(
    Client client,
    Future<Profile> Function() action,
  ) async {
    var active = true;
    final generation = _generation;
    Future<Profile> request() async {
      try {
        return await action();
      } on ApiException catch (error) {
        // #58の欠落プロフィール契約。再び欠落しても更新を繰り返さない。
        if (error.code != .failedPrecondition ||
            error.reason != 'PROFILE_NOT_INITIALIZED') {
          rethrow;
        }
        if (!active ||
            !ref.mounted ||
            generation != _generation ||
            !identical(state, client)) {
          throw const ProfileFailure(.authentication);
        }
        final authentication = client.authKeyProvider;
        if (authentication is! RefresherClientAuthKeyProvider) {
          throw const ProfileFailure(.authentication);
        }
        final result = await authentication.refreshAuthKey(force: true);
        if (result != RefreshAuthKeyResult.success) {
          throw ProfileFailure(
            result == RefreshAuthKeyResult.failedOther
                ? .unavailable
                : .authentication,
          );
        }
        // 接続先変更・破棄後に旧アカウントの要求を再送しない。
        if (!active ||
            !ref.mounted ||
            generation != _generation ||
            !identical(state, client)) {
          throw const ProfileFailure(.authentication);
        }
        return await action();
      }
    }

    try {
      return await request().timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      // SDK例外には応答本文が入ることがあるため、種類とstackだけ記録する。
      log('プロフィールの通信に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (error is ProfileFailure) rethrow;
      if (error is ServerpodClientUnauthorized) {
        throw const ProfileFailure(.authentication);
      }
      if (error is ApiException) {
        if (error.code == .invalidArgument &&
            error.reason == ApiErrorReasons.invalidNickname) {
          final violations = error.fieldViolations;
          String? reason;
          if (violations != null) {
            for (final violation in violations) {
              if (violation.field == 'nickname') {
                reason = violation.reason;
                break;
              }
            }
          }
          throw ProfileFailure(.invalidNickname, nicknameReason: reason);
        }
        if (error.code == .failedPrecondition &&
            error.reason == 'PROFILE_NOT_INITIALIZED') {
          throw const ProfileFailure(.authentication);
        }
        if (error.code == .unavailable) {
          throw const ProfileFailure(.unavailable);
        }
      }
      if (error is TimeoutException ||
          error is SocketException ||
          error is ServerpodClientException) {
        throw const ProfileFailure(.unavailable);
      }
      throw const ProfileFailure(.rejected);
    } finally {
      // 期限を過ぎた認証更新が完了しても旧要求を再送しない。
      active = false;
    }
  }
}
