import 'dart:math';

import 'package:characters/characters.dart';

class const InvalidNicknameException(final String reason) implements Exception;

String generateInitialNickname(Random random) =>
    '旅人${random.nextInt(10000).toString().padLeft(4, '0')}';

// 20個のZWJ家族絵文字（220 code units）も収めつつ結合文字の濫用を制限する。
const maxNicknameCodeUnits = 512;
final _formatCharacter = RegExp(r'\p{Cf}', unicode: true);
final _visibleCharacter = RegExp(
  r'[^\p{M}\p{Cf}\p{Z}\s\u115f\u1160\u2800\u3164\uffa0]',
  unicode: true,
);

/// 公開名を正規化する。ZWJ・異体字セレクタ・結合文字は許可する。
String normalizeNickname(String input) {
  final value = input.trim();
  if (value.length > maxNicknameCodeUnits) {
    throw const InvalidNicknameException('TOO_LONG_CODE_UNITS');
  }
  final units = input.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final unit = units[i];
    if (unit >= 0xd800 && unit <= 0xdbff) {
      if (++i == units.length || units[i] < 0xdc00 || units[i] > 0xdfff) {
        throw const InvalidNicknameException('INVALID_UNICODE');
      }
    } else if (unit >= 0xdc00 && unit <= 0xdfff) {
      throw const InvalidNicknameException('INVALID_UNICODE');
    }
  }
  // trim で改行を消してしまう前に検査する。
  if (input.runes.any(
    (r) => r <= 0x1f || (r >= 0x7f && r <= 0x9f) || r == 0x2028 || r == 0x2029,
  )) {
    throw const InvalidNicknameException('CONTROL_CHARACTER');
  }
  if (_formatCharacter.allMatches(input).any((m) => m.group(0) != '\u200d')) {
    throw const InvalidNicknameException('FORMAT_CHARACTER');
  }
  if (value.isEmpty) throw const InvalidNicknameException('EMPTY');
  if (!_visibleCharacter.hasMatch(value)) {
    throw const InvalidNicknameException('EMPTY');
  }
  if (value.characters.length > 20) {
    throw const InvalidNicknameException('TOO_LONG');
  }
  return value;
}
