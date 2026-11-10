import 'dart:async';

import 'package:app/model/guide/model.dart';
import 'package:app/provider/guide/provider.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/usecase/play/play_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../provider/guide/support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('未接続時はダミー本文を表示せず安全なエラーを案内する', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(guidePanelViewModelProvider, (_, _) {});
    final vm = container.read(guidePanelViewModelProvider.notifier);
    vm.generate();
    expect(container.read(guideProvider).failure, GuideFailure.notConnected);
    expect(container.read(guideProvider).text, isNull);
    expect(vm.message, contains('接続できません'));
  });
  test('待ち秒数の間は再生成を押せず、秒数を案内する（#223）', () async {
    final container = ProviderContainer(
      overrides: [
        guideRequestSnapshotProvider.overrideWithValue(request),
        guideApiClientProvider.overrideWithValue(
          GuideApiClient(
            explainNearby: (_) => Stream.error(
              ApiException(
                code: .resourceExhausted,
                reason: ApiErrorReasons.guideRateLimited,
                message: '内部情報',
                retryAfterSeconds: 8,
              ),
            ),
            release: () async {},
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(guidePanelViewModelProvider, (_, _) {});
    final vm = container.read(guidePanelViewModelProvider.notifier);
    expect(vm.canRegenerate, isTrue);
    vm.generate();
    await eventually(
      () => container.read(guideProvider).failure == GuideFailure.rateLimited,
    );
    expect(vm.canRegenerate, isFalse);
    expect(vm.message, contains('約8秒後'));
    expect(vm.message, isNot(contains('内部情報')));
    await container.read(guideProvider.notifier).close();
    expect(vm.canRegenerate, isTrue);
  });
  test('背景移行で取消し復帰で要求を再送しない', () async {
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    var calls = 0;
    var releases = 0;
    final stream = StreamController<NearbyGuideEvent>();
    final container = ProviderContainer(
      overrides: [
        guideRequestSnapshotProvider.overrideWithValue(request),
        guideApiClientProvider.overrideWithValue(
          GuideApiClient(
            explainNearby: (_) {
              calls++;
              return stream.stream;
            },
            release: () async {
              releases++;
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(guidePanelViewModelProvider, (_, _) {});
    container.read(guidePanelViewModelProvider.notifier).generate();
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    stream.add(textEvent());
    await Future<void>.delayed(Duration.zero);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(guideProvider).phase, GuidePhase.idle);
    await container.read(guideProvider.notifier).close();
    expect(releases, 1);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.hidden,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    await stream.close();
  });
  test('受信途中の期限切れは本文を残し音声を破棄する', () async {
    final defaults = ProviderContainer();
    expect(defaults.read(guideDeadlineProvider), const Duration(seconds: 60));
    defaults.dispose();
    final stream = StreamController<NearbyGuideEvent>(sync: true);
    var releases = 0;
    final container = ProviderContainer(
      overrides: [
        guideDeadlineProvider.overrideWithValue(
          const Duration(milliseconds: 20),
        ),
        guideApiClientProvider.overrideWithValue(
          GuideApiClient(
            explainNearby: (_) => stream.stream,
            release: () async {
              releases++;
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(guideProvider, (_, _) {});
    await container.read(guideProvider.notifier).generate(request());
    stream.add(textEvent());
    stream.add(chunk(last: false));
    expect(container.read(guideProvider).phase, GuidePhase.receiving);
    await eventually(() => container.read(guideProvider).failure == .timeout);
    expect(container.read(guideProvider).text, isNotNull);
    await container.read(guideProvider.notifier).close();
    expect(releases, 1);
    await stream.close();
  });

  test('Provider破棄で購読を解放し、遅い応答を無視する', () async {
    final stream = StreamController<NearbyGuideEvent>(sync: true);
    var releases = 0;
    final container = ProviderContainer(
      overrides: [
        guideApiClientProvider.overrideWithValue(
          GuideApiClient(
            explainNearby: (_) => stream.stream,
            release: () async {
              releases++;
            },
          ),
        ),
      ],
    );
    container.listen(guideProvider, (_, _) {});
    await container.read(guideProvider.notifier).generate(request());
    stream.add(textEvent());
    container.dispose();
    stream.add(chunk());
    await eventually(() => releases == 1);
    expect(stream.hasListener, isFalse);
    await stream.close();
  });
}
