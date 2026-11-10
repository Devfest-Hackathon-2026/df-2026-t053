import 'dart:convert';
import 'dart:io';

import 'package:app/provider/play/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pending_record');
    await Directory('${directory.path}/play').create();
  });
  tearDown(() => directory.delete(recursive: true));

  test('初期PRの平坦な記録を同じ姿勢とIDで復旧する', () async {
    await File('${directory.path}/play/pending_shot.json').writeAsString(
      jsonEncode({
        'authUserId': 'owner',
        'playSessionId': 'session',
        'revisionId': 7,
        'requestId': 'request',
        'positionX': 1.0,
        'positionZ': 2.0,
        'yawDegrees': 90.0,
        'pitchDegrees': 0.0,
      }),
    );
    final pending = await loadPendingShot(directory);
    expect(pending?.revisionId, 7);
    expect(pending?.shot.positionX, 1);
    expect(pending?.requestId, 'request');
  });

  test('壊れた記録を撮影なしとして黙って上書きしない', () async {
    final file = File('${directory.path}/play/pending_shot.json');
    await file.writeAsString('{broken');
    await expectLater(loadPendingShot(directory), throwsFormatException);
    expect(await file.readAsString(), '{broken');
  });

  test('記録がないのは正常な未設定状態', () async {
    expect(await loadPendingShot(directory), isNull);
    await deletePendingShot(directory);
  });
}
