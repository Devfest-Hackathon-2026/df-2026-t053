// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;

import '../../../domain/exceptions.dart';

/// DB の列挙値は byName の文字列。unknown は DB に存在してはならない。
PlayMode playModeFromRow(PlayMode mode, {required String entity}) {
  if (mode == PlayMode.unknown) {
    throw CorruptedDataException(
      entity: entity,
      field: 'mode',
      message: '未知のモード',
    );
  }
  return mode;
}

PlayMode playModeToRow(PlayMode mode) {
  if (mode == PlayMode.unknown) {
    throw ArgumentError.value(mode, 'mode', 'unknown は保存できない');
  }
  return mode;
}
