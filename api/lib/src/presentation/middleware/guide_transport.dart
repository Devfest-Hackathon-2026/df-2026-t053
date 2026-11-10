import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:relic_core/adapter.dart';
import 'package:serverpod/serverpod.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../domain/ports/guide_transport.dart';

final _transports = Expando<GuideTransport>();

/// 送信路の実装はdiが渡す。middlewareから具体実装を作らない。
typedef GuideTransportFactory = GuideTransport Function({
  required Future<void> Function(Uint8List) write,
  required void Function() abort,
  required Future<void> Function() closeSocket,
});

GuideTransport? guideTransport(Request? request) =>
    request == null ? null : _transports[request];

/// Serverpodのorigin検査とdispatchを再利用し、IOの送信だけflush可能な経路にする。
/// Relicの公開framerを使用するので、既存の生成clientとWSSプロトコルは同じ。
Middleware guideTransportMiddleware(GuideTransportFactory createTransport) =>
    (Handler next) => (Request request) async {
      final result = await next(request);
      if (result is! WebSocketUpgrade) return result;
      final key = webSocketAcceptKey(request);
      if (key == null) return Response.badRequest();
      return Hijack((channel) {
        final raw = channel.stream;
        if (raw is! Socket) {
          // 現行Cloud Run/LinuxとローカルのIO adapter以外では安全にfail closed。
          unawaited(channel.sink.close());
          return;
        }
        final sink = createTransport(
          write: (bytes) async {
            raw.add(bytes);
            await raw.flush();
          },
          abort: raw.destroy,
          closeSocket: raw.close,
        );
        _transports[request] = sink;
        sink.add(webSocketHandshakeResponse(key));
        final socket = FramedWebSocket(
          StreamChannel<Uint8List>(channel.stream, sink),
          maxMessageSize: 64 * 1024,
        );
        unawaited(
          socket.done.whenComplete(() {
            _transports[request] = null;
            sink.terminate();
          }),
        );
        result.callback(socket);
      });
    };
