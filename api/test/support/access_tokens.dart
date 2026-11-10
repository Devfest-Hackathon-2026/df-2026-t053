import 'package:photohunt_server/src/infrastructure/google/access_token_provider.dart';

/// 呼ばれたらテストを失敗させる取得元。エミュレーターへはトークンを送らないことを確かめる。
class NoAccessTokens() implements AccessTokenProvider {
  @override
  Future<String> accessToken() => throw StateError('エミュレーターではトークンを取得しない');
}

/// 常に失敗する取得元。呼ばれた回数を数える。
class FailingAccessTokens() implements AccessTokenProvider {
  int calls = 0;

  @override
  Future<String> accessToken() async {
    calls++;
    throw const AccessTokenException('メタデータサーバーに接続できない');
  }
}
