import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:app/model/scene_streaming/model.dart';
import 'package:flutter_scene/scene.dart';

/// 区画モデルを読み込む。成功した1回ごとに、[SceneTileRelease]で1回解放する。
typedef SceneTileLoad = Future<Node> Function(String path);

/// [SceneTileLoad]で取った共有キャッシュの参照を1つ返す。
typedef SceneTileRelease = Future<void> Function(String path);

/// 位置（[x], [z]）から区画範囲までの水平距離（m）。範囲内なら0。
double sceneTileDistance(SceneTile tile, double x, double z) {
  final dx = math.max(0.0, math.max(tile.minX - x, x - tile.maxX));
  final dz = math.max(0.0, math.max(tile.minZ - z, z - tile.maxZ));
  return math.sqrt(dx * dx + dz * dz);
}

/// プレイヤー位置から区画ごとの詳細度を決め、区画モデルの読み込み・切替・解放を行う。
///
/// - 描画距離内の区画は簡略モデル、高精細距離内の区画は加工元と同じモデルで表示する。
/// - 近い区画から順に、同時読み込み数の上限まで読み込む。
/// - 詳細度の切替中は旧モデルを表示し続け、新しいモデルの完了後に入れ替える。
/// - 遠ざかった区画は、ノードを外してからキャッシュの参照を解放する。
/// - 完了時に不要になった応答や、[dispose]後に完了した応答は追加せずに解放する。
///
/// 1区画の読み込みは同時に1つまでとし、完了後に必要な詳細度を計算し直す。
class SceneTileStreamer {
  SceneTileStreamer({
    required SceneTileManifest manifest,
    required this._settings,
    required this._load,
    required this._release,
    required this._attach,
    required this._detach,
  }) : _entries = [for (final tile in manifest.tiles) _TileEntry(tile)];

  final SceneStreamingSettings _settings;
  final SceneTileLoad _load;
  final SceneTileRelease _release;
  final void Function(Node node) _attach;
  final void Function(Node node) _detach;
  final List<_TileEntry> _entries;
  final List<Completer<void>> _readyWaiters = [];

  ({double x, double z})? _position;
  ({double x, double z})? _evaluatedAt;
  int _inFlight = 0;
  Timer? _retryTimer;
  bool _disposed = false;

  /// 表示中の区画の詳細度。テストと計測用。
  Map<String, SceneTileLod> get shownLods => {
    for (final entry in _entries)
      if (entry.shown case final shown?) entry.tile.id: shown.lod,
  };

  /// 表示中の区画の三角形数の合計。計測用。
  int get shownTriangles {
    var total = 0;
    for (final entry in _entries) {
      total += switch (entry.shown?.lod) {
        .detail => entry.tile.detailTriangles,
        .coarse => entry.tile.coarseTriangles,
        null => 0,
      };
    }
    return total;
  }

  /// プレイヤーの水平位置を伝える。[force]がfalseなら、前回の計算位置から
  /// [SceneStreamingSettings.updateStepMeters]以上動いたときだけ計算し直す。
  void updatePosition(double x, double z, {bool force = false}) {
    if (_disposed) {
      return;
    }
    _position = (x: x, z: z);
    final evaluated = _evaluatedAt;
    if (!force && evaluated != null) {
      final moved = math.sqrt(
        math.pow(x - evaluated.x, 2) + math.pow(z - evaluated.z, 2),
      );
      if (moved < _settings.updateStepMeters) {
        return;
      }
    }
    _evaluate();
  }

  /// 失敗した区画の待ち時間を取り消し、次の計算ですぐに再試行させる。
  void retryFailedNow() {
    for (final entry in _entries) {
      entry.retryAt = null;
      entry.failure = null;
    }
  }

  /// 現在位置で必要な区画が、すべて必要な詳細度で表示されるまで待つ。
  /// 必要な区画の読み込みに失敗した場合や、待機中に破棄された場合は例外にする。
  ///
  /// 先に[updatePosition]で位置を伝えておく。位置が未設定なら必要な区画を
  /// 決められないため、待たずに[StateError]で失敗する。
  Future<void> waitUntilReady() {
    if (_position == null) {
      return Future.error(StateError('区画を待つ前にプレイヤー位置を伝えてください'));
    }
    if (_disposed) {
      return Future.error(StateError('区画の読み込み中に描画資源が破棄されました'));
    }
    final completer = Completer<void>();
    _readyWaiters.add(completer);
    _notifyReadyWaiters();
    return completer.future;
  }

