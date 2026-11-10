import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../application/seed/seed_ports.dart';
import '../database/replication/gcs_object_client.dart';

/// 公開素材に付ける `Cache-Control`。内容ハッシュ付きの不変パス（`media/{sha256}/…`）なので、
/// 1 年の長期キャッシュにし、再検証もさせない（docs/infrastructure.md 5.5）。
const kMediaCacheControl = 'public, max-age=31536000, immutable';

/// [SeedMediaStore] の GCS 実装。公開素材バケット（`ASSET_BUCKET`）へ置く。
///
/// 内容アドレス（`media/{sha256}/…`）は上書きしない。既にあればサイズと MD5 で内容を比べる。
class GcsMediaStore({
  required final GcsMediaObjectClient _gcs,
  required final String bucket,
}) implements SeedMediaStore {
  @override
  Future<bool> putIfAbsent(
    String objectPath,
    Uint8List bytes,
    String contentType,
  ) async {
    // 再投入では素材は既にあることが多い。メタデータだけで比べ、送受信を省く。
    if (await _matchesExisting(objectPath, bytes, contentType)
        case final same?) {
      if (!same) throw _conflict(objectPath);
      return false;
    }
    try {
      await _gcs.createBytesIfAbsent(
        bucket,
        objectPath,
        bytes,
        contentType,
        cacheControl: kMediaCacheControl,
      );
      return true;
    } on GcsPreconditionFailed {
      // 確かめた後に別の書き込みが作った。
      if (await _matchesExisting(objectPath, bytes, contentType) != true) {
        throw _conflict(objectPath);
      }
      return false;
    }
  }

  /// 既にあるオブジェクトが [bytes] と [contentType] の両方で同じか。無ければ null。
  ///
  /// サイズと MD5 で比べる。MD5 が得られないときだけ内容を読んで比べる。
  Future<bool?> _matchesExisting(
    String objectPath,
    Uint8List bytes,
    String contentType,
  ) async {
    final meta = await _gcs.readMetadata(bucket, objectPath);
    if (meta == null) return null;
    if (meta.size != bytes.length) return false;
    // Content-Type が違うと、公開 URL が DB の登録と違う型で配信される。別のものとして扱う。
    if (meta.contentType != contentType) return false;
    final md5Base64 = meta.md5Base64;
    if (md5Base64 != null) {
      return md5Base64 == base64.encode(md5.convert(bytes).bytes);
    }
    final existing = await _gcs.readBytes(bucket, objectPath);
    return existing != null && _sameBytes(existing, bytes);
  }

  SeedConflictException _conflict(String objectPath) =>
      SeedConflictException('$bucket/$objectPath に別の内容がある（内容アドレスは上書きしない）');

  bool _sameBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
