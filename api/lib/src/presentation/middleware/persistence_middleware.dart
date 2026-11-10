import 'dart:async';
import 'dart:typed_data';

import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

import '../../domain/ports/persistence_gate.dart';

/// 保守応答。認証・業務要求を処理の前に拒否する。
class const MaintenanceState(
  /// `MAINTENANCE`（migration 待ち・保守中）または `SCHEMA_TOO_NEW`。
  final String reason,
);

/// 共通ゲートの対象にする要求か。
///
/// Serverpod は HTTP メソッドを見ずに endpoint を実行する（`GET /<endpoint>/<method>?...`
/// でも呼べる）。そのため「POST だけ」ではなく、**次の除外以外はすべてゲートを通す**。
///
/// - OPTIONS（CORS のプリフライト）
/// - WebSocket のハンドシェイク。接続が続く間ゲートを保持してしまうため、#32 で
///   短い DB 区間だけを個別にゲートへ通す。
/// - 疎通確認（`health/ping`、`/`、`livez`・`readyz`・`startupz`）。DB を使わない。
bool isGatedCall(Method method, String path) {
  if (method == Method.options) return false;
  final p = path.startsWith('/') ? path.substring(1) : path;
  if (p.isEmpty) return false;
  if (p.startsWith('v1/websocket')) return false;
  if (p == 'health/ping') return false;
  if (p == 'livez' || p == 'readyz' || p == 'startupz') return false;
  return true;
}

/// [call] をゲートの中で実行する。保守中は処理の前に拒否する。
Future<T> runGated<T>({
  required PersistenceGate gate,
  required Duration requestDeadline,
  required Future<T> Function() call,
  MaintenanceState? maintenance,
}) async {
  if (maintenance != null) {
    throw ApiException(
      code: ApiErrorCode.unavailable,
      reason: maintenance.reason,
      message: '保守中のため処理できません',
    );
  }
  try {
    return await gate.runWrite<T>(call, deadline: requestDeadline);
  } on ReplicationUnavailableException {
    // 内部の理由（SQL・パス・Litestream の応答）は応答に出さない。
    throw ApiException(
      code: ApiErrorCode.unavailable,
      reason: ApiErrorReasons.temporarilyUnavailable,
      message: '保存を確認できませんでした。しばらくしてからやり直してください',
      retryAfterSeconds: 5,
    );
  }
}

/// RPC 1 件を「SQLite 更新 → GCS 複製確認」の 1 区間にする middleware。
///
/// 前提: HTTP の endpoint は上流 API（Gemini など）を待たない。上流を待つ処理は WSS
/// （#32 の guide.explainNearby）だけで、WSS はこの middleware の対象外。HTTP の endpoint に
/// 上流の呼び出しを足すときは、その待ちの間ゲートを保持しない形へ見直す。
///
/// 認証モジュールの内部更新も同じ要求の中で起きるので、個別の接続なしで
/// ゲートの内側に入る。要求は 1 件ずつ処理され、応答は複製確認の後に返る。
Middleware persistenceGateMiddleware({
  required PersistenceGate gate,
  required Duration requestDeadline,
  required int maxRequestSize,
  Duration bodyTimeout = const Duration(seconds: 15),
  MaintenanceState? maintenance,
}) {
  return (Handler next) {
    return (Request req) async {
      if (!isGatedCall(req.method, req.url.path)) return next(req);

      // 本文はゲートの外で読み切る。ゆっくり送るクライアントがゲートを握って、
      // 他の要求を待たせ続けるのを防ぐ。
      final Request buffered;
      if (maintenance != null) {
        buffered = req;
      } else {
        final builder = BytesBuilder(copy: false);
        await for (final chunk
            in req.read(maxLength: maxRequestSize).timeout(bodyTimeout)) {
          builder.add(chunk);
        }
        buffered = req.copyWith(body: Body.fromData(builder.takeBytes()));
      }

      return runGated<Result>(
        gate: gate,
        requestDeadline: requestDeadline,
        maintenance: maintenance,
        call: () async => await next(buffered),
      );
    };
  };
}
