import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../../google/access_token_provider.dart';

/// 前提条件（ifGenerationMatch）が合わなかった（HTTP 412）。
class const GcsPreconditionFailed(final String object) implements Exception {
  @override
  String toString() => 'GcsPreconditionFailed($object)';
}

/// GCS の通信・認証・権限などの失敗。
class const GcsException(final String message) implements Exception {
  @override
  String toString() => 'GcsException($message)';
}

/// 所有権オブジェクトに必要な、GCS の条件付き操作だけを持つ最小の client。
abstract interface class GcsObjectClient() {
  /// 存在しないときだけ作る（`ifGenerationMatch=0`）。返すのは作られた generation。
  /// 既にあれば [GcsPreconditionFailed]。
  Future<String> createIfAbsent(String bucket, String object, String content);

  /// [generation] が一致するときだけ消す。違う・既に無いときは [GcsPreconditionFailed]
  /// （誰かが解除した可能性があるため成功にしない）。
  Future<void> deleteIfGeneration(
    String bucket,
    String object,
    String generation,
  );

  /// 現在の generation と内容。無ければ null。運用者の確認用。
  Future<({String generation, String content})?> read(
    String bucket,
    String object,
  );
}

/// 公開素材（#26）の配置に必要な、GCS のバイト列の操作だけを持つ client。
abstract interface class GcsMediaObjectClient() {
  /// バイト列を、存在しないときだけ作る（`ifGenerationMatch=0`）。
  /// 既にあれば [GcsPreconditionFailed]。
  ///
  /// [cacheControl] はオブジェクトのメタデータに付け、公開配信の応答の `Cache-Control` になる。
  Future<void> createBytesIfAbsent(
    String bucket,
    String object,
    List<int> bytes,
    String contentType, {
    required String cacheControl,
  });

  /// オブジェクトのサイズ・MD5（base64）・Content-Type。無ければ null。MD5 を返さない場合
  /// （複合オブジェクトなど）は md5Base64 が null。
  Future<({int size, String? md5Base64, String? contentType})?> readMetadata(
    String bucket,
    String object,
  );

  /// オブジェクトの内容。無ければ null。
  Future<List<int>?> readBytes(String bucket, String object);
}

