import 'dart:io' show ContentType;
import 'dart:typed_data';

import '../../domain/ports/guide_speech_generator.dart';

/// PCM の形式。Gemini TTS は 24 kHz・モノラル・16 bit（符号付き・リトルエンディアン）。
class const PcmFormat({
  final int sampleRate = 24000,
  final int channels = 1,
  final int bitsPerSample = 16,
});

const _riffHeaderBytes = 44;

/// ヘッダーのない PCM に、44 バイトの WAV（RIFF）ヘッダーを付ける。
Uint8List pcmToWav(
  Uint8List pcm, {
  PcmFormat format = const PcmFormat(),
  bool reservedHeader = false,
}) {
  if (reservedHeader && pcm.offsetInBytes < _riffHeaderBytes) {
    throw ArgumentError('WAV header space was not reserved');
  }
  final output = reservedHeader
      ? Uint8List.view(
          pcm.buffer,
          pcm.offsetInBytes - _riffHeaderBytes,
          pcm.length + _riffHeaderBytes,
        )
      : Uint8List(pcm.length + _riffHeaderBytes);
  if (!reservedHeader) output.setRange(_riffHeaderBytes, output.length, pcm);
  final blockAlign = format.channels * format.bitsPerSample ~/ 8;
  ByteData.sublistView(output, 0, _riffHeaderBytes)
    ..setUint32(0, 0x52494646) // 'RIFF'
    ..setUint32(4, 36 + pcm.length, Endian.little)
    ..setUint32(8, 0x57415645) // 'WAVE'
    ..setUint32(12, 0x666d7420) // 'fmt '
    ..setUint32(16, 16, Endian.little) // fmt チャンクの大きさ
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, format.channels, Endian.little)
    ..setUint32(24, format.sampleRate, Endian.little)
    ..setUint32(28, format.sampleRate * blockAlign, Endian.little)
    ..setUint16(32, blockAlign, Endian.little)
    ..setUint16(34, format.bitsPerSample, Endian.little)
    ..setUint32(36, 0x64617461) // 'data'
    ..setUint32(40, pcm.length, Endian.little);
  return output;
}

/// [bytes] が、読める WAV（RIFF・WAVE・fmt・data がそろい、大きさが合う）か。
bool isWav(Uint8List bytes) {
  if (bytes.length < _riffHeaderBytes) return false;
  final data = ByteData.sublistView(bytes);
  if (data.getUint32(0) != 0x52494646 || data.getUint32(8) != 0x57415645) {
    return false;
  }
  // RIFF の大きさ（先頭 8 バイトを除く）がファイルを越えない。
  if (8 + data.getUint32(4, Endian.little) > bytes.length) return false;
  var sawFormat = false;
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final id = data.getUint32(offset);
    final length = data.getUint32(offset + 4, Endian.little);
    final end = offset + 8 + length;
    if (end > bytes.length) return false;
    if (id == 0x666d7420) sawFormat = length >= 16;
    if (id == 0x64617461) return sawFormat && length > 0;
    offset = end + (length.isOdd ? 1 : 0);
  }
  return false;
}

/// TTS の出力を、1 つの完全な WAV にする（docs/specs.md「モデル・本文・音声の検証」）。
///
/// - `audio/wav`：そのまま使う（ヘッダーを二重に付けない）。読めなければ失敗。
/// - `audio/l16`・`audio/pcm`：ヘッダーのない 16 bit PCM として、WAV ヘッダーを付ける。
///   `rate=`・`channels=` があればそれを使う（既定は 24 kHz・モノラル）。
/// - そのほかの形式は失敗。全体が [kGuideAudioMaxBytes] を超えたら失敗。
Uint8List toWav(
  Uint8List bytes, {
  required String mimeType,
  bool reservedHeader = false,
}) {
  final ContentType content;
  try {
    content = ContentType.parse(mimeType);
  } on FormatException {
    throw const GuideSpeechException(
      GuideSpeechFailure.invalidFormat,
      detail: '音声の形式を読めない',
    );
  }
  final type = content.mimeType.toLowerCase();
  final Uint8List wav;
  if (type == 'audio/wav' || type == 'audio/x-wav' || type == 'audio/wave') {
    if (!isWav(bytes)) {
      throw const GuideSpeechException(
        GuideSpeechFailure.invalidFormat,
        detail: 'WAV として読めない',
      );
    }
    wav = bytes;
  } else if (type == 'audio/l16' || type == 'audio/pcm') {
    final format = PcmFormat(
      sampleRate: _positiveParameter(content, 'rate') ?? 24000,
      channels: _positiveParameter(content, 'channels') ?? 1,
    );
    // 標本 1 つ分（チャンネル数 × 2 バイト）の倍数でなければ、途中で切れている。
    final frameBytes = format.channels * format.bitsPerSample ~/ 8;
    if (bytes.isEmpty || bytes.length % frameBytes != 0) {
      throw const GuideSpeechException(
        GuideSpeechFailure.invalidFormat,
        detail: '16 bit PCM の長さではない',
      );
    }
    if (bytes.length + _riffHeaderBytes > kGuideAudioMaxBytes) {
      throw const GuideSpeechException(GuideSpeechFailure.tooLarge);
    }
    wav = pcmToWav(bytes, format: format, reservedHeader: reservedHeader);
  } else {
    throw GuideSpeechException(
      GuideSpeechFailure.invalidFormat,
      detail: '対応しない音声形式: $type',
    );
  }
  if (wav.length > kGuideAudioMaxBytes) {
    throw const GuideSpeechException(GuideSpeechFailure.tooLarge);
  }
  return wav;
}

/// MIME の引数（`rate=`・`channels=`）を正の整数として読む。なければ null、不正なら失敗。
int? _positiveParameter(ContentType content, String name) {
  final raw = content.parameters[name];
  if (raw == null) return null;
  final value = int.tryParse(raw.trim());
  if (value == null || value <= 0) {
    throw GuideSpeechException(
      GuideSpeechFailure.invalidFormat,
      detail: '音声形式の $name が不正',
    );
  }
  return value;
}
