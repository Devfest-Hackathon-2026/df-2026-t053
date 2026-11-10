import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

/// 未分類の失敗を返すときの固定文。SQL・秘密・例外の文字列は入れない。
const unclassifiedFailureMessage = '処理を完了できませんでした';

/// 業務例外に変換できなかった失敗を internal / INTERNAL にする。
///
/// [ApiException] はそのまま返す。Serverpod が認証拒否の HTTP ステータスを決める
/// [EndpointDispatchException] も通す。メソッドに入る前の未認証を INTERNAL にすると、
/// アプリの認証更新と食い違う。それ以外（[StateError] や SQL の
/// SerializableException など）は型名とスタックトレースだけをログに残す。
/// 例外オブジェクトはログに出さない。文字列に SQL や内部経路が入ることがある。
/// ApiException へ置き換えると Serverpod は元の例外を記録しないため、フレームはここで残す。
Future<T> guardUnclassifiedFailure<T>({
  required Session session,
  required String logLabel,
  required Future<T> Function() action,
}) async {
  try {
    return await action();
  } on ApiException {
    rethrow;
  } on EndpointDispatchException {
    rethrow;
  } catch (error, stackTrace) {
    session.log(
      '$logLabel: ${error.runtimeType}',
      level: .error,
      stackTrace: stackTrace,
    );
    throw ApiException(
      code: .internal,
      reason: ApiErrorReasons.internal,
      message: unclassifiedFailureMessage,
    );
  }
}
