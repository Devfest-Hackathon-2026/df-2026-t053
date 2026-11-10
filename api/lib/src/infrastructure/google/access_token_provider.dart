import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// アクセストークンを取得できなかった（通信・HTTP の状態・応答の形・待ち上限）。
///
/// トークンの値も応答の本文も持たない。
class const AccessTokenException(final String reason) implements Exception {
  @override
  String toString() => 'AccessTokenException($reason)';
}

/// Google Cloud の API へ送る OAuth のアクセストークンを返す。
abstract interface class AccessTokenProvider() {
  /// 失敗したら [AccessTokenException]。
  Future<String> accessToken();
}

/// Cloud Run のメタデータサーバーから、実行サービスアカウントのトークンを取得する（ADC）。
///
/// 期限の 60 秒前までは使い回す。同時に呼ばれても、取得は 1 回にまとめる。
class MetadataServerAccessTokenProvider({
  HttpClient? httpClient,

  /// 取得先。テストでローカルの HTTP サーバーに向けるときだけ指定する。
  final Uri? endpoint,

  /// 1 回の取得の上限。
  final Duration timeout = const Duration(seconds: 5),
}) implements AccessTokenProvider {
  static final Uri _metadataServer = Uri.parse(
    'http://metadata.google.internal/computeMetadata/v1/'
    'instance/service-accounts/default/token',
  );

  final HttpClient _http =
      httpClient ??
      (HttpClient()..connectionTimeout = const Duration(seconds: 5));

  ({String token, DateTime refreshAfter})? _cached;
  Future<String>? _inFlight;

  @override
  Future<String> accessToken() {
    final cached = _cached;
    if (cached != null && DateTime.now().isBefore(cached.refreshAfter)) {
      return Future.value(cached.token);
    }
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<String> _fetch() async {
    final attempt = _Attempt();
    try {
      final (token, expiresIn) = await _request(attempt).timeout(
        timeout,
        onTimeout: () {
          // Future.timeout は元の要求を止めないので、ここで中断して接続を残さない。
          attempt.abandon();
          throw const AccessTokenException('メタデータサーバーの応答が待ち上限を過ぎた');
        },
      );
      _cached = (
        token: token,
        refreshAfter: DateTime.now().add(Duration(seconds: expiresIn - 60)),
      );
      return token;
    } on IOException {
      throw const AccessTokenException('メタデータサーバーに接続できない');
    } on FormatException {
      throw const AccessTokenException('メタデータサーバーの応答が JSON ではない');
    }
  }

  Future<(String, int)> _request(_Attempt attempt) async {
    final request = await _http.getUrl(endpoint ?? _metadataServer);
    attempt.request = request;
    if (attempt.abandoned) {
      // 接続している間に待ち上限を過ぎた。送らずに中断する。
      request.abort();
      throw const AccessTokenException('メタデータサーバーの応答が待ち上限を過ぎた');
    }
    request.headers.set('Metadata-Flavor', 'Google');
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw AccessTokenException('メタデータサーバーが HTTP ${response.statusCode}');
    }
    return switch (jsonDecode(text)) {
      {'access_token': final String token, 'expires_in': final int expiresIn} =>
        (token, expiresIn),
      _ => throw const AccessTokenException('メタデータサーバーの応答の形が違う'),
    };
  }

  void close() => _http.close(force: true);
}

/// 1 回の取得の状態。待ち上限を過ぎたら、送信中の要求を中断する。接続中なら、接続できた
/// 時点で中断する（`request` がまだないときの abort は効かないため）。
class _Attempt() {
  HttpClientRequest? request;
  bool abandoned = false;

  void abandon() {
    abandoned = true;
    request?.abort();
  }
}
