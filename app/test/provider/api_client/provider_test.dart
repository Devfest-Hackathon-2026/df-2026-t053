import 'dart:io';

import 'package:app/provider/api_client/provider.dart';
import 'package:app/provider/profile/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_client/photohunt_client.dart';

class TrackingHttpClient extends Fake implements HttpClient {
  int closes = 0;

  @override
  set connectionTimeout(Duration? value) {}

  @override
  void close({bool force = false}) {
    closes++;
  }
}

void main() {
  test('共通Clientはプロフィール以外の生成endpointも提供する', () {
    final container = ProviderContainer(
      overrides: [apiBaseUrlProvider.overrideWithValue('https://api.example/')],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(apiClientProvider, (_, _) {});
    final client = subscription.read();
    expect(client, isA<Client>());
    expect(client.host, 'https://api.example/');
    expect(client.challenge.name, 'challenge');
    expect(client.play.name, 'play');
    expect(client.ranking.name, 'ranking');
    expect(container.read(profileProvider), same(client));
  });

  test('接続先切替と最後の購読の破棄で、所有するHTTP接続を一度ずつ閉じる', () async {
    final transports = <TrackingHttpClient>[];
    await HttpOverrides.runZoned(
      () async {
        final container = ProviderContainer(
          overrides: [
            apiBaseUrlProvider.overrideWithValue('https://old.example/'),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(apiClientProvider, (_, _) {});
        final oldClient = subscription.read();
        expect(transports, hasLength(1));
        container.updateOverrides([
          apiBaseUrlProvider.overrideWithValue('https://new.example/'),
        ]);
        await container.pump();
        expect(subscription.read(), isNot(same(oldClient)));
        expect(subscription.read().host, 'https://new.example/');
        expect(transports, hasLength(2));
        expect(transports.first.closes, 1);
        expect(transports.last.closes, 0);
        subscription.close();
        await container.pump();
        expect(transports.last.closes, 1);
      },
      createHttpClient: (_) {
        final client = TrackingHttpClient();
        transports.add(client);
        return client;
      },
    );
  });
}
