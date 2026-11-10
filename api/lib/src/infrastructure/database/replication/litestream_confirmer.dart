import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../domain/ports/persistence_gate.dart';
import 'replication_confirmer.dart';
import 'sync_response.dart';

/// Litestream の IPC socket へ `POST /sync`（wait=true）を送って複製を確認する。
class LitestreamConfirmer({
  required final String socketPath,
  required final String dbPath,
}) implements ReplicationConfirmer {
  static HttpClient _unixSocketClient(String socketPath) {
    final client = HttpClient();
    client.connectionFactory = (uri, proxyHost, proxyPort) {
      final address = InternetAddress(
        socketPath,
        type: InternetAddressType.unix,
      );
      return Socket.startConnect(address, 0);
    };
    return client;
  }

  /// 要求ごとに作らず使い回す（IPC socket への接続を保てる）。
  final HttpClient _client = _unixSocketClient(socketPath);

  @override
  Future<void> confirm({required Duration timeout}) async {
    if (timeout <= Duration.zero) {
      throw const ReplicationUnavailableException('複製確認の残り時間がない');
    }
    try {
      // Litestream 側の timeout は秒の best-effort。こちらでも少し余裕を持って打ち切る。
      final seconds = (timeout.inMilliseconds / 1000).ceil();
      final body = await _post(_client, seconds).timeout(
        timeout + const Duration(seconds: 1),
        onTimeout: () =>
            throw const ReplicationUnavailableException('複製確認がタイムアウトした'),
      );
      final response = SyncResponse.parse(body);
      if (!response.confirmsReplication(expectedPath: dbPath)) {
        throw ReplicationUnavailableException(
          '複製を確認できない応答: status=${response.status} '
          'txid=${response.txid} replicated_txid=${response.replicatedTxid}',
        );
      }
    } on ReplicationUnavailableException {
      rethrow;
    } on Object catch (e) {
      // 接続できない・切れた・HTTP エラーなど。成功の根拠にしない。
      throw ReplicationUnavailableException('複製確認に失敗した: $e');
    }
  }

  void close() => _client.close(force: true);

  Future<String> _post(HttpClient client, int timeoutSeconds) async {
    final request = await client.postUrl(Uri.parse('http://localhost/sync'));
    request.headers.contentType = ContentType.json;
    request.write(
      jsonEncode({'path': dbPath, 'wait': true, 'timeout': timeoutSeconds}),
    );
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    if (response.statusCode != 200) {
      throw ReplicationUnavailableException(
        '同期要求が HTTP ${response.statusCode} を返した',
      );
    }
    return text;
  }
}
