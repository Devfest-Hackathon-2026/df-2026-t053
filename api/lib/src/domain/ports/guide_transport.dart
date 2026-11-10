import 'dart:async';
import 'dart:typed_data';

/// ガイドstreamの送信路。flush完了の待機と、期限・切断時の強制終了を提供する。
/// infrastructureの実装（BoundedSocketSink）をmiddlewareから隠すためのport。
/// PersistenceGateと同様、利用側はpresentationだけ。
abstract interface class GuideTransport() implements StreamSink<Uint8List> {
  /// キューに入れたフレームがソケットへflushされるまで待つ。
  Future<void> get drained;

  /// 送信を打ち切って生ソケットを破棄する。
  void terminate();
}
