import 'dart:typed_data';

import '../../domain/ports/guide_transport.dart';
import '../../infrastructure/guide/bounded_socket_sink.dart';

/// 送信キューに上限を持つ実装を作る。middlewareはinfrastructureを参照しない。
GuideTransport createGuideTransport({
  required Future<void> Function(Uint8List) write,
  required void Function() abort,
  required Future<void> Function() closeSocket,
}) => BoundedSocketSink(write: write, abort: abort, closeSocket: closeSocket);
