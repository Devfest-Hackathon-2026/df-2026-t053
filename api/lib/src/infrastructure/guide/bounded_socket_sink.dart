import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import '../../domain/ports/guide_transport.dart';

/// ソケットへ渡すフレームを、flush完了までキューの容量に含める。
/// writeは必ずadd+flushを待つ実装。期限/切断時のabortは生ソケットをdestroyする。
class BoundedSocketSink({
  required final Future<void> Function(Uint8List) write,
  required final void Function() abort,
  required final Future<void> Function() closeSocket,
  final int maxBytes = 128 * 1024,
}) implements GuideTransport {
  final _queue = Queue<Uint8List>();
  final _done = Completer<void>();
  Completer<void>? _drained;
  bool _writing = false;
  bool _closed = false;
  int pendingBytes = 0;
  int peakBytes = 0;

  @override
  Future<void> get drained => _drained?.future ?? Future.value();
  @override
  Future<void> get done => _done.future;

  @override
  void add(Uint8List data) {
    if (_closed) return;
    if (pendingBytes + data.length > maxBytes) {
      terminate();
      return;
    }
    pendingBytes += data.length;
    if (pendingBytes > peakBytes) peakBytes = pendingBytes;
    _queue.add(data);
    _drained ??= Completer<void>();
    if (!_writing) unawaited(_pump());
  }

  Future<void> _pump() async {
    _writing = true;
    try {
      while (!_closed && _queue.isNotEmpty) {
        final frame = _queue.removeFirst();
        await write(frame);
        if (!_closed) pendingBytes -= frame.length;
      }
    } catch (_) {
      // transportの終了として通知。データ・位置・トークンをログへ出さない。
      terminate();
    } finally {
      _writing = false;
      if (!_closed) {
        _drained?.complete();
        _drained = null;
      }
    }
  }

  @override
  void terminate() {
    if (_closed) return;
    _closed = true;
    _queue.clear();
    pendingBytes = 0;
    abort();
    _drained?.complete();
    _drained = null;
    if (!_done.isCompleted) _done.complete();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) => terminate();

  @override
  Future<void> addStream(Stream<Uint8List> stream) async {
    await for (final data in stream) {
      if (_closed) break;
      add(data);
      await drained;
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    await drained;
    if (_closed) return;
    _closed = true;
    await closeSocket();
    if (!_done.isCompleted) _done.complete();
  }
}
