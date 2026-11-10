import 'dart:typed_data';

/// 受信した単一のRIFF/WAVE全体を検証する。PCM 16bit mono/24kHzが契約。
/// チャンク境界・宣言サイズ・パディングも調べ、切れたファイルを再生しない。
bool isCompleteGuideWav(Uint8List bytes) {
  if (bytes.length < 44) return false;
  final data = ByteData.sublistView(bytes);
  bool tag(int offset, String value) {
    if (offset + value.length > bytes.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (bytes[offset + i] != value.codeUnitAt(i)) return false;
    }
    return true;
  }

  if (!tag(0, 'RIFF') ||
      !tag(8, 'WAVE') ||
      data.getUint32(4, Endian.little) != bytes.length - 8) {
    return false;
  }
  var offset = 12;
  var formatFound = false;
  var audioFound = false;
  while (offset + 8 <= bytes.length) {
    final size = data.getUint32(offset + 4, Endian.little);
    final start = offset + 8;
    final end = start + size;
    if (end > bytes.length) return false;
    if (tag(offset, 'fmt ')) {
      if (formatFound || audioFound || size < 16) return false;
      formatFound = true;
      if (data.getUint16(start, Endian.little) != 1 ||
          data.getUint16(start + 2, Endian.little) != 1 ||
          data.getUint32(start + 4, Endian.little) != 24000 ||
          data.getUint32(start + 8, Endian.little) != 48000 ||
          data.getUint16(start + 12, Endian.little) != 2 ||
          data.getUint16(start + 14, Endian.little) != 16) {
        return false;
      }
    } else if (tag(offset, 'data')) {
      if (!formatFound || audioFound || size == 0 || size.isOdd) return false;
      audioFound = true;
    }
    offset = end + (size % 2);
  }
  return offset == bytes.length && formatFound && audioFound;
}
