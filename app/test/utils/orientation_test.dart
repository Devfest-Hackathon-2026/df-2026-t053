import 'package:app/utils/orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('画面の向きを横画面の左右だけに固定する', () async {
    final calls = <MethodCall>[];
    tester() =>
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tester().setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => tester().setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await lockLandscapeOrientation();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'SystemChrome.setPreferredOrientations');
    expect(calls.single.arguments, [
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
  });
}