  /// 表示中の区画を外して参照を解放する。読み込み中の区画は完了時に解放する。
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _retryTimer?.cancel();
    for (final entry in _entries) {
      _hide(entry);
    }
    final waiters = List.of(_readyWaiters);
    _readyWaiters.clear();
    for (final waiter in waiters) {
      waiter.completeError(StateError('区画の読み込み中に描画資源が破棄されました'));
    }
  }

  void _evaluate() {
    final position = _position;
    if (_disposed || position == null) {
      return;
    }
    _evaluatedAt = position;
    final now = DateTime.now();
    final candidates = <({_TileEntry entry, SceneTileLod lod})>[];
    for (final entry in _entries) {
      entry.distance = sceneTileDistance(entry.tile, position.x, position.z);
      final desired = _desiredLod(entry);
      if (desired == null) {
        _hide(entry);
        continue;
      }
      if (desired == entry.shown?.lod || entry.loading != null) {
        continue;
      }
      final retryAt = entry.retryAt;
      if (retryAt != null && now.isBefore(retryAt)) {
        continue;
      }
      candidates.add((entry: entry, lod: desired));
    }
    candidates.sort((l, r) => l.entry.distance.compareTo(r.entry.distance));
    for (final candidate in candidates) {
      if (_inFlight >= _settings.maxConcurrentLoads) {
        break;
      }
      _start(candidate.entry, candidate.lod);
    }
    _scheduleRetry(now);
    _notifyReadyWaiters();
  }

  /// 境界付近の往復で切替を繰り返さないよう、表示中・読み込み中の詳細度は
  /// 各距離にヒステリシスを足した距離まで維持する。
  SceneTileLod? _desiredLod(_TileEntry entry) {
    final distance = entry.distance;
    final holds = {?entry.shown?.lod, ?entry.loading};
    final hysteresis = _settings.hysteresisMeters;
    final detailLimit = holds.contains(SceneTileLod.detail)
        ? _settings.detailDistanceMeters + hysteresis
        : _settings.detailDistanceMeters;
    if (distance <= detailLimit) {
      return .detail;
    }
    final drawLimit = holds.isNotEmpty
        ? _settings.drawDistanceMeters + hysteresis
        : _settings.drawDistanceMeters;
    if (distance <= drawLimit) {
      return .coarse;
    }
    return null;
  }

  void _start(_TileEntry entry, SceneTileLod lod) {
    final path = _pathOf(entry.tile, lod);
    entry.loading = lod;
    _inFlight++;
    _load(path).then(
      (node) => _onLoaded(entry, lod, path, node),
      onError: (Object error, StackTrace stackTrace) =>
          _onFailed(entry, path, error, stackTrace),
    );
  }

  void _onLoaded(_TileEntry entry, SceneTileLod lod, String path, Node node) {
    _inFlight--;
    if (_disposed) {
      entry.loading = null;
      _releaseQuietly(path);
      return;
    }
    final desired = _desiredLod(entry);
    entry.loading = null;
    if (desired != lod) {
      // 読み込み中に移動・設定変更で不要になった応答は表示しない。
      _releaseQuietly(path);
    } else {
      final previous = entry.shown;
      _attach(node);
      entry.shown = (lod: lod, node: node, path: path);
      entry.failure = null;
      entry.retryAt = null;
      if (previous != null) {
        _detach(previous.node);
        _releaseQuietly(previous.path);
      }
    }
    _evaluate();
  }

  void _onFailed(
    _TileEntry entry,
    String path,
    Object error,
    StackTrace stackTrace,
  ) {
    _inFlight--;
    entry.loading = null;
    if (_disposed) {
      return;
    }
    log('区画モデルの読み込みに失敗しました: $path', error: error, stackTrace: stackTrace);
    entry.failure = error;
    entry.retryAt = DateTime.now().add(_settings.retryDelay);
    _evaluate();
  }

  void _hide(_TileEntry entry) {
    final shown = entry.shown;
    if (shown == null) {
      return;
    }
    entry.shown = null;
    _detach(shown.node);
    _releaseQuietly(shown.path);
  }

  void _scheduleRetry(DateTime now) {
    _retryTimer?.cancel();
    _retryTimer = null;
    DateTime? next;
    for (final entry in _entries) {
      final retryAt = entry.retryAt;
      if (retryAt == null || entry.loading != null) {
        continue;
      }
      if (_desiredLod(entry) == entry.shown?.lod) {
        continue;
      }
      if (next == null || retryAt.isBefore(next)) {
        next = retryAt;
      }
    }
    if (next == null) {
      return;
    }
    final delay = next.difference(now);
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, _evaluate);
  }

  void _notifyReadyWaiters() {
    if (_readyWaiters.isEmpty || _position == null) {
      return;
    }
    Object? failure;
    var pending = false;
    for (final entry in _entries) {
      final desired = _desiredLod(entry);
      if (desired == null || desired == entry.shown?.lod) {
        continue;
      }
      if (entry.loading != null || entry.failure == null) {
        pending = true;
      } else {
        failure ??= entry.failure;
      }
    }
    if (pending) {
      return;
    }
    final waiters = List.of(_readyWaiters);
    _readyWaiters.clear();
    for (final waiter in waiters) {
      if (failure != null) {
        waiter.completeError(failure);
      } else {
        waiter.complete();
      }
    }
  }

  void _releaseQuietly(String path) {
    _release(path).catchError((Object error, StackTrace stackTrace) {
      log('区画モデルの参照を解放できませんでした: $path', error: error, stackTrace: stackTrace);
    });
  }

  static String _pathOf(SceneTile tile, SceneTileLod lod) => switch (lod) {
    .detail => tile.detailPath,
    .coarse => tile.coarsePath,
  };
}

/// 1区画の表示・読み込み状態。[SceneTileStreamer]の内部でだけ変更する。
class _TileEntry(final SceneTile tile) {
  ({SceneTileLod lod, Node node, String path})? shown;
  SceneTileLod? loading;
  Object? failure;
  DateTime? retryAt;
  double distance = double.infinity;
}
