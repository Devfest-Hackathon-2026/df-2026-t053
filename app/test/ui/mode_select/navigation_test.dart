import 'dart:async';

import 'package:app/model/exploration_mode.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/ui/mode_select/screen.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class _Mode extends ModeSelectViewModel {
  @override
  ModeSelectState build() => const ModeSelectState();
  void ready() => state = state.copyWith(boot: .ready);
  void start() => state = state.copyWith(flow: .done);
  void complete() =>
      state = state.copyWith(playPhase: .completed, pendingSessionMode: .free);
  void pending() => state = state.copyWith(playPhase: .submitUnknown);
  @override
  Future<ExplorationMode?> resumePending() async {
    complete();
    return .free;
  }
}

class _Photo extends CluePhotoNotifier {
  @override
  CluePhotoState build() => const CluePhotoState(phase: .ready);
}

class _Record extends ModeRecordViewModel {
  @override
  Future<String> build(PlayMode mode) async => '未記録';
}

void main() {
  late ProviderContainer container;
  late _Mode mode;
  late int opened;
  late GlobalKey<NavigatorState> navigator;
  setUp(() {
    mode = _Mode();
    opened = 0;
    navigator = GlobalKey<NavigatorState>();
    container = ProviderContainer(
      overrides: [
        modeSelectViewModelProvider.overrideWith(() => mode),
        cluePhotoProvider.overrideWith(_Photo.new),
        modeRecordViewModelProvider(PlayMode.free).overrideWith(_Record.new),
        modeRecordViewModelProvider(PlayMode.near).overrideWith(_Record.new),
      ],
    );
  });
  tearDown(() => container.dispose());
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigator,
          home: ModeSelectScreen(
            onStartPlay: (_, _) => opened++,
            onOpenRanking: () {},
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('通常の開始後の撮影完了を保存結果の復旧と扱わない', (tester) async {
    await mount(tester);
    mode.ready();
    await tester.pump(const Duration(milliseconds: 500));
    mode.start();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 1);
    mode.complete();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 1);
  });
  testWidgets('背後のモード選択は開始と撮影完了で画面を開かない', (tester) async {
    await mount(tester);
    mode.ready();
    await tester.pump(const Duration(milliseconds: 500));
    final nav = navigator.currentState;
    if (nav == null) fail('Navigatorがない');
    unawaited(
      nav.push<void>(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('探索中'))),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    mode.start();
    await tester.pump(const Duration(milliseconds: 500));
    mode.complete();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 0);
    expect(find.text('探索中'), findsOneWidget);
  });
  testWidgets('表示中の起動時に復旧した保存結果は一度だけ開く', (tester) async {
    await mount(tester);
    mode.complete();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 0);
    mode.ready();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 1);
    mode.complete();
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 1);
  });
  testWidgets('保留撮影の明示的な再照会完了も一度だけ開く', (tester) async {
    await mount(tester);
    mode.pending();
    mode.ready();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('探索を開く'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opened, 1);
  });
}
