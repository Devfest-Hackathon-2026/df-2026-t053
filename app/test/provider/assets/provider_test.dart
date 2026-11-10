import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/assets/model.dart';
import 'package:app/provider/assets/provider.dart';
import 'package:app/provider/assets/validation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late HttpServer server;
  late ProviderContainer container;
  late AssetCacheSettings settings;
  late List<int> image;
  late List<int> otherImage;
  late Future<void> Function(HttpRequest) respond;
  late SecurityContext trust;
  var requests = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('photohunt-assets-');
    const fixtures = 'test/provider/assets/fixtures';
    final tls = SecurityContext()
      ..useCertificateChain('$fixtures/localhost-cert.pem')
      ..usePrivateKey('$fixtures/localhost-key.pem');
    trust = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificates('$fixtures/localhost-cert.pem');
    server = await HttpServer.bindSecure(InternetAddress.loopbackIPv4, 0, tls);
    settings = AssetCacheSettings(
      baseUrl: Uri.parse('https://localhost:${server.port}/bucket'),
    );
    image = await _png(const ui.Color(0xff112233));
    otherImage = await _png(const ui.Color(0xff445566));
    requests = 0;
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(image);
      await request.response.close();
    };
    server.listen((request) async {
      requests++;
      try {
        await respond(request);
      } on SocketException {
        /* cancelled client */
      }
    });
    container = ProviderContainer(
      overrides: [
        assetCacheDirectoryProvider.overrideWith((ref) async => directory),
        assetCacheSettingsProvider.overrideWith((ref) => settings),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await server.close(force: true);
    // 接続とファイルの解放が済んでからテスト専用領域を削除する。
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await directory.delete(recursive: true);
  });

  AssetRef asset([List<int>? bytes, String name = 'photo']) {
    final content = bytes ?? image;
    final hash = sha256.convert(content).toString();
    return AssetRef(
      url: '${settings.baseUrl}/media/$hash/$name.png',
      sha256: hash,
      byteLength: content.length,
      contentType: 'image/png',
    );
  }

  AssetsNotifier notifier() => container.read(assetsProvider.notifier);
  void check(String name, Future<void> Function() body) => test(
    name,
    () => HttpOverrides.runWithHttpOverrides(body, _TrustedHttp(trust)),
  );

  check('APIなしでHTTPS取得し、サイズ・SHA・画像デコード確認後に確定する', () async {
    final lease = notifier().acquire(asset());
    final progress = <AssetProgress>[];
    final subscription = lease.changes.listen(progress.add);
    final file = await lease.file;
    expect(await file.readAsBytes(), image);
    expect(file.path, endsWith('/${asset().sha256}/photo.png'));
    expect(
      lease.progress,
      AssetProgress(received: image.length, total: image.length),
    );
    expect(progress, isNotEmpty);
    expect(await _parts(directory), isEmpty);
    lease.release();
    await subscription.cancel();
    final cached = notifier().acquire(asset());
    expect((await cached.file).path, file.path);
    expect(requests, 1);
    cached.release();
  });

  check('不正参照・モデル・別origin・クエリ・経路・上限超過を通信前に拒否', () async {
    final valid = asset();
    for (final bad in [
      valid.copyWith(url: valid.url.replaceFirst('https:', 'http:')),
      valid.copyWith(url: valid.url.replaceFirst('localhost', 'example.com')),
      valid.copyWith(url: '${valid.url}?token=secret'),
      valid.copyWith(url: '${valid.url}#fragment'),
      valid.copyWith(url: valid.url.replaceFirst('/photo.png', '/model.png')),
      valid.copyWith(url: valid.url.replaceFirst('/photo.png', '/%70hoto.png')),
      valid.copyWith(
        url: valid.url.replaceFirst('/photo.png', '/../photo.png'),
      ),
      valid.copyWith(sha256: 'invalid'),
      valid.copyWith(byteLength: 0),
      valid.copyWith(byteLength: maxImageBytes + 1),
      valid.copyWith(contentType: 'model/gltf-binary'),
    ]) {
      expect(
        () => notifier().acquire(bad),
        throwsA(const AssetFailure(.invalidReference)),
      );
    }
    expect(requests, 0);
  });

  check('異なるoriginへのredirectに追従せず未確定ファイルを消す', () async {
    respond = (request) async {
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set(
        HttpHeaders.locationHeader,
        'https://example.com/secret',
      );
      await request.response.close();
    };
    final lease = notifier().acquire(asset());
    await expectLater(lease.file, throwsA(const AssetFailure(.integrity)));
    lease.release();
    expect(requests, 1);
    expect(await _parts(directory), isEmpty);
  });

  check('SHA不一致は保存せず、同じ参照で再試行できる', () async {
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(List.filled(image.length, 0));
      await request.response.close();
    };
    final first = notifier().acquire(asset());
    await expectLater(first.file, throwsA(const AssetFailure(.integrity)));
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(image);
      await request.response.close();
    };
    final retry = notifier().acquire(asset());
    first.release();
    expect(await (await retry.file).readAsBytes(), image);
    retry.release();
    expect(requests, 2);
  });

  check('chunked応答も受信中のバイト上限を超えたら中断する', () async {
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add([...image, 1]);
      await request.response.close();
    };
    final lease = notifier().acquire(asset());
    await expectLater(lease.file, throwsA(const AssetFailure(.integrity)));
    lease.release();
    expect(await _parts(directory), isEmpty);
  });

  check('正しいSHAでも画像として壊れていたら確定しない', () async {
    final broken = image.sublist(0, 16);
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(broken);
      await request.response.close();
    };
    final lease = notifier().acquire(asset(broken));
    await expectLater(lease.file, throwsA(isA<AssetFailure>()));
    lease.release();
    expect(await _parts(directory), isEmpty);
  });

  check('同じ取得を共有し、一方の取消で別の画面を止めない', () async {
    final started = Completer<void>();
    final resume = Completer<void>();
    respond = (request) async {
      started.complete();
      await resume.future;
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(image);
      await request.response.close();
    };
    final old = notifier().acquire(asset());
    final current = notifier().acquire(asset());
    await started.future;
    old.release();
    await expectLater(old.file, throwsA(const AssetFailure(.cancelled)));
    resume.complete();
    expect(await (await current.file).readAsBytes(), image);
    expect(requests, 1);
    current.release();
  });

  check('全員取消は待機中のジョブも中断し、新しい試行を古いreleaseで消さない', () async {
    final first = notifier().acquire(asset());
    first.release();
    await expectLater(first.file, throwsA(const AssetFailure(.cancelled)));
    final retry = notifier().acquire(asset());
    first.release();
    expect(await (await retry.file).readAsBytes(), image);
    retry.release();
  });

  check('同じSHAに異なる型・サイズを宣言した同時要求を拒否', () async {
    final lease = notifier().acquire(asset());
    expect(
      () => notifier().acquire(asset().copyWith(byteLength: image.length + 1)),
      throwsA(const AssetFailure(.invalidReference)),
    );
    await lease.file;
    lease.release();
  });

  check('再利用前にも整合性を調べ、破損キャッシュを再取得する', () async {
    final lease = notifier().acquire(asset());
    final file = await lease.file;
    lease.release();
    await file.writeAsBytes(List.filled(image.length, 0));
    final retry = notifier().acquire(asset());
    expect(await (await retry.file).readAsBytes(), image);
    expect(requests, 2);
    retry.release();
  });

  check('使用中は削除せず容量不足を返し、解放後は古い素材を整理', () async {
    settings = settings.copyWith(
      capacityBytes: image.length + otherImage.length - 1,
    );
    final current = notifier().acquire(asset());
    final file = await current.file;
    final other = notifier().acquire(asset(otherImage));
    await expectLater(other.file, throwsA(const AssetFailure(.storage)));
    expect(await file.exists(), isTrue);
    other.release();
    current.release();
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(otherImage);
      await request.response.close();
    };
    final retry = notifier().acquire(asset(otherImage));
    await retry.file;
    expect(await file.exists(), isFalse);
    retry.release();
  });

  check('並行取得は最大2本に制限し、3本目は待機する', () async {
    var active = 0;
    var peak = 0;
    final twoStarted = Completer<void>();
    final resume = Completer<void>();
    respond = (request) async {
      active++;
      if (active > peak) peak = active;
      if (active == 2 && !twoStarted.isCompleted) twoStarted.complete();
      await resume.future;
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(
        request.uri.path.contains(sha256.convert(image).toString())
            ? image
            : otherImage,
      );
      await request.response.close();
      active--;
    };
    final leases = [
      notifier().acquire(asset()),
      notifier().acquire(asset(otherImage, 'map')),
      notifier().acquire(asset(image, 'map')),
    ];
    await twoStarted.future;
    expect(requests, 2);
    resume.complete();
    for (final lease in leases) {
      await lease.file;
      lease.release();
    }
    expect(peak, 2);
  });

  check('全体期限後は待たずに失敗し、partを残さない', () async {
    settings = settings.copyWith(
      totalTimeout: const Duration(milliseconds: 60),
    );
    final resume = Completer<void>();
    respond = (request) async {
      await resume.future;
      await request.response.close();
    };
    final lease = notifier().acquire(asset());
    await expectLater(lease.file, throwsA(const AssetFailure(.unavailable)));
    resume.complete();
    lease.release();
  });

  check('取得中の全員取消で切断し、取消直後でも再試行できる', () async {
    final started = Completer<void>();
    final resume = Completer<void>();
    respond = (request) async {
      if (!started.isCompleted) {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(image.sublist(0, 8));
        await request.response.flush();
        started.complete();
        await resume.future;
      } else {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(image);
      }
      await request.response.close();
    };
    final first = notifier().acquire(asset());
    await started.future;
    first.release();
    await expectLater(first.file, throwsA(const AssetFailure(.cancelled)));
    final retry = notifier().acquire(asset());
    resume.complete();
    await retry.file;
    retry.release();
    expect(requests, 2);
  });

  check('無受信期限で失敗し部分ファイルを確定しない', () async {
    settings = settings.copyWith(idleTimeout: const Duration(milliseconds: 50));
    final resume = Completer<void>();
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(image.sublist(0, 8));
      await request.response.flush();
      await resume.future;
      await request.response.close();
    };
    final lease = notifier().acquire(asset());
    await expectLater(lease.file, throwsA(const AssetFailure(.unavailable)));
    resume.complete();
    lease.release();
    expect(await _parts(directory), isEmpty);
  });

  check('型の偽装と最大辺4096px超過はSHAが正しくても拒否', () async {
    final large = await _png(const ui.Color(0xff000000), width: 4097);
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(large);
      await request.response.close();
    };
    final lease = notifier().acquire(asset(large));
    await expectLater(lease.file, throwsA(const AssetFailure(.integrity)));
    lease.release();
    final disguised = asset().copyWith(
      url: asset().url.replaceFirst('.png', '.jpg'),
      contentType: 'image/jpeg',
    );
    respond = (request) async {
      request.response.headers.contentType = ContentType('image', 'jpeg');
      request.response.add(image);
      await request.response.close();
    };
    final fake = notifier().acquire(disguised);
    await expectLater(fake.file, throwsA(const AssetFailure(.integrity)));
    fake.release();
  });

  check('Provider破棄は取得中のジョブと待機者を取り消す', () async {
    final started = Completer<void>();
    final resume = Completer<void>();
    respond = (request) async {
      started.complete();
      await resume.future;
      await request.response.close();
    };
    final lease = notifier().acquire(asset());
    await started.future;
    container.dispose();
    await expectLater(lease.file, throwsA(const AssetFailure(.cancelled)));
    resume.complete();
    lease.release();
  });
}

Future<List<int>> _png(ui.Color color, {int width = 2}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(color, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, 2);
  picture.dispose();
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('PNG encoding failed');
    return bytes.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

Future<List<String>> _parts(Directory directory) async => [
  await for (final entry in directory.list(recursive: true))
    if (entry.path.endsWith('.part') && entry is File) entry.path,
];

class _TrustedHttp(final SecurityContext trust) extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(trust)
        ..badCertificateCallback = (certificate, host, port) =>
            host == 'localhost' &&
            certificate.pem.trim() ==
                File('test/provider/assets/fixtures/localhost-cert.pem')
                    .readAsStringSync()
                    .trim();
}
