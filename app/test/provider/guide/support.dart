import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod_client/serverpod_client.dart';

final guideId = UuidValue.fromString('b3ff01dd-8334-4d3f-b5f6-6596965aa176');
final otherId = UuidValue.fromString('c3ff01dd-8334-4d3f-b5f6-6596965aa176');
ExplainNearbyRequest request() => ExplainNearbyRequest(
  playSessionId: guideId,
  positionX: 10,
  positionZ: 20,
  yawDegrees: 30,
  locale: 'ja',
);
GuideText textEvent({String text = '木の梁を組み合わせた屋根です。'}) => GuideText(
  guideId: guideId,
  text: text,
  structures: ['大屋根リング'],
  sources: [GuideSource(title: '登録済み構造物資料', url: 'https://example.com/source')],
  aiGenerated: true,
);
Uint8List wav() {
  final bytes = Uint8List(48);
  final data = ByteData.sublistView(bytes);
  void tag(int offset, String text) =>
      bytes.setRange(offset, offset + text.length, text.codeUnits);
  tag(0, 'RIFF');
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  tag(36, 'data');
  data.setUint32(4, 40, Endian.little);
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, 24000, Endian.little);
  data.setUint32(28, 48000, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  data.setUint32(40, 4, Endian.little);
  return bytes;
}

GuideAudioChunk chunk({int sequence = 0, bool last = true, Uint8List? bytes}) =>
    GuideAudioChunk(
      guideId: guideId,
      sequence: sequence,
      data: ByteData.sublistView(bytes ?? wav()),
      contentType: 'audio/wav',
      last: last,
    );

class FakeGuidePlayer extends Fake implements AudioPlayer {
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final errors = StreamController<PlayerException>.broadcast(sync: true);
  String? path;
  int plays = 0;
  bool disposed = false;
  Completer<void>? loading;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<PlayerException> get errorStream => errors.stream;
  @override
  Future<Duration?> setFilePath(
    String filePath, {
    Duration? initialPosition,
    bool preload = true,
    dynamic tag,
  }) async {
    path = filePath;
    await loading?.future;
    return const Duration(seconds: 1);
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {}
  @override
  Future<void> play() async {
    plays++;
    states.add(PlayerState(true, .ready));
  }

  @override
  Future<void> pause() async {
    states.add(PlayerState(false, .ready));
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await states.close();
    await errors.close();
  }
}

Future<void> eventually(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue, reason: '非同期処理が完了する');
}
