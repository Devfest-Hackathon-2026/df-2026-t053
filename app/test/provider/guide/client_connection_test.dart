import 'dart:async';
import 'dart:io';

import 'package:app/model/guide/model.dart';
import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/guide/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_client/photohunt_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

import 'support.dart';

/// 実際の生成ClientとSDKの接続寿命を、ループバックのprotocol peerで検証。
/// APIの業務処理・Vertex・ネイティブ音声を代替検証するものではない。
void main() {
  late HttpServer server;
  late Client client;
  late ProviderContainer container;
  late List<WebSocket> sockets;
  late List<OpenMethodStreamCommand> opens;
  late List<CloseMethodStreamCommand> cancellations;
  late int closed;
  late bool acknowledgeOpens;
  late bool answerPing;
  late bool rejectConnection;
  late int rejected;
  late Directory temporary;
  late FakeGuidePlayer player;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('guide-connection-');
    player = FakeGuidePlayer();
    sockets = [];
    opens = [];
    cancellations = [];
    closed = 0;
    acknowledgeOpens = true;
    answerPing = true;
    rejectConnection = false;
    rejected = 0;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      if (rejectConnection) {
        rejected++;
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
        return;
      }
      final socket = await WebSocketTransformer.upgrade(request);
      sockets.add(socket);
      socket.listen((data) {
        if (data is! String) throw StateError('Expected protocol text');
        final message = WebSocketMessage.fromJsonString(
          data,
          client.serializationManager,
        );
        switch (message) {
          case PingCommand():
            if (answerPing) socket.add(PongCommand.buildMessage());
          case OpenMethodStreamCommand():
            opens.add(message);
            if (!acknowledgeOpens) break;
            socket.add(
              OpenMethodStreamResponse.buildMessage(
                connectionId: message.connectionId,
                responseType: .success,
                endpoint: message.endpoint,
                method: message.method,
              ),
            );
            socket.add(
              MethodStreamMessage.buildMessage(
                endpoint: message.endpoint,
                method: message.method,
                connectionId: message.connectionId,
                object: textEvent(),
                serializationManager: client.serializationManager,
              ),
            );
          case CloseMethodStreamCommand():
            cancellations.add(message);
          default:
            break;
        }
      }, onDone: () => closed++);
    });
    client = Client('http://127.0.0.1:${server.port}/')
      ..authKeyProvider = _TestAuthKey();
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        guideTemporaryDirectoryProvider.overrideWithValue(
          () async => temporary,
        ),
        guideAudioPlayerFactoryProvider.overrideWithValue(() => player),
      ],
    );
    container.listen(guideApiClientProvider, (_, _) {});
  });

  tearDown(() async {
    await container.read(guideProvider.notifier).close();
    container.dispose();
    await client.closeStreamingMethodConnections();
    client.close();
    for (final socket in sockets) {
      await socket.close();
    }
    await server.close(force: true);
    await temporary.delete(recursive: true);
  });

  test('生成Clientが認証と要求を送り、取消は他streamを壊さない', () async {
    final api = container.read(guideApiClientProvider);
    final first = <NearbyGuideEvent>[];
    final second = <NearbyGuideEvent>[];
    final one = api.explainNearby(request()).listen(first.add);
    await eventually(() => first.length == 1);
    // Providerを経由しない別の利用者も、同じClientのsocketを共有する。
    final two = client.guide.explainNearby(request()).listen(second.add);
    await eventually(() => second.length == 1);
    expect(sockets, hasLength(1));
    expect(
      opens.every((value) => value.authentication == 'Bearer local-test'),
      isTrue,
    );
    expect(opens.first.endpoint, 'guide');
    expect(opens.first.method, 'explainNearby');
    expect(
      opens.first.encodedArgs,
      SerializationManager.encodeForProtocol({'request': request()}),
    );
    await one.cancel();
    await api.release();
    await eventually(() => cancellations.length == 1);
    expect(closed, 0);
    sockets.single.add(
      MethodStreamMessage.buildMessage(
        endpoint: opens.last.endpoint,
        method: opens.last.method,
        connectionId: opens.last.connectionId,
        object: chunk(),
        serializationManager: client.serializationManager,
      ),
    );
    await eventually(() => second.length == 2);
    await two.cancel();
    await eventually(() => closed == 1);
    // 全stream終了後もClientは使え、新しい接続を作れる。
    final thirdEvents = <NearbyGuideEvent>[];
    final third = api.explainNearby(request()).listen(thirdEvents.add);
    await eventually(() => thirdEvents.length == 1);
    await third.cancel();
    await eventually(() => closed == 2);
  });

  test('実protocolの本文とWAVを受信し、正常終了後だけ音声を準備する', () async {
    container.listen(guideProvider, (_, _) {});
    final guide = container.read(guideProvider.notifier);
    await guide.generate(request());
    await eventually(() => container.read(guideProvider).text != null);
    expect(player.path, isNull);
    final call = opens.single;
    sockets.single.add(
      MethodStreamMessage.buildMessage(
        endpoint: call.endpoint,
        method: call.method,
        connectionId: call.connectionId,
        object: chunk(),
        serializationManager: client.serializationManager,
      ),
    );
    sockets.single.add(
      CloseMethodStreamCommand.buildMessage(
        endpoint: call.endpoint,
        method: call.method,
        connectionId: call.connectionId,
        reason: .done,
      ),
    );
    await eventually(() => container.read(guideProvider).phase == .ready);
    await eventually(() => closed == 1);
    expect(await File(player.path ?? '').readAsBytes(), wav());
    expect(player.plays, 0);
    await guide.togglePlayback();
    expect(player.plays, 1);
    await guide.close();
    expect(player.disposed, isTrue);
    expect(await temporary.list().toList(), isEmpty);
  });

  void acknowledge(OpenMethodStreamCommand call) {
    sockets.single.add(
      OpenMethodStreamResponse.buildMessage(
        connectionId: call.connectionId,
        responseType: .success,
        endpoint: call.endpoint,
        method: call.method,
      ),
    );
  }

  test('接続完了前の取消を開始応答後に送り、サーバー終了を待たず回収する', () async {
    answerPing = false;
    acknowledgeOpens = false;
    final events = <NearbyGuideEvent>[];
    final subscription = client.guide
        .explainNearby(request())
        .listen(events.add);
    await subscription.cancel().timeout(const Duration(seconds: 1));
    await eventually(() => sockets.length == 1);
    expect(opens, isEmpty);
    sockets.single.add(PongCommand.buildMessage());
    await eventually(() => opens.length == 1);
    acknowledge(opens.single);
    await eventually(() => cancellations.length == 1 && closed == 1);
    expect(cancellations.single.connectionId, opens.single.connectionId);
    expect(events, isEmpty);
  });

  test('開始応答待ちの取消は、後から開始した別streamを閉じない', () async {
    acknowledgeOpens = false;
    final oldEvents = <NearbyGuideEvent>[];
    final nextEvents = <NearbyGuideEvent>[];
    final old = client.guide.explainNearby(request()).listen(oldEvents.add);
    await eventually(() => opens.length == 1);
    await old.cancel();
    final next = client.guide.explainNearby(request()).listen(nextEvents.add);
    await eventually(() => opens.length == 2);
    acknowledge(opens.last);
    acknowledge(opens.first);
    await eventually(() => cancellations.length == 1);
    expect(cancellations.single.connectionId, opens.first.connectionId);
    expect(closed, 0);
    sockets.single.add(
      MethodStreamMessage.buildMessage(
        endpoint: opens.last.endpoint,
        method: opens.last.method,
        connectionId: opens.last.connectionId,
        object: textEvent(),
        serializationManager: client.serializationManager,
      ),
    );
    await eventually(() => nextEvents.length == 1);
    expect(oldEvents, isEmpty);
    await next.cancel();
    await eventually(() => cancellations.length == 2 && closed == 1);
  });

  test('Guideを開始直後に閉じると上流へ取消し、旧応答を表示しない', () async {
    container.listen(guideProvider, (_, _) {});
    final guide = container.read(guideProvider.notifier);
    await guide.generate(request());
    await guide.close();
    // 取消後に到着した本文にもSDKはCloseを返すため、同じIDの重複は許容する。
    await eventually(() => cancellations.isNotEmpty && closed == 1);
    expect(
      cancellations.every(
        (value) => value.connectionId == opens.single.connectionId,
      ),
      isTrue,
    );
    expect(container.read(guideProvider).phase, GuidePhase.idle);
    expect(player.path, isNull);
  });

  test('取消済み接続が失敗しても新しいstreamを開始できる', () async {
    rejectConnection = true;
    final errors = <Object>[];
    final old = client.guide
        .explainNearby(request())
        .listen((_) {}, onError: errors.add);
    await old.cancel();
    await eventually(() => rejected == 1);
    rejectConnection = false;
    final events = <NearbyGuideEvent>[];
    final next = client.guide.explainNearby(request()).listen(events.add);
    await eventually(() => events.length == 1);
    expect(errors, isEmpty);
    await next.cancel();
    await eventually(() => closed == 1);
  });

  test('正常終了で不要なsocketが閉じる', () async {
    final api = container.read(guideApiClientProvider);
    final done = Completer<void>();
    final events = <NearbyGuideEvent>[];
    api.explainNearby(request()).listen(events.add, onDone: done.complete);
    await eventually(() => events.length == 1);
    final call = opens.single;
    sockets.single.add(
      CloseMethodStreamCommand.buildMessage(
        endpoint: call.endpoint,
        method: call.method,
        connectionId: call.connectionId,
        reason: .done,
      ),
    );
    await done.future.timeout(const Duration(seconds: 5));
    await api.release();
    await eventually(() => closed == 1);
  });
}

class _TestAuthKey implements ClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async => 'Bearer local-test';
}
