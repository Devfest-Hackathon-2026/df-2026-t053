import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/infrastructure/media/image_probe.dart';
import 'package:test/test.dart';

import 'seed_fixture.dart';

Uint8List _bytes(List<int> b) => Uint8List.fromList(b);

/// 寸法だけを持つ最小の JPEG（SOI・APPn・SOF0・EOI）。
Uint8List _jpeg({required int width, required int height, List<int>? app1}) =>
    _bytes([
      0xFF, 0xD8, //
      if (app1 != null) ...[
        0xFF,
        0xE1,
        (app1.length + 2) >> 8,
        (app1.length + 2) & 0xFF,
        ...app1,
      ],
      0xFF, 0xC0, 0x00, 0x11, 0x08, //
      height >> 8, height & 0xFF, width >> 8, width & 0xFF, //
      0x03, 1, 0x22, 0, 2, 0x11, 1, 3, 0x11, 1, //
      ..._scan,
      0xFF, 0xD9,
    ]);

/// SOS（成分 1 つ）と、FF 00（詰め物）を含む短いスキャンデータ。
const _scan = [
  0xFF, 0xDA, 0x00, 0x08, 1, 1, 0, 0, 0x3F, 0, //
  0x12, 0xFF, 0x00, 0x34,
];

List<int> _le32(int v) => [
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  v >> 24,
];
List<int> _le24(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF];

Uint8List _webpVp8x({
  required int width,
  required int height,
  bool exif = false,
}) {
  final chunks = <int>[
    ...'VP8X'.codeUnits, ..._le32(10), //
    exif ? 0x08 : 0x00, 0, 0, 0, ..._le24(width - 1), ..._le24(height - 1),
    // 画像データ（VP8L の最小の 5 バイト。寸法は VP8X の値を使う）。
    ...'VP8L'.codeUnits, ..._le32(5), 0x2F, 0, 0, 0, 0, 0,
    if (exif) ...[...'EXIF'.codeUnits, ..._le32(2), 0, 0],
  ];
  return _bytes([
    ...'RIFF'.codeUnits,
    ..._le32(4 + chunks.length),
    ...'WEBP'.codeUnits,
    ...chunks,
  ]);
}

