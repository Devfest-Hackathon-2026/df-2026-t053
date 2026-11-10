import 'package:app/model/assets/model.dart';

/// 写真取得の失敗を画面へ出す文言。URL と端末内パスは含めない。
String cluePhotoFailureMessage(AssetFailureKind kind) => switch (kind) {
  .storage => '写真を保存する空き容量がありません。',
  .invalidReference || .integrity => '写真を確認できませんでした。',
  .cancelled => '写真の取得を中止しました。',
  .unavailable => '写真を取得できませんでした。接続を確認して再度お試しください。',
};