/// GCS の JSON API を直接呼ぶ実装。
///
/// - [emulatorHost]（`STORAGE_EMULATOR_HOST`）があればそこへ認証なしで送る
///   （[_tokens] は呼ばない）。
/// - なければ `https://storage.googleapis.com` へ、[_tokens] のトークンで送る。
class HttpGcsObjectClient({
  final String? emulatorHost,
  HttpClient? httpClient,

  /// GCS へ送るアクセストークンの取得元（本番は Cloud Run のメタデータサーバー）。
  required final AccessTokenProvider _tokens,

  /// 1 回の要求（トークンの取得・接続・送信・受信）の上限。起動・終了の途中で止まり続けないため。
  final Duration requestTimeout = const Duration(seconds: 20),
}) implements GcsObjectClient, GcsMediaObjectClient {
  final HttpClient _http =
      httpClient ??
      (HttpClient()..connectionTimeout = const Duration(seconds: 5));

  String get _base {
    final host = emulatorHost;
    if (host == null || host.isEmpty) return 'https://storage.googleapis.com';
    final trimmed = host.endsWith('/')
        ? host.substring(0, host.length - 1)
        : host;
    return trimmed.contains('://') ? trimmed : 'http://$trimmed';
  }

  bool get _useEmulator => emulatorHost != null && emulatorHost!.isNotEmpty;

  @override
  Future<String> createIfAbsent(
    String bucket,
    String object,
    String content,
  ) async {
    final uri =
        Uri.parse('$_base/upload/storage/v1/b/${Uri.encodeComponent(bucket)}/o')
            .replace(
              queryParameters: {
                'uploadType': 'media',
                'name': object,
                'ifGenerationMatch': '0',
              },
            );
    final response = await _send('POST', uri, body: content);
    if (response.status == 412) throw GcsPreconditionFailed(object);
    _expectOk(response, 'create $object', ok: const [200]);
    final generation = _json(response.body)['generation'];
    if (generation is! String || generation.isEmpty) {
      throw const GcsException('作成の応答に generation がない');
    }
    return generation;
  }

  @override
  Future<void> deleteIfGeneration(
    String bucket,
    String object,
    String generation,
  ) async {
    final uri =
        Uri.parse(
          '$_base/storage/v1/b/${Uri.encodeComponent(bucket)}/o/'
          '${Uri.encodeComponent(object)}',
        ).replace(
          // fake-gcs-server は DELETE の ifGenerationMatch を無視する（1.56.1 で確認）。
          // generation を併記すると、違う世代の削除は 404 になる。実 GCS では併記しても同じ意味。
          queryParameters: {
            'ifGenerationMatch': generation,
            'generation': generation,
          },
        );
    final response = await _send('DELETE', uri);
    // 指定した世代がもう無いのも「条件を満たさない」として扱う。
    if (response.status == 412 || response.status == 404) {
      throw GcsPreconditionFailed(object);
    }
    _expectOk(response, 'delete $object', ok: const [200, 204]);
  }

  @override
  Future<({String generation, String content})?> read(
    String bucket,
    String object,
  ) async {
    final meta = Uri.parse(
      '$_base/storage/v1/b/${Uri.encodeComponent(bucket)}/o/'
      '${Uri.encodeComponent(object)}',
    );
    final metaResponse = await _send('GET', meta);
    if (metaResponse.status == 404) return null;
    _expectOk(metaResponse, 'get $object', ok: const [200]);
    final generation = _json(metaResponse.body)['generation'];
    if (generation is! String) {
      throw const GcsException('取得の応答に generation がない');
    }
    final media = meta.replace(
      queryParameters: {'alt': 'media', 'generation': generation},
    );
    final mediaResponse = await _send('GET', media);
    _expectOk(mediaResponse, 'get media $object', ok: const [200]);
    return (generation: generation, content: mediaResponse.body);
  }

  @override
  Future<void> createBytesIfAbsent(
    String bucket,
    String object,
    List<int> bytes,
    String contentType, {
    required String cacheControl,
  }) async {
    // メタデータ（名前・Content-Type・Cache-Control）と内容を 1 回で送る multipart アップロード。
    // `uploadType=media` では Content-Type しか指定できない（#101）。
    if (contentType.contains('\r') || contentType.contains('\n')) {
      // 部分のヘッダー行へそのまま書くので、改行で別のヘッダーを差し込ませない。
      throw ArgumentError.value(contentType, 'contentType', '改行を含められない');
    }
    final uri =
        Uri.parse('$_base/upload/storage/v1/b/${Uri.encodeComponent(bucket)}/o')
            .replace(
              queryParameters: {
                'uploadType': 'multipart',
                'ifGenerationMatch': '0',
              },
            );
    final boundary = _multipartBoundary();
    final metadata = jsonEncode({
      'name': object,
      'contentType': contentType,
      'cacheControl': cacheControl,
    });
    final body = BytesBuilder(copy: false)
      ..add(
        utf8.encode(
          '--$boundary\r\n'
          'Content-Type: application/json; charset=UTF-8\r\n\r\n'
          '$metadata\r\n'
          '--$boundary\r\n'
          'Content-Type: $contentType\r\n\r\n',
        ),
      )
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--\r\n'));
    final response = await _send(
      'POST',
      uri,
      bytes: body.takeBytes(),
      contentType: ContentType(
        'multipart',
        'related',
        parameters: {'boundary': boundary},
      ),
    );
    if (response.status == 412) throw GcsPreconditionFailed(object);
    _expectOk(response, 'create $object', ok: const [200]);
  }

  @override
  Future<({int size, String? md5Base64, String? contentType})?> readMetadata(
    String bucket,
    String object,
  ) async {
    final uri = Uri.parse(
      '$_base/storage/v1/b/${Uri.encodeComponent(bucket)}/o/'
      '${Uri.encodeComponent(object)}',
    );
    final response = await _send('GET', uri);
    if (response.status == 404) return null;
    _expectOk(response, 'get $object', ok: const [200]);
    final json = _json(response.body);
    // JSON API の size は文字列。
    final size = int.tryParse('${json['size']}');
    if (size == null) throw const GcsException('取得の応答に size がない');
    final md5 = json['md5Hash'];
    final type = json['contentType'];
    return (
      size: size,
      md5Base64: md5 is String && md5.isNotEmpty ? md5 : null,
      contentType: type is String ? type : null,
    );
  }

  @override
  Future<List<int>?> readBytes(String bucket, String object) async {
    final uri = Uri.parse(
      '$_base/storage/v1/b/${Uri.encodeComponent(bucket)}/o/'
      '${Uri.encodeComponent(object)}',
    ).replace(queryParameters: {'alt': 'media'});
    final response = await _send('GET', uri);
    if (response.status == 404) return null;
    _expectOk(response, 'get media $object', ok: const [200]);
    return response.bytes;
  }

  void close() => _http.close(force: true);

  /// multipart の区切り。内容に偶然現れないよう、推測できない 32 桁の 16 進にする。
  String _multipartBoundary() {
    final random = Random.secure();
    final hex = [
      for (var i = 0; i < 16; i++)
        random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ].join();
    return 'photohunt-$hex';
  }

  Map<String, Object?> _json(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // 下で例外にする。
    }
    throw const GcsException('GCS の応答が JSON オブジェクトではない');
  }

  void _expectOk(_Response response, String what, {required List<int> ok}) {
    if (ok.contains(response.status)) return;
    throw GcsException('$what が HTTP ${response.status} を返した');
  }

  Future<_Response> _send(
    String method,
    Uri uri, {
    String? body,
    List<int>? bytes,
    ContentType? contentType,
  }) async {
    try {
      return await _sendOnce(
        method,
        uri,
        body: body,
        bytes: bytes,
        contentType: contentType,
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw GcsException('GCS への要求がタイムアウトした: $method ${uri.path}');
    }
  }

  Future<_Response> _sendOnce(
    String method,
    Uri uri, {
    String? body,
    List<int>? bytes,
    ContentType? contentType,
  }) async {
    // 接続を開く前に取る。取得に失敗したときに、開いた接続を残さない。
    final token = _useEmulator ? null : await _accessToken();
    try {
      final request = await _http.openUrl(method, uri);
      if (token != null) {
        request.headers.set('Authorization', 'Bearer $token');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(body);
      }
      if (bytes != null) {
        request.headers.contentType = contentType;
        request.contentLength = bytes.length;
        request.add(bytes);
      }
      final response = await request.close();
      // 受信した塊をそのままつなぐ（List<int> に 1 バイトずつ足すと、素材 5 MiB で数十 MB 使う）。
      final received = BytesBuilder(copy: false);
      await response.forEach(received.add);
      return _Response(response.statusCode, received.takeBytes());
    } on GcsException {
      rethrow;
    } on Object catch (e) {
      throw GcsException('GCS への通信に失敗した: $e');
    }
  }

  /// 呼び出し側は GCS の失敗を [GcsException] として扱うので、取得の失敗も変換する。
  /// 使い回し・同時要求のまとめ・待ち上限は [AccessTokenProvider] の実装が持つ。
  Future<String> _accessToken() async {
    try {
      return await _tokens.accessToken();
    } on AccessTokenException catch (e) {
      throw GcsException('アクセストークンを取得できない: ${e.reason}');
    }
  }
}

/// 応答の状態と本文。所有権オブジェクトは JSON（[body]）、素材はバイト列（[bytes]）で読む。
class const _Response(final int status, final List<int> bytes) {
  // 壊れた UTF-8 でも例外にせず、JSON の解釈（_json）で GcsException にする。
  String get body => utf8.decode(bytes, allowMalformed: true);
}
