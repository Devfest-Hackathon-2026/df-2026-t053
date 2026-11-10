import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/photo/model.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/ui/result/components/result_comparison.dart';
import 'package:app/ui/result/screen.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_scene/scene.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/play.dart';

class _UnavailableScene extends SceneAdapter {
  @override
  void build() {}

  @override
  Future<void> prepareResultCamera(
    Camera camera, {
    required bool Function() isCurrent,
  }) async {
    throw StateError('/private/scene-secret-path');
  }
}

class _AvailableScene extends _UnavailableScene {
  @override
  Future<ui.Image> captureResultCamera(
    Camera camera, {
    required int width,
    required int height,
    required bool Function() isCurrent,
  }) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const Color(0xFF4488AA), .src);
    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(width, height);
    } finally {
      picture.dispose();
    }
  }
}

class _Photo(final String path) extends CluePhotoNotifier {
  @override
  CluePhotoState build() => CluePhotoState(
    phase: .ready,
    path: path,
    width: 4,
    height: 3,
    alt: '比較写真',
  );
}

void main() {
  for (final size in [const Size(667, 375), const Size(844, 390)]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final available in [false, true]) {
        testWidgets('画面$size・文字$scale・3D成功=$availableで3列比較と点数・解説を保つ', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final file = await tester.runAsync(() async {
            final directory = await Directory.systemTemp.createTemp(
              'result-photo-',
            );
            addTearDown(() => directory.delete(recursive: true));
            final recorder = ui.PictureRecorder();
            ui.Canvas(recorder).drawColor(const Color(0xFF4488AA), .src);
            final picture = recorder.endRecording();
            final image = await picture.toImage(4, 3);
            final bytes = await image.toByteData(format: .png);
            image.dispose();
            picture.dispose();
            if (bytes == null) throw StateError('PNGを作成できませんでした');
            return File('${directory.path}/photo.png')
              ..writeAsBytesSync(bytes.buffer.asUint8List());
          });
          if (file == null) fail('写真を準備できませんでした');
          final result = SubmitShotResponse(
            shot: fakeShot(),
            reveal: fakeReveal(),
            myRankingEntry: fakeRankingEntry(),
          );
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sceneAdapterProvider.overrideWith(
                  available ? _AvailableScene.new : _UnavailableScene.new,
                ),
                cluePhotoProvider.overrideWith(() => _Photo(file.path)),
              ],
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: ResultScreen(
                  mode: .free,
                  result: result,
                  onRetry: () {},
                  onModeSelect: () {},
                  onRanking: () {},
                  onClose: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.textContaining('3Dを表示できませんでした'),
            available ? findsNothing : findsNWidgets(2),
          );
          if (available) expect(find.byType(RawImage), findsNWidgets(3));
          expect(find.textContaining('scene-secret-path'), findsNothing);
          expect(find.text('500'), findsOneWidget);
          expect(find.textContaining('解説文'), findsOneWidget);
          final ratioFinder = find.descendant(
            of: find.byType(ResultComparison),
            matching: find.byType(AspectRatio),
          );
          expect(ratioFinder, findsNWidgets(3));
          final rects = [
            for (final element in ratioFinder.evaluate())
              tester.getRect(find.byWidget(element.widget)),
          ];
          for (final rect in rects) {
            expect(rect.width / rect.height, closeTo(4 / 3, 1e-9));
            expect(rect.top, rects.first.top);
            if (scale == 1) expect(rect.bottom, lessThanOrEqualTo(size.height));
          }
          expect(rects[0].right, lessThan(rects[1].left));
          expect(rects[1].right, lessThan(rects[2].left));
          for (final label in ['自分の撮影（3D）', 'お手本（3D）', '実写写真']) {
            expect(find.text(label), findsOneWidget);
          }
          if (scale == 1) expect(find.byType(Scrollable), findsNothing);
          final image = tester.widget<Image>(find.byType(Image));
          expect(image.fit, BoxFit.contain);
          expect(find.text('500'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
