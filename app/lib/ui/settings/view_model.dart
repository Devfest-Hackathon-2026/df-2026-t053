import 'dart:async';
import 'dart:developer';

import 'package:app/model/profile/model.dart';
import 'package:app/provider/profile/provider.dart';
import 'package:characters/characters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_model.freezed.dart';
part 'view_model.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    Profile? profile,
    @Default('') String nickname,
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool saved,
    String? errorMessage,
    String? nicknameError,
  }) = _SettingsState;
}

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  var _generation = 0;

  @override
  SettingsState build() {
    // 利用者ごとの接続が変わったら、旧応答を捨てて画面状態を作り直す。
    ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final generation = ++_generation;
    unawaited(Future<void>.microtask(() => _load(profileNotifier, generation)));
    return const SettingsState();
  }

  bool get canSave =>
      state.profile != null &&
      !state.isLoading &&
      !state.isSaving &&
      state.nickname.trim() != state.profile?.nickname;

  int get nicknameLength => state.nickname.trim().characters.length;

  /// 出典のURLはHTTPSの公開リンクだけを表示する。未登録・不正なURLは省く。
  String? sourceUrl(Credit credit) {
    final value = credit.url;
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri.toString();
  }

  Future<void> reload() async {
    if (state.isLoading || state.isSaving) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _load(ref.read(profileProvider.notifier), ++_generation);
  }

  Future<void> _load(ProfileNotifier profileNotifier, int generation) async {
    if (!ref.mounted || generation != _generation) return;
    try {
      final profile = await profileNotifier.getMyProfile();
      if (!ref.mounted || generation != _generation) return;
      state = SettingsState(
        profile: profile.copyWith(),
        nickname: profile.nickname,
        isLoading: false,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(_failure(error, stackTrace)),
      );
    }
  }

  void updateNickname(String value) {
    if (state.profile == null || state.isLoading || state.isSaving) return;
    state = state.copyWith(
      nickname: value,
      saved: false,
      errorMessage: null,
      nicknameError: null,
    );
  }

  Future<void> save() async {
    if (!canSave) return;
    final nickname = state.nickname.trim();
    // 入力補助だけを端末で行い、公開名の厳密な検証はサーバーを正とする。
    final String? inputError;
    if (nickname.isEmpty) {
      inputError = 'ニックネームを入力してください';
    } else if (nickname.characters.length > 20) {
      inputError = 'ニックネームは20文字以内で入力してください';
    } else {
      inputError = null;
    }
    if (inputError != null) {
      state = state.copyWith(nicknameError: inputError, saved: false);
      return;
    }
    final generation = ++_generation;
    state = state.copyWith(
      isSaving: true,
      saved: false,
      errorMessage: null,
      nicknameError: null,
    );
    try {
      final profile = await ref
          .read(profileProvider.notifier)
          .updateNickname(nickname);
      if (!ref.mounted || generation != _generation) return;
      state = SettingsState(
        profile: profile.copyWith(),
        nickname: profile.nickname,
        isLoading: false,
        saved: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || generation != _generation) return;
      final failure = _failure(error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        saved: false,
        nicknameError: failure.kind == .invalidNickname
            ? _message(failure)
            : null,
        errorMessage: failure.kind == .invalidNickname
            ? null
            : _message(failure),
      );
    }
  }

  String _message(ProfileFailure failure) => switch (failure.kind) {
    .invalidNickname => switch (failure.nicknameReason) {
      'EMPTY' => 'ニックネームを入力してください',
      'TOO_LONG' => 'ニックネームは20文字以内で入力してください',
      'TOO_LONG_CODE_UNITS' => '結合文字などが多すぎます。短い名前に変更してください',
      'CONTROL_CHARACTER' ||
      'FORMAT_CHARACTER' ||
      'INVALID_UNICODE' => '改行・制御文字・表示できない文字は使えません',
      _ => 'ニックネームの長さ・文字を確認してください',
    },
    .authentication => '認証を確認できません。設定を開き直してください',
    .unavailable => 'プロフィールを利用できません。時間をおいて再試行してください',
    .rejected => 'プロフィールの処理に失敗しました。再試行してください',
  };

  ProfileFailure _failure(Object error, StackTrace stackTrace) {
    if (error is ProfileFailure) return error;
    log(
      '設定画面のプロフィール処理に失敗しました',
      error: error.runtimeType,
      stackTrace: stackTrace,
    );
    return const ProfileFailure(.rejected);
  }
}
