import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/assets/model.dart';
import 'package:crypto/crypto.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

const _fixtures = 'test/provider/assets/fixtures';

/// 手がかり写真の取得テスト用。localhost の自己署名 HTTPS で PNG を返す。
class ServedCluePhoto {
  ServedCluePhoto._({
    required this.server,
    required this.settings,
    required this.trust,
    required this._images,
  });

  final HttpServer server;
  final AssetCacheSettings settings;
  final SecurityContext trust;
  final Map<String, List<int>> _images;
  var requests = 0;

  /// 次の応答をこの回数だけ 503 にする。通信回復後の再試行に使う。
  var failTimes = 0;

  AssetRef add(List<int> bytes) {
    final hash = sha256.convert(bytes).toString();
    _images[hash] = bytes;
    return AssetRef(
      url: '${settings.baseUrl}/media/$hash/photo.png',
      sha256: hash,
      byteLength: bytes.length,
      contentType: 'image/png',
    );
  }

  Future<void> close() => server.close(force: true);
}

Future<List<int>> solidPng(ui.Color color) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(color, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  picture.dispose();
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('PNG encoding failed');
    return bytes.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

Future<ServedCluePhoto> serveCluePhoto() async {
  final tls = SecurityContext()
    ..useCertificateChain('$_fixtures/localhost-cert.pem')
    ..usePrivateKey('$_fixtures/localhost-key.pem');
  final trust = SecurityContext(withTrustedRoots: true)
    ..setTrustedCertificates('$_fixtures/localhost-cert.pem');
  final server = await HttpServer.bindSecure(
    InternetAddress.loopbackIPv4,
    0,
    tls,
  );
  final images = <String, List<int>>{};
  final served = ServedCluePhoto._(
    server: server,
    settings: AssetCacheSettings(
      baseUrl: Uri.parse('https://localhost:${server.port}/bucket'),
    ),
    trust: trust,
    images: images,
  );
  server.listen((request) async {
    served.requests++;
    if (served.failTimes > 0) {
      served.failTimes--;
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      return;
    }
    final segments = request.uri.pathSegments;
    final hash = segments.length >= 3 ? segments[segments.length - 2] : '';
    final bytes = images[hash];
    try {
      if (bytes == null) {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(bytes);
      }
      await request.response.close();
    } on SocketException {
      // 取得取消で切れた接続。
    }
  });
  return served;
}

class LocalhostTrust extends HttpOverrides {
  LocalhostTrust(this.trust);

  final SecurityContext trust;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(trust)
        ..badCertificateCallback = (certificate, host, port) =>
            host == 'localhost' &&
            certificate.pem.trim() ==
                File('$_fixtures/localhost-cert.pem').readAsStringSync().trim();
}
