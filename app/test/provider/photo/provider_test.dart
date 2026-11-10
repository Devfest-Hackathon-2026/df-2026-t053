import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/model/assets/model.dart';
import 'package:app/model/challenge/model.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/provider/assets/provider.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/clue_photo_server.dart';
import '../../support/play.dart';

class _RevisionHolder extends ChallengeNotifier {
  _RevisionHolder(this.initial);

  ChallengeRevision initial;

  @override
  ChallengeState build() => ChallengeState(challengeId: 1, revision: initial);

  void publish(ChallengeRevision revision) {
    initial = revision;
    state = ChallengeState(challengeId: 1, revision: revision);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late ServedCluePhoto served;
  late ProviderContainer container;
  late _RevisionHolder revisions;
  late List<int> image;
  late HttpOverrides? previousOverrides;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('clue-photo-');
    served = await serveCluePhoto();
    image = await solidPng(const ui.Color(0xff112233));
    revisions = _RevisionHolder(fakeRevision(photo: served.add(image)));
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = LocalhostTrust(served.trust);
    container = ProviderContainer(
      overrides: [
        challengeProvider.overrideWith(() => revisions),
        assetCacheDirectoryProvider.overrideWith((ref) async => directory),
        assetCacheSettingsProvider.overrideWith((ref) => served.settings),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    HttpOverrides.global = previousOverrides;
    await served.close();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await directory.delete(recursive: true);
  });

  test('出題版の写真を検証して寸法付きで保持し、同じ版は再取得しない', () async {
    final notifier = container.read(cluePhotoProvider.notifier);
    await notifier.ensureReady(revisions.initial);
    final ready = container.read(cluePhotoProvider);
    expect(ready.phase, CluePhotoPhase.ready);
    expect(ready.alt, 'お手本写真');
    expect(ready.width, 2);
    expect(ready.height, 2);
    final path = ready.path;
    if (path == null) fail('写真のパスがありません');
    expect(await File(path).readAsBytes(), image);
    await notifier.ensureReady(revisions.initial);
    expect(served.requests, 1);
  });

  test('不正な参照は通信せず失敗し、正しい版へ差し替えると取得できる', () async {
    final invalid = fakeRevision();
    revisions.initial = invalid;
    final notifier = container.read(cluePhotoProvider.notifier);
    await expectLater(
      notifier.ensureReady(invalid),
      throwsA(const AssetFailure(.invalidReference)),
    );
    expect(container.read(cluePhotoProvider).phase, CluePhotoPhase.failed);
    expect(served.requests, 0);

    final next = fakeRevision(photo: served.add(image));
    revisions.publish(next);
    await notifier.ensureReady(next);
    expect(container.read(cluePhotoProvider).phase, CluePhotoPhase.ready);
    expect(served.requests, 1);
  });

  test('版が変わると前の写真を捨てて新しい写真を保持する', () async {
    final notifier = container.read(cluePhotoProvider.notifier);
    await notifier.ensureReady(revisions.initial);
    final firstPath = container.read(cluePhotoProvider).path;
    final nextImage = await solidPng(const ui.Color(0xff445566));
    final nextRevision = fakeRevision(id: 2, photo: served.add(nextImage));
    revisions.publish(nextRevision);
    await notifier.ensureReady(nextRevision);
    final next = container.read(cluePhotoProvider);
    expect(next.phase, CluePhotoPhase.ready);
    expect(next.path, isNot(firstPath));
    final nextPath = next.path;
    if (nextPath == null) fail('新しい写真のパスがありません');
    expect(await File(nextPath).readAsBytes(), nextImage);
    expect(served.requests, 2);
  });

  test('失敗した取得は再試行で同じ版を取り直す', () async {
    served.failTimes = 1;
    final notifier = container.read(cluePhotoProvider.notifier);
    await expectLater(
      notifier.ensureReady(revisions.initial),
      throwsA(const AssetFailure(.integrity)),
    );
    expect(container.read(cluePhotoProvider).phase, CluePhotoPhase.failed);
    expect(served.requests, 1);

    await notifier.retry();
    final ready = container.read(cluePhotoProvider);
    expect(ready.phase, CluePhotoPhase.ready);
    final path = ready.path;
    if (path == null) fail('写真のパスがありません');
    expect(await File(path).readAsBytes(), image);
    expect(served.requests, 2);
  });

  test('ensureReadyは引数の版を使い、後から公開された版へすり替わらない', () async {
    final notifier = container.read(cluePhotoProvider.notifier);
    final pinned = revisions.initial;
    final other = await solidPng(const ui.Color(0xff778899));
    revisions.publish(fakeRevision(id: 2, photo: served.add(other)));
    await notifier.ensureReady(pinned);
    final ready = container.read(cluePhotoProvider);
    expect(ready.phase, CluePhotoPhase.ready);
    final path = ready.path;
    if (path == null) fail('写真のパスがありません');
    expect(await File(path).readAsBytes(), image);
  });
}
