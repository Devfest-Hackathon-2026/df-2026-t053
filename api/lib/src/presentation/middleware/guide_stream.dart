import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../../domain/ports/persistence_gate.dart';
import 'guide_transport.dart';
import 'persistence_middleware.dart';

const guideLifetime = Duration(seconds: 55);
final _contexts = Expando<GuideStreamContext>();
final _clocks = Expando<Stopwatch>();
final _authHandlers = Expando<AuthenticationHandler>();

class GuideStreamContext({
  required final PersistenceGate? gate,
  required final MaintenanceState? maintenance,
  final Duration lifetime = guideLifetime,
}) {
  Future<T> database<T>(Session session, Future<T> Function() call) {
    final gate = this.gate;
    if (gate == null) return call();
    return runGated(
      gate: gate,
      requestDeadline: guideRemaining(session),
      maintenance: maintenance,
      call: call,
    );
  }
}

Duration guideRemaining(Session session) {
  final clock = _clocks[session] ??= Stopwatch()..start();
  return guideStreamContext(session).lifetime - clock.elapsed;
}

/// HTTPはmiddleware、WSSの認証だけはここで同じゲートを使う。二重取得しない。
void configureGuideStreaming(
  Serverpod pod, {
  required PersistenceGate? gate,
  required MaintenanceState? maintenance,
  Duration lifetime = guideLifetime,
}) {
  final context = GuideStreamContext(
    gate: gate,
    maintenance: maintenance,
    lifetime: lifetime,
  );
  _contexts[pod] = context;
  final authenticate = _authHandlers[pod] ?? pod.authenticationHandler;
  if (authenticate == null) throw StateError('認証を先に初期化してください');
  _authHandlers[pod] = authenticate;
  pod.authenticationHandler = (session, token) async {
    if (session is! MethodStreamSession) return authenticate(session, token);
    final context = guideStreamContext(session);
    _clocks[session] = Stopwatch()..start();
    // 認証・DBが完了しなくても55秒で通信を終了。DBの所有権は安全な完了まで保持する。
    final deadline = Timer(
      context.lifetime,
      () => guideTransport(session.request)?.terminate(),
    );
    session.addWillCloseListener((_) {
      deadline.cancel();
    });
    final authenticated = await context.database(
      session,
      () => authenticate(session, token),
    );
    // 切断後にendpointを開始しない。認証結果なしとしてframeworkにsessionを閉じさせる。
    if (guideRemaining(session) <= Duration.zero) return null;
    return authenticated;
  };
}

GuideStreamContext guideStreamContext(Session session) =>
    _contexts[session.serverpod] ?? (throw StateError('ガイドstreamが未初期化です'));

/// Serverpodの非同期outputControllerがフレームを渡してからflushを待つ。
/// 次のイベントを生成する前に呼び、ソケットが詰まると購読も止める。
Future<void> drainGuideTransport(Session session) async {
  await Future<void>.delayed(Duration.zero);
  await guideTransport(session.request)?.drained;
}
