import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../domain/ports/guide_cancellation.dart';
import '../google/access_token_provider.dart';
import 'bounded_audio_json.dart';

/// Gemini の応答が成功でなかった（HTTP の状態が 200 以外）。本文は記録しない。
class const GeminiHttpException(final int status) implements Exception {
  @override
  String toString() => 'GeminiHttpException($status)';
}

/// 待ち上限を過ぎた。
class const GeminiTimeoutException() implements Exception {
  @override
  String toString() => 'GeminiTimeoutException';
}

/// Vertex AI の Gemini（Interactions・generateContent）へ、JSON の要求を 1 回送る。
/// 送り先は [VertexEndpoint]（`vertex_endpoint.dart`）で作る。
abstract interface class GeminiTransport() {
  /// 応答の JSON を返す。HTTP の失敗は [GeminiHttpException]、待ち上限は
  /// [GeminiTimeoutException]、トークンの取得の失敗は [AccessTokenException]、
  /// 取消は [GuideCancelledException]。
  Future<Map<String, Object?>> post(
    Uri uri,
    Map<String, Object?> body, {
    required Duration timeout,
    GuideCancellation? cancellation,
  });
}

/// 応答が上限（[HttpGeminiTransport.maxResponseBytes]）を超えた。読み込みを途中で止める。
class const GeminiResponseTooLargeException() implements Exception {
  @override
  String toString() => 'GeminiResponseTooLargeException';
}

/// 1 回の要求の状態。取消・タイムアウトで「やめる」と決めたら、接続中でも、接続できた
/// 時点で要求を中断して送らない（`request` がまだないときの abort は効かないため）。
class _Attempt() {
  HttpClientRequest? request;
  bool abandoned = false;

  void abandon() {
    abandoned = true;
    request?.abort();
  }
}

/// HTTPS で送る実装。要求ごとに [AccessTokenProvider] からトークンを取り、
/// `Authorization: Bearer` で送る（ADC）。トークンは URL・ログ・例外に載せない。
///
/// 共有の [HttpClient] の接続は、使われなければ既定の待ち時間で自然に閉じる。
class HttpGeminiTransport({
  required final AccessTokenProvider _tokens,
  HttpClient? httpClient,

  /// 応答の上限。音声の上限（WAV 10 MiB）を base64 にした大きさ（約 13.4 MiB）と JSON の
  /// 余白を見込む。音声は受信中に復号し、metadata・非音声応答は64 KiBで制限する。
  /// 超えたら、残りを読まずに止める。
  final int maxResponseBytes = 16 * 1024 * 1024,
}) implements GeminiTransport {
  final HttpClient _http =
      httpClient ??
      (HttpClient()..connectionTimeout = const Duration(seconds: 5));

  @override
  Future<Map<String, Object?>> post(
    Uri uri,
    Map<String, Object?> body, {
    required Duration timeout,
    GuideCancellation? cancellation,
  }) async {
    if (cancellation?.isCancelled ?? false) {
      throw const GuideCancelledException();
    }
    final attempt = _Attempt();
    final outcome = Completer<Map<String, Object?>>();
    void fail(Object error) {
      if (outcome.isCompleted) return;
      attempt.abandon();
      outcome.completeError(error);
    }

    final timer = Timer(timeout, () => fail(const GeminiTimeoutException()));
    // 取り消されたら、送信中の要求を中断する（上流の処理を止める）。終わった要求の後に
    // 取り消されても、outcome が完了済みなので何もしない（要求は下で手放している）。
    unawaited(
      cancellation?.whenCancelled.then(
        (_) => fail(const GuideCancelledException()),
      ),
    );
    unawaited(
      _send(uri, body, attempt).then(
        (value) {
          if (!outcome.isCompleted) outcome.complete(value);
        },
        onError: (Object error, StackTrace stack) {
          if (!outcome.isCompleted) outcome.completeError(error, stack);
        },
      ),
    );
    try {
      return await outcome.future;
    } finally {
      timer.cancel();
      // 取消の待ち受けが要求を持ち続けないよう手放す。
      attempt.request = null;
    }
  }

  Future<Map<String, Object?>> _send(
    Uri uri,
    Map<String, Object?> body,
    _Attempt attempt,
  ) async {
    final token = await _tokens.accessToken();
    if (attempt.abandoned) {
      // トークンを取っている間に、取消かタイムアウトが来た。接続せずにやめる。
      throw const GuideCancelledException();
    }
    final request = await _http.postUrl(uri);
    attempt.request = request;
    if (attempt.abandoned) {
      // 接続している間に、取消かタイムアウトが来た。送らずに中断する。
      request.abort();
      throw const GuideCancelledException();
    }
    request.headers
      ..set(HttpHeaders.authorizationHeader, 'Bearer $token')
      ..contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    final declared = response.contentLength;
    if (declared > maxResponseBytes) {
      request.abort();
      throw const GeminiResponseTooLargeException();
    }
    if (response.statusCode != 200) {
      request.abort();
      throw GeminiHttpException(response.statusCode);
    }
    if (body case {'generationConfig': {'responseModalities': ['AUDIO']}}) {
      final decoder = BoundedAudioJson();
      var count = 0;
      try {
        await for (final chunk in response) {
          count += chunk.length;
          if (count > maxResponseBytes) {
            throw const AudioJsonTooLargeException();
          }
          decoder.add(chunk);
        }
        return decoder.finish();
      } on AudioJsonTooLargeException {
        request.abort();
        throw const GeminiResponseTooLargeException();
      } on Object {
        request.abort();
        rethrow;
      }
    }
    final received = BytesBuilder(copy: false);
    await for (final chunk in response) {
      received.add(chunk);
      if (received.length > maxResponseBytes || received.length > 64 * 1024) {
        request.abort();
        throw const GeminiResponseTooLargeException();
      }
    }
    final decoded = jsonDecode(utf8.decode(received.takeBytes()));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Gemini の応答が JSON オブジェクトではない');
    }
    return decoded;
  }

  void close() => _http.close(force: true);
}

