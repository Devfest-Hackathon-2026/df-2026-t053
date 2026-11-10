import 'dart:convert';

import '../../../domain/ports/persistence_gate.dart';

/// Litestream の `POST /sync`（wait=true）の応答。
class const SyncResponse({
  required final String status,
  required final String path,
  required final int txid,
  required final int replicatedTxid,
}) {
  /// 応答 JSON を読む。形が違えば [ReplicationUnavailableException]。
  factory parse(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const ReplicationUnavailableException('同期応答が JSON ではない');
    }
    if (decoded is! Map<String, Object?>) {
      throw const ReplicationUnavailableException('同期応答が JSON オブジェクトではない');
    }
    final status = decoded['status'];
    final path = decoded['path'];
    final txid = decoded['txid'];
    final replicated = decoded['replicated_txid'];
    if (status is! String ||
        path is! String ||
        txid is! int ||
        replicated is! int) {
      throw const ReplicationUnavailableException('同期応答の項目が足りない');
    }
    return SyncResponse(
      status: status,
      path: path,
      txid: txid,
      replicatedTxid: replicated,
    );
  }

  /// GCS への複製まで終わったと言える応答か。
  ///
  /// - `synced`: 複製済み位置がローカル位置に届いている。
  /// - `no_change`: 位置が一致して初めて「すでに複製済み」と扱う。
  /// - `synced_local`（WAL→LTX までで、GCS は未確認）や未知の値は根拠にしない。
  ///
  /// [expectedPath] と違う DB への応答も根拠にしない。
  bool confirmsReplication({required String expectedPath}) {
    if (path != expectedPath) return false;
    if (replicatedTxid < txid) return false;
    return status == 'synced' || status == 'no_change';
  }
}
