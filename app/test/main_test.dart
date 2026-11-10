import 'dart:async';

import 'package:app/app.dart';
import 'package:app/main.dart' as app;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// 起動順序だけを検証し、認証・3D読み込みを伴う実画面の構築を切り離す。
class _StartupBinding extends AutomatedTestWidgetsFlutterBinding {
  final launchedApps = <Widget>[];

  @override
  void scheduleAttachRootWidget(Widget rootWidget) {}

  @override
  void scheduleWarmUpFrame() {}

  @override
  Widget wrapWithDefaultView(Widget rootWidget) {
    launchedApps.add(rootWidget);
    return super.wrapWithDefaultView(const SizedBox.shrink());
  }
}

void main() {
  final binding = _StartupBinding();
  test('起動時に横画面の両方向を一度だけ要求し、完了してからアプリを表示する', () async {
    binding.launchedApps.clear();
    final calls = <MethodCall>[];
    final orientationReady = Completer<void>();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          calls.add(call);
          await orientationReady.future;
        }
        return null;
      },
    );
    addTearDown(() {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    final startup = app.main();
    await Future<void>.delayed(Duration.zero);
    expect(calls, hasLength(1));
    expect(calls.single.arguments, [
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
    expect(binding.launchedApps, isEmpty);
    orientationReady.complete();
    await startup;
    expect(binding.launchedApps.single, isA<GdgHackApp>());
    expect(calls, hasLength(1));
  });
}
