import 'dart:async';

import 'package:app/model/scene_streaming/model.dart';
import 'package:app/usecase/scene/scene_tile_streamer.dart';
import 'package:flutter_scene/scene.dart';
import 'package:flutter_test/flutter_test.dart';

/// x方向に100mずつ並んだ区画 t0〜t5（zは0〜100）。
SceneTileManifest _manifest() => SceneTileManifest(
  version: 1,
  tileSizeMeters: 100,
  tiles: [
    for (var i = 0; i < 6; i++)
      SceneTile(
        id: 't$i',
        minX: i * 100.0,
        maxX: i * 100.0 + 100,
        minZ: 0,
        maxZ: 100,
        detailPath: 'detail/t$i',
        coarsePath: 'coarse/t$i',
        detailTriangles: 1000,
        coarseTriangles: 100,
      ),
  ],
);

const _settings = SceneStreamingSettings(
  drawDistanceMeters: 250,
  detailDistanceMeters: 50,
  hysteresisMeters: 20,
  maxConcurrentLoads: 2,
  updateStepMeters: 5,
  retryDelay: Duration(minutes: 1),
);

/// GPUを使わずに、読み込みの完了・失敗の時期を操作するローダー。
class _Loader {
  final Map<String, List<Completer<Node>>> _pending = {};
  final List<String> started = [];
  final List<String> released = [];
  final Set<String> attached = {};
  int loadedCount = 0;

  Future<Node> load(String path) {
    final completer = Completer<Node>();
    started.add(path);
    _pending.putIfAbsent(path, () => []).add(completer);
    return completer.future;
  }

  Future<void> release(String path) async => released.add(path);

  void attach(Node node) => attached.add(node.name);

  void detach(Node node) => attached.remove(node.name);

  bool isLoading(String path) => _pending[path]?.isNotEmpty ?? false;

  Future<void> complete(String path) async {
    loadedCount++;
    _pending[path]!.removeAt(0).complete(Node(name: path));
    await pumpEventQueue();
  }

  Future<void> fail(String path) async {
    _pending[path]!.removeAt(0).completeError(StateError('読み込み失敗'));
    await pumpEventQueue();
  }

  /// 読み込み中のものを順に完了させる。
  Future<void> completeAll() async {
    while (_pending.values.any((list) => list.isNotEmpty)) {
      final path = _pending.entries
          .firstWhere((entry) => entry.value.isNotEmpty)
          .key;
      await complete(path);
    }
  }

  SceneTileStreamer streamer({SceneStreamingSettings settings = _settings}) =>
      SceneTileStreamer(
        manifest: _manifest(),
        settings: settings,
        load: load,
        release: release,
        attach: attach,
        detach: detach,
      );
}

