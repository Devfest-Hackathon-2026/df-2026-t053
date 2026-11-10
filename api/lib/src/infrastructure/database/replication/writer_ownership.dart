import 'dart:convert';
import 'dart:math';

import 'gcs_object_client.dart';

/// 所有権を取れなかった（既に別の writer が持つ、または GCS の失敗）。
/// この場合は業務 DB を開かず、復元・複製・API の受付を始めない。
class const WriterOwnershipUnavailable(final String message)
    implements Exception {
  @override
  String toString() => 'WriterOwnershipUnavailable($message)';
}

/// 取得済みの所有権。解放には取得時の generation が要る。
class const WriterOwnership({
  required final String ownerId,
  required final String generation,
  required final String bucket,
  required final String object,
});

/// writer 所有権（GCS のオブジェクト）の取得と解放。
///
/// TTL・時刻・ヘルス失敗で自動的に奪わない。異常終了で残った場合は、運用者が旧プロセス・
/// Job・未完了アップロードの停止を確認してから手動で解除する（#34 の runbook）。
class WriterOwnershipManager({
  required final GcsObjectClient _gcs,
  required final String bucket,
  required final String object,
  required final String releaseId,
  String Function()? newOwnerId,
  DateTime Function()? now,
}) {
  final String Function() _newOwnerId = newOwnerId ?? _randomOwnerId;
  final DateTime Function() _now = now ?? DateTime.now;

  /// `ifGenerationMatch=0` で作成して所有権を取る。既にあれば
  /// [WriterOwnershipUnavailable]（残っている内容も添える）。
  Future<WriterOwnership> acquire() async {
    final ownerId = _newOwnerId();
    final content = jsonEncode({
      'ownerId': ownerId,
      'releaseId': releaseId,
      'startedAt': _now().toUtc().toIso8601String(),
    });
    try {
      final generation = await _gcs.createIfAbsent(bucket, object, content);
      return WriterOwnership(
        ownerId: ownerId,
        generation: generation,
        bucket: bucket,
        object: object,
      );
    } on GcsPreconditionFailed {
      final current = await _describeCurrent();
      throw WriterOwnershipUnavailable(
        '既に別の writer が所有権を持つ（gs://$bucket/$object）$current',
      );
    } on GcsException catch (e) {
      throw WriterOwnershipUnavailable('所有権を取得できない: ${e.message}');
    }
  }

  /// 保持した generation を指定して削除する。generation が違えば失敗する
  /// （別のプロセスが取り直している可能性があり、他人の所有権を消さないため）。
  Future<void> release(WriterOwnership ownership) async {
    try {
      await _gcs.deleteIfGeneration(
        ownership.bucket,
        ownership.object,
        ownership.generation,
      );
    } on GcsPreconditionFailed {
      throw const WriterOwnershipUnavailable(
        '所有権の generation が変わっていたため解放しなかった',
      );
    } on GcsException catch (e) {
      throw WriterOwnershipUnavailable('所有権を解放できない: ${e.message}');
    }
  }

  Future<String> _describeCurrent() async {
    try {
      final current = await _gcs.read(bucket, object);
      if (current == null) return '';
      return ' generation=${current.generation} ${current.content}';
    } on GcsException {
      return '';
    }
  }

  static String _randomOwnerId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
