import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const assetStorageChannel = MethodChannel('photohunt/asset_storage');

/// 再取得可能な素材だけの専用領域。作成後、取得開始前にバックアップから除外する。
Future<Directory> prepareAssetDirectory() async {
  final support = await getApplicationSupportDirectory();
  final directory = Directory('${support.path}/assets');
  await directory.create(recursive: true);
  if (Platform.isIOS) {
    await assetStorageChannel.invokeMethod<void>('excludeFromBackup');
  }
  return directory;
}
