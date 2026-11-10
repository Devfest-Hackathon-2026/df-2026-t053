import 'dart:convert';
import 'dart:typed_data';

import '../../domain/ports/guide_speech_generator.dart';

/// 大きなbase64文字列だけを受信中に復号し、残りは標準JSON decoderで検証する。
/// JSON構文を独自に解釈しない。dataは1個だけ許可し、正しいinlineData位置も検証する。
class BoundedAudioJson({
  final int maxAudioBytes = kGuideAudioMaxBytes,
  final int maxMetadataBytes = 64 * 1024,
}) {
  final Uint8List _metadata = Uint8List(maxMetadataBytes);
  int _length = 0;
  int _stringStart = 0;
  bool _inString = false;
  bool _escaped = false;
  bool _audioString = false;
  bool _expectData = false;
  String? _previousString;
  _AudioBytes? _audio;
  StringConversionSink? _base64;
  final _encoded = StringBuffer();
  int _unicodeDigits = 0;
  int _unicodeValue = 0;

  /// 音声領域はWAVヘッダー用44 bytesを先頭に予約。PCM変換でもコピーしない。
  int get allocatedBytes => _metadata.length + (_audio?.buffer.length ?? 0);

  void add(List<int> chunk) {
    for (final byte in chunk) {
      if (_inString) {
        if (_audioString) {
          _audioByte(byte);
        } else {
          _append(byte);
          if (_escaped) {
            _escaped = false;
          } else if (byte == 92) {
            _escaped = true;
          } else if (byte == 34) {
            _inString = false;
            final value = jsonDecode(
              utf8.decode(
                Uint8List.sublistView(_metadata, _stringStart, _length),
              ),
            );
            if (value is! String) throw const FormatException('Invalid string');
            _previousString = value;
          }
        }
        continue;
      }
      if (byte == 34) {
        _inString = true;
        _audioString = _expectData;
        _expectData = false;
        _previousString = null;
        _stringStart = _length;
        _append(byte);
        if (_audioString) {
          if (_audio != null) {
            throw const FormatException('Multiple audio data');
          }
          final audio = _AudioBytes(maxAudioBytes);
          _audio = audio;
          _base64 = base64.decoder.startChunkedConversion(audio);
        }
      } else {
        _append(byte);
        if (byte == 32 || byte == 9 || byte == 10 || byte == 13) continue;
        _expectData = byte == 58 && _previousString == 'data';
        _previousString = null;
      }
    }
  }

  void _append(int byte) {
    if (_length == _metadata.length) throw const AudioJsonTooLargeException();
    _metadata[_length++] = byte;
  }

  void _audioByte(int byte) {
    if (_unicodeDigits > 0) {
      final digit = switch (byte) {
        >= 48 && <= 57 => byte - 48,
        >= 65 && <= 70 => byte - 55,
        >= 97 && <= 102 => byte - 87,
        _ => throw const FormatException('Invalid unicode escape'),
      };
      _unicodeValue = (_unicodeValue << 4) | digit;
      if (--_unicodeDigits == 0) _audioCharacter(_unicodeValue);
      return;
    }
    if (_escaped) {
      _escaped = false;
      if (byte == 117) {
        _unicodeDigits = 4;
        _unicodeValue = 0;
      } else if (byte == 47 || byte == 92 || byte == 34) {
        _audioCharacter(byte);
      } else {
        throw const FormatException('Invalid base64 escape');
      }
      return;
    }
    if (byte == 92) {
      _escaped = true;
    } else if (byte == 34) {
      _flush();
      _base64?.close();
      _base64 = null;
      _inString = false;
      _audioString = false;
      _append(byte);
    } else {
      _audioCharacter(byte);
    }
  }

  void _audioCharacter(int byte) {
    // JSONの生制御文字、非ASCII、base64以外を事前拒否。percent/url-safe拡張も不要。
    if (!(byte >= 65 && byte <= 90 ||
        byte >= 97 && byte <= 122 ||
        byte >= 48 && byte <= 57 ||
        byte == 43 ||
        byte == 47 ||
        byte == 61)) {
      throw const FormatException('Invalid base64 character');
    }
    _encoded.writeCharCode(byte);
    if (_encoded.length == 4096) _flush();
  }

  void _flush() {
    final decoder = _base64;
    if (decoder == null) throw StateError('Audio decoder is not active');
    decoder.add(_encoded.toString());
    _encoded.clear();
  }

  Map<String, Object?> finish() {
    if (_inString) throw const FormatException('Truncated JSON string');
    final result = jsonDecode(
      utf8.decode(Uint8List.sublistView(_metadata, 0, _length)),
    );
    if (result is! Map<String, Object?>) {
      throw const FormatException('Expected object');
    }
    final audio = _audio;
    if (audio == null) return result; // 拒否応答等は既存のエラー分類へ渡す。
    if (result case {
      'candidates': [{'content': {'parts': final List<Object?> parts}}, ...],
    }) {
      for (final part in parts) {
        if (part case {'inlineData': final Map<String, Object?> inline}) {
          if (inline['data'] == '' && inline['mimeType'] is String) {
            inline['data'] = audio.bytes;
            return result;
          }
        }
      }
    }
    throw const FormatException(
      'Audio data outside first candidate inlineData',
    );
  }
}

class const AudioJsonTooLargeException() implements Exception;

class _AudioBytes(final int maximum) implements Sink<List<int>> {
  final Uint8List buffer = Uint8List(maximum + 44);
  int _length = 0;
  Uint8List get bytes => Uint8List.sublistView(buffer, 44, 44 + _length);
  @override
  void add(List<int> data) {
    if (_length + data.length > maximum) {
      throw const AudioJsonTooLargeException();
    }
    buffer.setRange(44 + _length, 44 + _length + data.length, data);
    _length += data.length;
  }

  @override
  void close() {}
}
