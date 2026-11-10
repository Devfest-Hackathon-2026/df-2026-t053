import 'dart:convert';
import 'dart:io';

import 'package:app/model/play/model.dart';

/// 保留中の撮影はアプリ専用領域の play フォルダへ1件だけ記録する。
Future<File> _pendingShotFile(Directory base) async {
  final directory = Directory('${base.path}/play');
  await directory.create(recursive: true);
  return File('${directory.path}/pending_shot.json');
}

Future<void> savePendingShot(Directory base, PendingShot pending) async {
  final file = await _pendingShotFile(base);
  final temporary = File('${file.path}.tmp');
  await temporary.writeAsString(jsonEncode(pending.toJson()), flush: true);
  await temporary.rename(file.path);
}

Future<PendingShot?> loadPendingShot(Directory base) async {
  final file = await _pendingShotFile(base);
  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, Object?>) {
      // #103初期実装の平坦な記録も、生成JSONモデルの入口へ揃える。
      final normalized = decoded.containsKey('shot')
          ? decoded
          : {
              ...decoded,
              'shot': {
                'positionX': decoded['positionX'],
                'positionZ': decoded['positionZ'],
                'yawDegrees': decoded['yawDegrees'],
                'pitchDegrees': decoded['pitchDegrees'],
              },
            };
      return PendingShot.fromJson(normalized);
    }
    throw const FormatException('保留中の撮影記録の形式が不正です');
  } on FileSystemException catch (error) {
    if (error.osError?.errorCode != 2) rethrow;
    return null;
  }
}

Future<void> deletePendingShot(Directory base) async {
  final file = await _pendingShotFile(base);
  try {
    await file.delete();
  } on FileSystemException catch (error) {
    // 記録がない場合だけ何もしない。権限・I/Oの失敗を成功扱いしない。
    if (error.osError?.errorCode != 2) rethrow;
  }
}
