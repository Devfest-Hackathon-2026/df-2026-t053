import 'dart:typed_data';

import 'package:app/provider/guide/validation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('完成したPCM WAVだけを受け付ける', () {
    expect(isCompleteGuideWav(wav()), isTrue);
    expect(isCompleteGuideWav(Uint8List.sublistView(wav(), 0, 47)), isFalse);
    expect(isCompleteGuideWav(Uint8List.fromList([...wav(), 0])), isFalse);
    for (final offset in [0, 8, 12, 16, 20, 22, 24, 28, 32, 34, 36, 40]) {
      final invalid = wav();
      invalid[offset] = 255;
      expect(isCompleteGuideWav(invalid), isFalse, reason: 'header $offset');
    }
  });
}