void main() {
  test('PNG の寸法を読む（サンプルの会場図）', () {
    final probe = probeImage(
      File('${sampleDir.revision}/map.png').readAsBytesSync(),
    )!;
    expect(probe.contentType, 'image/png');
    expect((probe.width, probe.height), (960, 960));
    expect(probe.hasMetadata, isFalse);
  });

  test('PNG の eXIf チャンクを検出する', () {
    final png = File('${sampleDir.revision}/photo.png').readAsBytesSync();
    // IHDR（8 + 25 バイト）の直後に eXIf を差し込む。CRC は検査しない。
    final withExif = _bytes([
      ...png.sublist(0, 33),
      0, 0, 0, 4, ...'eXIf'.codeUnits, 0, 0, 0, 0, 0, 0, 0, 0, //
      ...png.sublist(33),
    ]);
    expect(probeImage(withExif)!.hasMetadata, isTrue);
  });

  test('JPEG の寸法と EXIF を読む', () {
    final plain = probeImage(_jpeg(width: 1200, height: 800))!;
    expect(plain.contentType, 'image/jpeg');
    expect((plain.width, plain.height), (1200, 800));
    expect(plain.hasMetadata, isFalse);

    final exif = probeImage(
      _jpeg(width: 10, height: 20, app1: [...'Exif'.codeUnits, 0, 0, 1, 2]),
    )!;
    expect(exif.hasMetadata, isTrue);
  });

  test('WebP（VP8X）の寸法と EXIF を読む', () {
    final plain = probeImage(_webpVp8x(width: 4097, height: 300))!;
    expect(plain.contentType, 'image/webp');
    expect((plain.width, plain.height), (4097, 300));
    expect(plain.hasMetadata, isFalse);
    expect(
      probeImage(_webpVp8x(width: 1, height: 1, exif: true))!.hasMetadata,
      isTrue,
    );
  });

  test('PNG のテキストチャンク（ImageMagick 式の EXIF など）をメタデータとして検出する', () {
    final png = File('${sampleDir.revision}/photo.png').readAsBytesSync();
    for (final type in const ['tEXt', 'zTXt', 'iTXt']) {
      final withText = _bytes([
        ...png.sublist(0, 33),
        0, 0, 0, 4, ...type.codeUnits, 0, 0, 0, 0, 0, 0, 0, 0, //
        ...png.sublist(33),
      ]);
      expect(probeImage(withText)!.hasMetadata, isTrue, reason: type);
    }
  });

  test('JPEG の APP13・拡張 XMP・コメントをメタデータとして検出する', () {
    for (final marker in const [0xE1, 0xE3, 0xED, 0xFE]) {
      final bytes = _bytes([
        0xFF, 0xD8, //
        0xFF, marker, 0x00, 0x06, 1, 2, 3, 4, //
        0xFF, 0xC0, 0x00, 0x11, 0x08, 0, 20, 0, 10, //
        0x03, 1, 0x22, 0, 2, 0x11, 1, 3, 0x11, 1, //
        ..._scan,
        0xFF, 0xD9,
      ]);
      expect(probeImage(bytes)!.hasMetadata, isTrue, reason: '$marker');
    }
  });

  test('プログレッシブ JPEG の、最初のスキャンの後ろにあるメタデータも検出する', () {
    final plain = _jpeg(width: 10, height: 20);
    expect(probeImage(plain)!.hasMetadata, isFalse);
    for (final marker in const [0xE1, 0xFE]) {
      final bytes = _bytes([
        ...plain.sublist(0, plain.length - 2), // EOI を外す
        0xFF, marker, 0x00, 0x04, 1, 2, // 2 つ目のスキャンの前のセグメント
        ..._scan,
        0xFF, 0xD9,
      ]);
      expect(probeImage(bytes)!.hasMetadata, isTrue, reason: '$marker');
    }
  });

  test('途中で切れた PNG・JPEG・WebP は null', () {
    final png = File('${sampleDir.revision}/photo.png').readAsBytesSync();
    expect(probeImage(png.sublist(0, png.length - 12)), isNull); // IEND がない
    expect(probeImage(png.sublist(0, 100)), isNull); // チャンクの途中
    final jpeg = _jpeg(width: 10, height: 20);
    // 画像データ（SOS）がなく、EOI だけがある。
    expect(
      probeImage(
        _bytes([
          0xFF, 0xD8, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0, 20, 0, 10, //
          0x03, 1, 0x22, 0, 2, 0x11, 1, 3, 0x11, 1, 0xFF, 0xD9,
        ]),
      ),
      isNull,
    );
    // スキャンの途中で切れている。
    expect(probeImage(jpeg.sublist(0, jpeg.length - 3)), isNull);
    expect(probeImage(jpeg.sublist(0, jpeg.length - 2)), isNull); // EOI がない
    expect(probeImage(jpeg.sublist(0, 12)), isNull); // セグメントの途中
    // 画像データ（SOS の後）の途中で切れたもの。
    final scan = _bytes([
      ...jpeg.sublist(0, jpeg.length - 2),
      0xFF, 0xDA, 0x00, 0x08, 1, 1, 0, 0, 0x3F, 0, 0x12, 0x34, //
    ]);
    expect(probeImage(scan), isNull);
    expect(probeImage(_bytes([...scan, 0xFF, 0xD9])), isNotNull);
    final webp = _webpVp8x(width: 10, height: 10);
    expect(probeImage(webp.sublist(0, webp.length - 3)), isNull);
    // VP8X だけで画像データがない（RIFF のサイズは合っている）。
    final headerOnly = _bytes([
      ...'RIFF'.codeUnits, ..._le32(4 + 18), ...'WEBP'.codeUnits, //
      ...'VP8X'.codeUnits, ..._le32(10), 0, 0, 0, 0, ..._le24(9), ..._le24(9),
    ]);
    expect(probeImage(headerOnly), isNull);
    // IDAT（画像データ）がない PNG（IHDR の直後に IEND）。
    expect(
      probeImage(
        _bytes([...png.sublist(0, 33), ...png.sublist(png.length - 12)]),
      ),
      isNull,
    );
    // IHDR が最初のチャンクでない、長さが 13 でない PNG。
    final badLength = Uint8List.fromList(png)..[11] = 12;
    expect(probeImage(badLength), isNull);
    final notFirst = _bytes([
      ...png.sublist(0, 8),
      0, 0, 0, 0, ...'tEXt'.codeUnits, 0, 0, 0, 0, //
      ...png.sublist(8),
    ]);
    expect(probeImage(notFirst), isNull);
  });

  test('対応しない形式・途中で切れたファイルは null', () {
    expect(probeImage(_bytes('GIF89a'.codeUnits)), isNull);
    expect(
      probeImage(_bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0])),
      isNull,
    );
    expect(probeImage(_bytes([0xFF, 0xD8, 0xFF])), isNull);
  });
}