/// Gemini の呼び出しの、想定した失敗の分類。
enum GeminiCallFailure() {
  /// 待ち上限を過ぎた。
  timeout,

  /// HTTP の状態が 200 以外（認証・上限・サーバーの失敗など）。
  http,

  /// 応答が JSON として読めない。
  malformed,

  /// 接続・TLS・HTTP の通信の失敗。
  network,

  /// 応答が上限を超えた。
  tooLarge,

  /// アクセストークンを取得できなかった（メタデータサーバーの失敗など）。
  credentials,
}

class const GeminiCallException(
  final GeminiCallFailure kind, {
  final String? detail,
}) implements Exception {
  @override
  String toString() => 'GeminiCallException($kind)';
}

/// [transport] を呼び、想定した失敗だけを [GeminiCallException] に分類する。文生成・音声生成が
/// 共通に使う。取消（[GuideCancelledException]）はそのまま、想定外の例外（実装の不具合）は
/// 分類せずに投げ直す（固定文で隠さない）。
Future<Map<String, Object?>> callGemini(
  GeminiTransport transport,
  Uri uri,
  Map<String, Object?> body, {
  required Duration timeout,
  GuideCancellation? cancellation,
}) async {
  try {
    return await transport.post(
      uri,
      body,
      timeout: timeout,
      cancellation: cancellation,
    );
  } on AccessTokenException catch (e) {
    throw GeminiCallException(GeminiCallFailure.credentials, detail: e.reason);
  } on GeminiTimeoutException {
    throw const GeminiCallException(GeminiCallFailure.timeout);
  } on GeminiHttpException catch (e) {
    throw GeminiCallException(
      GeminiCallFailure.http,
      detail: 'HTTP ${e.status}',
    );
  } on GeminiResponseTooLargeException {
    throw const GeminiCallException(GeminiCallFailure.tooLarge);
  } on FormatException {
    throw const GeminiCallException(GeminiCallFailure.malformed);
  } on IOException catch (e) {
    // SocketException・HttpException・TlsException など、通信の失敗。
    throw GeminiCallException(
      GeminiCallFailure.network,
      detail: e.runtimeType.toString(),
    );
  }
}

/// 応答の `steps` のうち、最後の `model_output` の `content` を返す。なければ空。
List<Map<String, Object?>> lastModelOutput(Map<String, Object?> response) {
  final steps = response['steps'];
  if (steps is! List) return const [];
  for (final step in steps.reversed) {
    if (step is Map<String, Object?> && step['type'] == 'model_output') {
      final content = step['content'];
      if (content is! List) return const [];
      return [
        for (final item in content)
          if (item is Map<String, Object?>) item,
      ];
    }
  }
  return const [];
}

/// 応答の `errors` に、安全性による拒否を示すものがあるか。
bool looksRefused(Map<String, Object?> response) {
  final errors = response['errors'];
  if (errors is! List) return false;
  for (final error in errors) {
    if (error is! Map) continue;
    final text = '${error['code']} ${error['message']}'.toUpperCase();
    if (text.contains('SAFETY') ||
        text.contains('BLOCK') ||
        text.contains('PROHIBITED')) {
      return true;
    }
  }
  return false;
}

/// base64 を復号する。壊れていれば null。
Uint8List? decodeBase64(Object? value) {
  if (value is Uint8List) return value;
  if (value is! String || value.isEmpty) return null;
  try {
    return base64.decode(value);
  } on FormatException {
    return null;
  }
}
