import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/assets/model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:photohunt_shared/photohunt_shared.dart';

const maxImageBytes = 5 * 1024 * 1024;

/// 環境のバケットURL配下だけを許可する。パスはデコード前後を照合する。
Uri validateAssetReference(
  AssetRef asset,
  AssetCacheSettings settings, {
  bool allowLocalHttp = const bool.fromEnvironment('ALLOW_LOCAL_ASSET_HTTP'),
}) {
  final base = settings.baseUrl;
  final uri = Uri.tryParse(asset.url);
  final localHttp =
      kDebugMode &&
      allowLocalHttp &&
      base.scheme == 'http' &&
      _isLocalHost(base.host);
  final hash = asset.sha256;
  final extension = switch (asset.contentType) {
    'image/png' => 'png',
    'image/jpeg' => 'jpg',
    'image/webp' => 'webp',
    _ => throw const AssetFailure(.invalidReference),
  };
  if ((base.scheme != 'https' && !localHttp) ||
      base.host.isEmpty ||
      base.userInfo.isNotEmpty ||
      base.hasQuery ||
      base.hasFragment ||
      uri == null ||
      uri.scheme != base.scheme ||
      uri.origin != base.origin ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash) ||
      asset.byteLength <= 0 ||
      asset.byteLength > maxImageBytes ||
      settings.capacityBytes < asset.byteLength) {
    throw const AssetFailure(.invalidReference);
  }
  final prefix = base.path.endsWith('/') ? base.path : '${base.path}/';
  final expected = RegExp(
    '^${RegExp.escape(prefix)}media/$hash/(photo|map)\\.$extension\$',
  );
  if (asset.url != uri.toString() ||
      !expected.hasMatch(uri.path) ||
      uri.toString() != '${uri.origin}${uri.path}') {
    throw const AssetFailure(.invalidReference);
  }
  return uri;
}

/// ローカルemulatorと実機から接続するLANだけ。DNS名の解決結果は信用しない。
bool _isLocalHost(String host) {
  if (host == 'localhost') return true;
  final address = InternetAddress.tryParse(host);
  if (address == null) return false;
  if (address.isLoopback) return true;
  if (address.type != InternetAddressType.IPv4) return false;
  final bytes = address.rawAddress;
  return bytes[0] == 10 ||
      (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
      (bytes[0] == 192 && bytes[1] == 168);
}

/// サイズを先に確認し、再利用時もSHAとデコードを検査する。
Future<void> verifyAssetFile(File file, AssetRef asset) async {
  if (await file.length() != asset.byteLength ||
      (await sha256.bind(file.openRead()).first).toString() != asset.sha256) {
    throw const AssetFailure(.integrity);
  }
  final input = await file.open();
  late final List<int> header;
  try {
    header = await input.read(12);
  } finally {
    await input.close();
  }
  final matches = switch (asset.contentType) {
    'image/png' => _startsWith(header, [137, 80, 78, 71, 13, 10, 26, 10]),
    'image/jpeg' => _startsWith(header, [255, 216, 255]),
    'image/webp' =>
      _startsWith(header, [82, 73, 70, 70]) &&
          header.length >= 12 &&
          _startsWith(header.sublist(8), [87, 69, 66, 80]),
    _ => false,
  };
  if (!matches) throw const AssetFailure(.integrity);
  final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      if (descriptor.width > 4096 || descriptor.height > 4096) {
        throw const AssetFailure(.integrity);
      }
      final codec = await descriptor.instantiateCodec();
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    } finally {
      descriptor.dispose();
    }
  } catch (_) {
    throw const AssetFailure(.integrity);
  } finally {
    buffer.dispose();
  }
}

/// 検証済みファイルの画素サイズ。表示の縦横比に使い、0 や上限超過は検証失敗にする。
Future<({int width, int height})> readImageSize(File file) async {
  final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final width = descriptor.width;
      final height = descriptor.height;
      if (width <= 0 || height <= 0 || width > 4096 || height > 4096) {
        throw const AssetFailure(.integrity);
      }
      return (width: width, height: height);
    } finally {
      descriptor.dispose();
    }
  } on AssetFailure {
    rethrow;
  } catch (error, stackTrace) {
    log('写真の寸法を読めませんでした', error: error.runtimeType, stackTrace: stackTrace);
    throw const AssetFailure(.integrity);
  } finally {
    buffer.dispose();
  }
}

bool _startsWith(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}
