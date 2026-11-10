import 'dart:convert';
import 'dart:typed_data';

import '../../application/seed/seed_validator.dart';

/// JPEG・PNG・WebP のヘッダーだけを読み、画素は復号しない。
///
/// 対応しない形式、または壊れたファイルは null を返す。
SeedImageFacts? probeImage(Uint8List bytes) {
  try {
    if (_startsWith(bytes, const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ])) {
      return _png(bytes);
    }
    if (_startsWith(bytes, const [0xFF, 0xD8])) return _jpeg(bytes);
    if (_ascii(bytes, 0, 4) == 'RIFF' && _ascii(bytes, 8, 4) == 'WEBP') {
      return _webp(bytes);
    }
  } on RangeError {
    // 途中で切れたファイル。
  }
  return null;
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}

String _ascii(Uint8List bytes, int offset, int length) =>
    latin1.decode(Uint8List.sublistView(bytes, offset, offset + length));

SeedImageFacts? _png(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  int? width;
  int? height;
  var hasMetadata = false;
  var sawImageData = false;
  var sawEnd = false;
  var offset = 8;
  while (offset + 8 <= bytes.length) {
    final length = data.getUint32(offset);
    final type = _ascii(bytes, offset + 4, 4);
    // 長さ・種別・データ・CRC。ファイルの終わりを越えるなら、途中で切れている。
    if (offset + 12 + length > bytes.length) return null;
    // IHDR は最初のチャンクで、長さは 13。そうでないものは PNG として読まない。
    if ((offset == 8) != (type == 'IHDR')) return null;
    if (type == 'IHDR') {
      if (length != 13) return null;
      width = data.getUint32(offset + 8);
      height = data.getUint32(offset + 12);
    }
    // EXIF と、EXIF・XMP を運べるテキストチャンク（ImageMagick の
    // `Raw profile type exif` は tEXt／zTXt）。キーワードを見分けず、すべて除く対象にする。
    if (type == 'eXIf' || type == 'tEXt' || type == 'zTXt' || type == 'iTXt') {
      hasMetadata = true;
    }
    // 画像データ（JPEG・WebP と同じく、画素のない画像は受け付けない）。
    if (type == 'IDAT' && length > 0) sawImageData = true;
    if (type == 'IEND') {
      sawEnd = true;
      break;
    }
    offset += 12 + length;
  }
  if (!sawImageData || !sawEnd || width == null || height == null) {
    return null;
  }
  return SeedImageFacts(
    contentType: 'image/png',
    width: width,
    height: height,
    hasMetadata: hasMetadata,
  );
}

SeedImageFacts? _jpeg(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  int? width;
  int? height;
  var hasMetadata = false;
  var sawImageData = false;
  var sawEnd = false;
  var offset = 2;
  // マーカーは 2 バイト。EOI（FF D9）だけが残る位置でも読む。長さが足りないときは
  // getUint16 の RangeError で、途中で切れたファイルとして null になる。
  // プログレッシブ JPEG はスキャンが複数あり、その間にもセグメント（APP1・COM など）を
  // 置けるので、EOI まで読み進める。
  while (offset + 2 <= bytes.length) {
    if (bytes[offset] != 0xFF) return null;
    final marker = bytes[offset + 1];
    // 埋め草の 0xFF。
    if (marker == 0xFF) {
      offset += 1;
      continue;
    }
    // 長さを持たないマーカー（RSTn・TEM）。
    if ((marker >= 0xD0 && marker <= 0xD7) || marker == 0x01) {
      offset += 2;
      continue;
    }
    if (marker == 0xD9) {
      sawEnd = true;
      break;
    }
    final length = data.getUint16(offset + 2);
    final segment = offset + 4;
    // セグメントがファイルの終わりを越えるなら、途中で切れている。
    if (length < 2 || offset + 2 + length > bytes.length) return null;
    // APP1（EXIF・XMP・拡張 XMP）、APP3（EXIF 拡張など）、APP13（Photoshop・IPTC）、
    // COM（コメント）。内容を見分けず、メタデータを持つとして除く対象にする。
    if (marker == 0xE1 || marker == 0xE3 || marker == 0xED || marker == 0xFE) {
      hasMetadata = true;
    }
    // SOF0〜SOF15（DHT・JPG・DAC は除く）。
    final isSof =
        marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC;
    if (isSof) {
      height = data.getUint16(segment + 1);
      width = data.getUint16(segment + 3);
    }
    offset += 2 + length;
    // SOS（スキャンの開始）の後は、次のマーカーまで画像データ（エントロピー符号）が続く。
    // データ中の FF は 00（バイトの詰め物）か RSTn が続くので、それ以外の FF xx で止まる。
    if (marker == 0xDA) {
      final start = offset;
      while (offset + 1 < bytes.length) {
        final next = bytes[offset + 1];
        final isMarker =
            bytes[offset] == 0xFF &&
            next != 0x00 &&
            next != 0xFF &&
            !(next >= 0xD0 && next <= 0xD7);
        if (isMarker) break;
        offset += 1;
      }
      if (offset > start) sawImageData = true;
      if (offset + 1 >= bytes.length) return null; // EOI の前で切れている
    }
  }
  // 画像データ（SOS の後のスキャン）と、末尾の EOI を求める。
  if (!sawImageData || !sawEnd || width == null || height == null) {
    return null;
  }
  return SeedImageFacts(
    contentType: 'image/jpeg',
    width: width,
    height: height,
    hasMetadata: hasMetadata,
  );
}

SeedImageFacts? _webp(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  int? width;
  int? height;
  var hasMetadata = false;
  var sawImageData = false;
  // RIFF のサイズ（先頭 8 バイトを除く）が、ファイルの終わりを越えるなら途中で切れている。
  final riffEnd = 8 + data.getUint32(4, Endian.little);
  if (riffEnd > bytes.length) return null;
  var offset = 12;
  while (offset + 8 <= riffEnd) {
    final type = _ascii(bytes, offset, 4);
    final length = data.getUint32(offset + 4, Endian.little);
    final chunk = offset + 8;
    // チャンクがファイルの終わりを越えるなら、途中で切れている。
    if (chunk + length > riffEnd) return null;
    // 画像データを持つチャンク（静止画の VP8／VP8L、アニメーションのフレーム ANMF）。
    if (type == 'VP8 ' || type == 'VP8L' || type == 'ANMF') sawImageData = true;
    switch (type) {
      case 'VP8X':
        width = 1 + _uint24(bytes, chunk + 4);
        height = 1 + _uint24(bytes, chunk + 7);
      case 'VP8 ':
        // フレームタグ 3 バイトと開始コード 9d 01 2a の後に、14 ビットずつ。
        if (width == null) {
          width = data.getUint16(chunk + 6, Endian.little) & 0x3FFF;
          height = data.getUint16(chunk + 8, Endian.little) & 0x3FFF;
        }
      case 'VP8L':
        if (width == null) {
          final bits = data.getUint32(chunk + 1, Endian.little);
          width = 1 + (bits & 0x3FFF);
          height = 1 + ((bits >> 14) & 0x3FFF);
        }
      case 'EXIF' || 'XMP ':
        hasMetadata = true;
    }
    // チャンクは偶数バイトに揃える。
    offset = chunk + length + (length.isOdd ? 1 : 0);
  }
  if (!sawImageData || width == null || height == null) return null;
  return SeedImageFacts(
    contentType: 'image/webp',
    width: width,
    height: height,
    hasMetadata: hasMetadata,
  );
}

int _uint24(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
