import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

import '../../application/dto/profile_result.dart';
import '../../domain/exceptions.dart';
import '../../domain/services/nickname.dart';
import '../endpoint_call.dart';

Future<Profile> profileResponse(
  Session session,
  Future<ProfileResult> Function() call,
) {
  return guardUnclassifiedFailure(
    session: session,
    logLabel: 'プロフィール処理に失敗しました',
    action: () async {
      try {
        final result = await call();
        return Profile(nickname: result.nickname, anonymous: result.anonymous);
      } on InvalidNicknameException catch (error) {
        throw ApiException(
          code: .invalidArgument,
          reason: ApiErrorReasons.invalidNickname,
          message: 'ニックネームの長さ・文字を確認してください',
          fieldViolations: [
            FieldViolation(field: 'nickname', reason: error.reason),
          ],
        );
      } on ProfileMissingException {
        session.log('認証主体のプロフィールが欠落しています', level: .error);
        throw ApiException(
          code: .failedPrecondition,
          reason: ApiErrorReasons.profileNotInitialized,
          message: '認証を更新してからプロフィールを再取得してください',
        );
      }
    },
  );
}
