import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:photohunt_server/src/domain/ports/guide_speech_generator.dart';
import 'package:photohunt_server/src/infrastructure/audio/wav.dart';
import 'package:photohunt_server/src/infrastructure/gemini/bounded_audio_json.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_guide_speech_generator.dart';
import 'package:photohunt_server/src/infrastructure/gemini/gemini_transport.dart';
import 'package:photohunt_server/src/infrastructure/guide/bounded_socket_sink.dart';
import 'package:test/test.dart';

String response(String data) =>
    '{"candidates":[{"content":{"parts":[{"inlineData":{"mimeType":"audio/pcm","data":"$data"}}]}}]}';

Uint8List audio(BoundedAudioJson decoder) {
  final result = lastInlineAudio(decoder.finish());
  final bytes = decodeBase64(result?.data);
  if (bytes == null) throw StateError('Missing audio');
  return bytes;
}

void main() {
  test('全byte境界・JSON escapeを跨いでも復号し、PCM→WAVは同じ領域を使う', () {
    final input = utf8.encode(response(r'\u0041P8\/AA=='));
    for (var split = 0; split <= input.length; split++) {
      final decoder = BoundedAudioJson(maxAudioBytes: 16);
      decoder.add(input.sublist(0, split));
      decoder.add(input.sublist(split));
      final pcm = audio(decoder);
      expect(pcm, [0, 255, 63, 0]);
      final wav = toWav(pcm, mimeType: 'audio/pcm', reservedHeader: true);
      expect(wav.buffer, pcm.buffer);
      expect(isWav(wav), isTrue);
      expect(wav.sublist(44), pcm);
    }
  });

  test('最大音声2件と送信待ち2接続を保持しても主要確保領域は24MiB以内', () async {
    final decoders = [BoundedAudioJson(), BoundedAudioJson()];
    // PCMは44bytes分を含め、最終WAVが10MiB。
    final remaining = kGuideAudioMaxBytes - 44;
    final prefix = '${response('').split('"data":"').first}"data":"';
    for (final decoder in decoders) {
      decoder.add(utf8.encode(prefix));
      final block = utf8.encode(base64.encode(Uint8List(3072)));
      var sent = 0;
      while (sent + 3072 <= remaining) {
        decoder.add(block);
        sent += 3072;
      }
      decoder.add(utf8.encode(base64.encode(Uint8List(remaining - sent))));
      decoder.add(utf8.encode('"}}]}}]}'));
    }
    final writes = [Completer<void>(), Completer<void>()];
    final sinks = [
      for (final write in writes)
        BoundedSocketSink(
          write: (_) => write.future,
          abort: () {},
          closeSocket: () async {},
        ),
    ];
    addTearDown(() async {
      for (final sink in sinks) {
        sink.terminate();
      }
      for (final write in writes) {
        write.complete();
      }
      await Future<void>.delayed(Duration.zero);
    });
    for (final sink in sinks) {
      sink.add(Uint8List(sink.maxBytes));
    }
    await Future<void>.delayed(Duration.zero);
    expect(sinks.every((sink) => sink.pendingBytes == sink.maxBytes), isTrue);
    expect(
      decoders.fold(0, (sum, d) => sum + d.allocatedBytes) +
          sinks.fold(0, (sum, sink) => sum + sink.pendingBytes),
      lessThan(24 * 1024 * 1024),
    );
    for (final decoder in decoders) {
      final pcm = audio(decoder);
      final wav = toWav(pcm, mimeType: 'audio/pcm', reservedHeader: true);
      expect(wav.length, kGuideAudioMaxBytes);
      expect(wav.buffer, pcm.buffer);
    }
  });

  test('音声・metadata上限は受信中に拒否する', () {
    expect(
      () =>
          BoundedAudioJson(maxAudioBytes: 2)
            ..add(utf8.encode(response('AAAA'))),
      throwsA(isA<AudioJsonTooLargeException>()),
    );
    expect(
      () =>
          BoundedAudioJson(maxMetadataBytes: 8)
            ..add(utf8.encode('{"long":"metadata"}')),
      throwsA(isA<AudioJsonTooLargeException>()),
    );
  });

  test('不正base64・JSON・複数data・異なる位置のdataを拒否', () {
    for (final input in [
      response('A!AA'),
      response('AAA'),
      response('AA=A'),
      response('AA==AA=='),
      response(r'\u00ff'),
      response('AAAA').substring(0, 35),
      '${response('AAAA')}x',
      '{"data":"AAAA"}',
      '{"data":"AAAA","data":"AAAA"}',
    ]) {
      expect(
        () {
          final decoder = BoundedAudioJson();
          decoder.add(utf8.encode(input));
          decoder.finish();
        },
        throwsA(isA<FormatException>()),
        reason: input,
      );
    }
  });

  test('拒否応答・音声なしのmetadataは既存の分類へ渡す', () {
    final decoder = BoundedAudioJson();
    decoder.add(utf8.encode('{"promptFeedback":{"blockReason":"SAFETY"}}'));
    expect(decoder.finish(), {
      'promptFeedback': {'blockReason': 'SAFETY'},
    });
  });
}
