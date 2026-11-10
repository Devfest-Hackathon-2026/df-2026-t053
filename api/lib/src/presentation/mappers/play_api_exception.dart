import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

import '../../domain/exceptions.dart';

/// [PlayException] を公開の [ApiException] にする。play と guide の共通の変換表。
///
/// [message] を渡したとき（ガイド）は code / reason / retryAfterSeconds だけをこの表に
/// 合わせ、説明文は呼び出し側の固定文のままにする。
ApiException playApiException(
  Session session,
  PlayException error, {
  String? message,
}) {
  switch (error.reason) {
    case .invalidRequest:
      return ApiException(
        code: .invalidArgument,
        reason: ApiErrorReasons.invalidRequest,
        message: message ?? '版とモードを確認してください',
      );
    case .requestIdReused:
      return ApiException(
        code: .invalidArgument,
        reason: ApiErrorReasons.requestIdReused,
        message: message ?? '同じ requestId で別の内容が届きました',
      );
    case .revisionNotFound:
      return ApiException(
        code: .notFound,
        reason: ApiErrorReasons.revisionNotFound,
        message: message ?? '指定された出題版が見つかりません',
      );
    case .revisionNotPlayable:
      return ApiException(
        code: .failedPrecondition,
        reason: ApiErrorReasons.revisionNotPlayable,
        message: message ?? 'この出題版は新規に開始できません。出題を更新してください',
      );
    case .sessionRateLimited:
      return ApiException(
        code: .resourceExhausted,
        reason: ApiErrorReasons.sessionRateLimited,
        message: message ?? '開始の回数が上限に達しました。しばらくしてからやり直してください',
        retryAfterSeconds: error.retryAfterSeconds,
      );
    case .sessionNotFound:
      return ApiException(
        code: .notFound,
        reason: ApiErrorReasons.playSessionNotFound,
        message: message ?? '指定されたプレイが見つかりません',
      );
    case .notSessionOwner:
      return ApiException(
        code: .permissionDenied,
        reason: ApiErrorReasons.notSessionOwner,
        message: message ?? 'このプレイにはアクセスできません',
      );
    case .profileNotInitialized:
      session.log('認証主体のプロフィールが欠落しています', level: .error);
      return ApiException(
        code: .failedPrecondition,
        reason: ApiErrorReasons.profileNotInitialized,
        message: message ?? '認証を更新してから再取得してください',
      );
  }
}