void main() {
  test('近い区画から上限数ずつ読み込み、距離に応じた詳細度で表示する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    var ready = false;
    streamer.updatePosition(50, 50);
    unawaited(streamer.waitUntilReady().then((_) => ready = true));

    // t0（0m）とt1（50m）は高精細、t2（150m）とt3（250m）は簡略、t4以降は読まない。
    expect(loader.started, ['detail/t0', 'detail/t1']);
    await loader.complete('detail/t0');
    expect(loader.started.last, 'coarse/t2');
    await loader.completeAll();
    await pumpEventQueue();

    expect(ready, isTrue);
    expect(streamer.shownLods, {
      't0': SceneTileLod.detail,
      't1': SceneTileLod.detail,
      't2': SceneTileLod.coarse,
      't3': SceneTileLod.coarse,
    });
    expect(loader.attached, {
      'detail/t0',
      'detail/t1',
      'coarse/t2',
      'coarse/t3',
    });
    expect(loader.started, isNot(contains('coarse/t4')));
    expect(streamer.shownTriangles, 1000 * 2 + 100 * 2);
  });

  test('移動量が更新幅未満なら計算し直さない', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.completeAll();
    final startedCount = loader.started.length;

    // t4までの距離は350mから346mになるが、更新幅5m未満なので計算しない。
    streamer.updatePosition(54, 50);
    expect(loader.started.length, startedCount);
  });

  test('遠ざかった区画はノードを外して参照を解放する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.completeAll();

    // テレポートで東端へ。t0〜t1は描画距離外、t2は簡略へ下がる。
    streamer.updatePosition(550, 50, force: true);
    expect(loader.attached, isNot(contains('detail/t0')));
    expect(loader.attached, isNot(contains('detail/t1')));
    expect(loader.released, containsAll(['detail/t0', 'detail/t1']));
    await loader.completeAll();

    expect(streamer.shownLods, {
      't2': SceneTileLod.coarse,
      't3': SceneTileLod.coarse,
      't4': SceneTileLod.detail,
      't5': SceneTileLod.detail,
    });
  });

  test('詳細度の切替中は旧モデルを表示し、完了後に入れ替えて旧モデルを解放する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.completeAll();

    // t2までの距離が40mになり、高精細へ切り替える。
    streamer.updatePosition(160, 50);
    expect(loader.isLoading('detail/t2'), isTrue);
    expect(loader.attached, contains('coarse/t2'));
    expect(loader.released, isNot(contains('coarse/t2')));

    await loader.complete('detail/t2');
    expect(loader.attached, contains('detail/t2'));
    expect(loader.attached, isNot(contains('coarse/t2')));
    expect(loader.released, contains('coarse/t2'));
  });

  test('境界の往復ではヒステリシスの範囲内で詳細度を維持する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.completeAll();
    expect(streamer.shownLods['t1'], SceneTileLod.detail);

    // t1（x=100〜200）から左へ60m。高精細距離50m＋ヒステリシス20m以内なので維持する。
    streamer.updatePosition(40, 50);
    expect(loader.isLoading('coarse/t1'), isFalse);
    expect(streamer.shownLods['t1'], SceneTileLod.detail);

    // 75mまで離れたら簡略へ切り替える。
    streamer.updatePosition(25, 50);
    expect(loader.isLoading('coarse/t1'), isTrue);
    await loader.complete('coarse/t1');
    expect(streamer.shownLods['t1'], SceneTileLod.coarse);

    // 戻るときは高精細距離50m以内に入るまで切り替えない。
    streamer.updatePosition(40, 50);
    expect(loader.isLoading('detail/t1'), isFalse);
    streamer.updatePosition(50, 50);
    expect(loader.isLoading('detail/t1'), isTrue);
  });

  test('テレポート後に完了した古い応答は表示せずに解放する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    expect(loader.isLoading('detail/t0'), isTrue);

    streamer.updatePosition(550, 50, force: true);
    await loader.complete('detail/t0');

    expect(loader.attached, isNot(contains('detail/t0')));
    expect(loader.released, contains('detail/t0'));
    expect(streamer.shownLods.containsKey('t0'), isFalse);
  });

  test('読み込みに失敗したら待機を失敗させ、再試行で表示する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    Object? failure;
    unawaited(streamer.waitUntilReady().catchError((Object e) => failure = e));

    await loader.fail('detail/t0');
    await loader.completeAll();
    await pumpEventQueue();
    expect(failure, isA<StateError>());
    expect(streamer.shownLods.containsKey('t0'), isFalse);
    // 待ち時間（1分）の間は再試行しない。
    expect(loader.started.where((p) => p == 'detail/t0'), hasLength(1));

    streamer.retryFailedNow();
    streamer.updatePosition(50, 50, force: true);
    var ready = false;
    unawaited(streamer.waitUntilReady().then((_) => ready = true));
    await loader.completeAll();
    await pumpEventQueue();
    expect(ready, isTrue);
    expect(streamer.shownLods['t0'], SceneTileLod.detail);
  });

  test('失敗した区画は待ち時間の経過後に自動で再試行する', () async {
    final loader = _Loader();
    final streamer = loader.streamer(
      // 同時読み込みの枠が空いている状態で、時間経過による再試行を確かめる。
      settings: _settings.copyWith(
        retryDelay: const Duration(milliseconds: 1),
        maxConcurrentLoads: 10,
      ),
    );
    addTearDown(streamer.dispose);
    streamer.updatePosition(50, 50);
    await loader.fail('detail/t0');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(loader.started.where((p) => p == 'detail/t0'), hasLength(2));
    await loader.completeAll();
    expect(streamer.shownLods['t0'], SceneTileLod.detail);
  });

  test('描画距離・高精細距離の設定どおりに読み込む範囲が変わる', () async {
    // 描画距離100m・高精細距離0m：t0（0m）だけ高精細、t1（50m）は簡略、t2以降は読まない。
    final loader = _Loader();
    final streamer = loader.streamer(
      settings: _settings.copyWith(
        drawDistanceMeters: 100,
        detailDistanceMeters: 0,
      ),
    );
    streamer.updatePosition(50, 50);
    await loader.completeAll();

    expect(streamer.shownLods, {
      't0': SceneTileLod.detail,
      't1': SceneTileLod.coarse,
    });
    expect(loader.started, isNot(contains('coarse/t2')));
  });

  test('位置を伝える前に待つと、待たずに失敗する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();

    await expectLater(streamer.waitUntilReady(), throwsStateError);
    expect(loader.started, isEmpty);
  });

  test('区画範囲までの水平距離は、範囲内なら0、外なら最も近い点までの距離', () {
    final tile = _manifest().tiles.first;
    expect(sceneTileDistance(tile, 50, 50), 0);
    expect(sceneTileDistance(tile, 130, 50), 30);
    // 角の外側は、xとzの差の両方を使ったユークリッド距離。
    expect(sceneTileDistance(tile, 130, 140), 50);
  });

  test('破棄すると表示中を解放し、破棄後に完了した応答は追加せずに解放する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.complete('detail/t0');
    expect(loader.isLoading('detail/t1'), isTrue);
    Object? failure;
    unawaited(streamer.waitUntilReady().catchError((Object e) => failure = e));

    streamer.dispose();
    await pumpEventQueue();
    expect(failure, isA<StateError>());
    expect(loader.attached, isEmpty);
    expect(loader.released, ['detail/t0']);

    await loader.complete('detail/t1');
    expect(loader.attached, isEmpty);
    expect(loader.released, ['detail/t0', 'detail/t1']);
  });

  test('成功した読み込みと解放の回数が一致する', () async {
    final loader = _Loader();
    final streamer = loader.streamer();
    streamer.updatePosition(50, 50);
    await loader.completeAll();
    streamer.updatePosition(160, 50);
    await loader.completeAll();
    streamer.updatePosition(550, 50, force: true);
    await loader.completeAll();
    streamer.dispose();
    await pumpEventQueue();

    expect(loader.released, hasLength(loader.loadedCount));
    expect(loader.attached, isEmpty);
  });
}
