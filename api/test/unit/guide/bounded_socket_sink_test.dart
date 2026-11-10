import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:photohunt_server/src/infrastructure/guide/bounded_socket_sink.dart';
import 'package:test/test.dart';

void main() {
  test('flush待ちも容量に含め、超過時は蓄積せず切断する', () async {
    final write = Completer<void>();
    var aborted = 0;
    final sink = BoundedSocketSink(
      write: (_) => write.future,
      abort: () => aborted++,
      closeSocket: () async {},
      maxBytes: 8,
    );
    sink.add(Uint8List(8));
    var drained = false;
    unawaited(sink.drained.then((_) => drained = true));
    await Future<void>.delayed(Duration.zero);
    expect(drained, isFalse);
    expect(sink.pendingBytes, 8);
    sink.add(Uint8List(1));
    await sink.done;
    expect(aborted, 1);
    expect(sink.peakBytes, 8);
    expect(sink.pendingBytes, 0);
    write.complete();
    await Future<void>.delayed(Duration.zero);
    expect(sink.pendingBytes, 0);
  });

  test('送信成功後に次を受け入れ、順序と容量を保つ', () async {
    final sent = <int>[];
    final sink = BoundedSocketSink(
      write: (bytes) async {
        sent.add(bytes.single);
      },
      abort: () {},
      closeSocket: () async {},
      maxBytes: 2,
    );
    await sink.addStream(
      Stream.fromIterable([
        Uint8List.fromList([1]),
        Uint8List.fromList([2]),
      ]),
    );
    await sink.close();
    expect(sent, [1, 2]);
    expect(sink.peakBytes, 1);
    expect(sink.pendingBytes, 0);
  });

  test('読み取らない実TCP受信者ではflushが待機し、destroyで期限内に解放できる', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final accepted = server.first;
    final client = await Socket.connect(
      InternetAddress.loopbackIPv4,
      server.port,
    );
    final socket = await accepted;
    addTearDown(() async {
      client.destroy();
      socket.destroy();
      await server.close();
    });
    final sink = BoundedSocketSink(
      write: (bytes) async {
        socket.add(bytes);
        await socket.flush();
      },
      abort: socket.destroy,
      closeSocket: socket.close,
    );
    var sent = 0;
    final timer = Timer(const Duration(milliseconds: 200), sink.terminate);
    await sink.addStream(() async* {
      for (var i = 0; i < 4096; i++) {
        sent++;
        yield Uint8List(32768);
      }
    }());
    timer.cancel();
    expect(sent, lessThan(4096));
    expect(sink.peakBytes, lessThanOrEqualTo(32768));
    expect(sink.pendingBytes, 0);
  });
}
