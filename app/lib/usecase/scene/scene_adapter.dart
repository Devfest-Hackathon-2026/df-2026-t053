import 'dart:convert';
import 'dart:io' show stdout;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/model/scene_streaming/model.dart';
import 'package:app/provider/assets/asset_store.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:app/usecase/play/collision_resolver.dart';
import 'package:app/usecase/scene/scene_tile_streamer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_math/vector_math.dart' as vm;

part 'scene_adapter.g.dart';

const double kGroundTopY = 8.4;
const double kPlayerEyeHeight = 11;
const double kStartPositionX = 580.0;
const double kStartPositionZ = 123.4;
const double kRingCenterX = -4.2;
const double kRingCenterZ = 0.2;
const bool kRunsWithAutoloadHarness = bool.fromEnvironment('EXPO_AUTOLOAD');

// 色は sRGB ではなく linear RGB / RGBA。Vector は可変なので、各シーンへは
// clone を渡し、破棄・再生成時に設定を共有しない。
final _skyZenithColor = vm.Vector3(0.06, 0.22, 0.55);
final _skyHorizonColor = vm.Vector3(0.55, 0.72, 0.9);
// 参考写真のグレーの石舗装。芝生の緑みを除き、明るすぎない反射率にする。
final _groundColor = vm.Vector4(0.22, 0.225, 0.23, 1);
final _waterColor = vm.Vector4(0.08, 0.28, 0.4, 1);
const double _fogStart = 900;
const double _fogEnd = 2200;

/// 区画の読み込み距離の初期値。実機計測では `--dart-define` でm単位の整数を渡して調整する。
/// 例: `--dart-define=SCENE_DRAW_DISTANCE=1200 --dart-define=SCENE_DETAIL_DISTANCE=150`
///
/// 描画距離の既定値は霧の終端（[_fogEnd]）に合わせ、霧で見えなくなる前に区画が
/// 消えないようにする。短くするほど遠景の区画を読み込まないが、霧の途中で消える。
final SceneStreamingSettings kSceneStreamingSettings = SceneStreamingSettings(
  drawDistanceMeters: const int.fromEnvironment(
    'SCENE_DRAW_DISTANCE',
    defaultValue: 2200,
  ).toDouble(),
  detailDistanceMeters: const int.fromEnvironment(
    'SCENE_DETAIL_DISTANCE',
    defaultValue: 200,
  ).toDouble(),
);

/// 対応する区画manifestの版。加工コマンドの MANIFEST_VERSION と合わせる。
const int kSceneTileManifestVersion = 1;

/// 出題版の垂直画角を投影へ反映する。未設定と 0 度以下・180 度以上は変えない。
void applyShotVerticalFov(PerspectiveProjection projection, double? degrees) {
  if (degrees == null || degrees <= 0 || degrees >= 180) return;
  projection.fovRadiansY = vm.radians(degrees);
}

@riverpod
class SceneAdapter extends _$SceneAdapter {
  @override
  void build() {
    scene = Scene();
    player = Node(name: 'player');
    _projection = PerspectiveProjection(
      fovRadiansY: vm.radians(60),
      near: 1,
      far: 8000,
    );
    cameraComponent = CameraComponent(projection: _projection);
    loading = ResourceGroup();
    _streamer = null;
    _streamerLoad = null;
    _maxTileDiagonalMeters = null;

    player.addComponent(cameraComponent);
    scene.add(player);
    final sunlight = DirectionalLight(
      direction: vm.Vector3(0.4, -1, 0.35),
      color: vm.Vector3(1, 0.96, 0.88),
      intensity: 3,
    );
    scene.directionalLight = sunlight;
    final sky = GradientSkySource(
      zenithColor: _skyZenithColor.clone(),
      horizonColor: _skyHorizonColor.clone(),
      groundColor: _groundColor.xyz,
      // 空は太陽へ向かう方向、既存のライトは光が進む方向。
      sunDirection: -sunlight.direction,
      sunColor: sunlight.color * sunlight.intensity,
    );
    scene.skybox = Skybox(sky);
    // 静的な空は初回だけ焼く。低解像度で初回フレームの負荷を抑える。
    scene.skyEnvironment = SkyEnvironment(
      sky,
      refresh: .manual,
      faceResolution: 64,
      equirectWidth: 256,
    );
    // 会場内の近〜中距離はクリアに保ち、地面の端より手前で空へ溶かす。
    scene.fog
      ..enabled = true
      ..mode = .linear
      ..color = _skyHorizonColor.clone()
      ..start = _fogStart
      ..end = _fogEnd;
    _addGround();
    _addWaterPlaza();

    ref.onDispose(() {
      // ノードを外して共有キャッシュの参照を返してから、シーンを破棄する。
      _streamer?.dispose();
      scene.dispose();
    });
  }

  late Scene scene;
  late Node player;
  late CameraComponent cameraComponent;
  late ResourceGroup loading;
  late PerspectiveProjection _projection;

  /// 区画manifestの読み込み前はnull。
  SceneTileStreamer? _streamer;
  Future<SceneTileStreamer>? _streamerLoad;

  /// 区画範囲の対角の最大値。manifestの読み込み前はnull。
  double? _maxTileDiagonalMeters;

  Camera get camera => cameraComponent.toCamera();

  void setStartPosition(double x, double z, {double? y}) {
    final height = y ?? kPlayerEyeHeight;
    player.localTransform.setTranslation(vm.Vector3(x, height, z));
    player.markTransformDirty();
    // 開始・テレポートは移動量に関係なく、必要な区画をすぐに計算し直す。
    _streamer?.updatePosition(x, z, force: true);
  }

  vm.Vector3 get playerPosition {
    return player.localTransform.getTranslation();
  }

  void setPlayerPosition(double x, double y, double z) {
    player.localTransform.setTranslation(vm.Vector3(x, y, z));
    player.markTransformDirty();
    _streamer?.updatePosition(x, z);
  }

  void setPlayerRotation(vm.Matrix3 rotation) {
    player.localTransform.setRotation(rotation);
    player.markTransformDirty();
  }

  /// 必要な区画を読み込み、表示できるまで待つ。戻り値は待った秒数。
  ///
  /// [startAt]を渡すと、その完了を待ってから開始点の周りの区画を読み込む。
  /// 開始点の決定（セッション作成）と区画manifestの読み込みを並行させるためで、
  /// プレイヤーの位置は変えない。省略した場合は現在のプレイヤー位置を使う。
  /// [startAt]の失敗は、そのまま例外として返す。
  ///
  /// 読み込み済みの区画は再利用し、足りない区画だけを読み込む。失敗した区画は
  /// 待ち時間を取り消して再試行し、それでも失敗したら例外にする。
  ///
  /// 呼び出し全体を[loading]へ1件として登録するため、進行度は0から1へ戻らずに進む。
  /// 歩行中の区画の読み込みは[loading]へ登録しない。
  Future<double> loadModel({Future<({double x, double z})>? startAt}) =>
      loading.add(_loadModel(startAt, null));

  Future<double> _loadModel(
    Future<({double x, double z})>? startAt,
    bool Function()? isCurrent,
  ) async {
    _applyShotFov();
    final asset = ref.read(assetStoreProvider).resolve();
    final stopwatch = Stopwatch()..start();
    final streamerLoad = _streamerLoad ??= _createStreamer(asset.assetPath);
    ({double x, double z}) position;
    if (startAt == null) {
      final current = playerPosition;
      position = (x: current.x, z: current.z);
    } else {
      // 先に失敗した方の例外をそのまま返し、もう一方の失敗も未処理にしない。
      await Future.wait<void>([streamerLoad, startAt]);
      position = await startAt;
    }
    final streamer = await streamerLoad;
    if (!ref.mounted || (isCurrent != null && !isCurrent())) {
      return stopwatch.elapsedMicroseconds / 1e6;
    }
    streamer.retryFailedNow();
    streamer.updatePosition(position.x, position.z, force: true);
    await streamer.waitUntilReady();
    stopwatch.stop();
    if (kRunsWithAutoloadHarness) {
      stdout.writeln(
        'EXPO_BOOT: ${asset.assetPath} imported=true '
        'seconds=${(stopwatch.elapsedMicroseconds / 1e6).toStringAsFixed(2)} '
        'tiles=${streamer.shownLods.length} '
        'triangles=${streamer.shownTriangles}',
      );
    }
    return stopwatch.elapsedMicroseconds / 1e6;
  }

  /// 結果専用カメラの周囲を準備する。プレイヤーの姿勢は変更しない。
  Future<void> prepareResultCamera(
    Camera camera, {
    required bool Function() isCurrent,
  }) async {
    await Scene.initializeStaticResources();
    if (!ref.mounted || !isCurrent()) return;
    await loading.add(
      _loadModel(
        Future.value((x: camera.position.x, z: camera.position.z)),
        isCurrent,
      ),
    );
    if (!ref.mounted || !isCurrent()) return;
    final views = [RenderView(camera: camera)];
    await scene.warmUp(views, sliceBudget: const Duration(milliseconds: 4));
  }

  /// 区画を切り替える前にGPUの描画結果を固定する。2視点の区画を同時に保持しない。
  Future<ui.Image> captureResultCamera(
    Camera camera, {
    required int width,
    required int height,
    required bool Function() isCurrent,
  }) async {
    await prepareResultCamera(camera, isCurrent: isCurrent);
    if (!ref.mounted || !isCurrent()) {
      throw StateError('結果比較の準備が取り消されました');
    }
    // 大きな写真も結果欄に十分な解像度へ制限する。投影比率は元写真に合わせる。
    final scale = math.min(1.0, 1024 / math.max(width, height));
    final imageWidth = math.max(1, (width * scale).round());
    final imageHeight = math.max(1, (height * scale).round());
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(scale);
    try {
      scene.render(
        camera,
        canvas,
        viewport: ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        pixelRatio: scale,
      );
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(imageWidth, imageHeight);
      } finally {
        picture.dispose();
      }
    } finally {
      // 描画自体が失敗した場合も記録中のPictureを残さない。
      if (recorder.isRecording) recorder.endRecording().dispose();
    }
  }

  /// 枠内の垂直画角を出題版の固定値にする。版が無いときは初期値のままにする。
  /// far 面は描画距離側で更新するため、同じ projection の画角だけを変える。
  void _applyShotFov() {
    applyShotVerticalFov(
      _projection,
      ref.read(challengeProvider).revision?.shotVerticalFovDegrees,
    );
  }

  Future<SceneTileStreamer> _createStreamer(String manifestPath) async {
    try {
      final manifest = await _loadManifest(manifestPath);
      if (!ref.mounted) {
        throw StateError('区画manifestの読み込み中に描画資源が破棄されました');
      }
      _maxTileDiagonalMeters = manifest.tiles.fold<double>(
        0,
        (longest, tile) => math.max(
          longest,
          math.sqrt(
            math.pow(tile.maxX - tile.minX, 2) +
                math.pow(tile.maxZ - tile.minZ, 2),
          ),
        ),
      );
      _applyFarPlane();
      final streamer = SceneTileStreamer(
        manifest: manifest,
        settings: kSceneStreamingSettings,
        load: loadScene,
        release: releaseScene,
        attach: scene.add,
        detach: scene.remove,
      );
      _streamer = streamer;
      return streamer;
    } catch (_) {
      // 次のloadModelでmanifestから読み直せるようにする。
      _streamerLoad = null;
      rethrow;
    }
  }

  static Future<SceneTileManifest> _loadManifest(String path) async {
    final text = await rootBundle.loadString(path);
    final manifest = switch (jsonDecode(text)) {
      final Map<String, Object?> json => SceneTileManifest.fromJson(json),
      _ => throw FormatException('区画manifestの形式が不正です: $path'),
    };
    if (manifest.version != kSceneTileManifestVersion) {
      throw FormatException(
        '区画manifestの版 ${manifest.version} に対応していません: $path',
      );
    }
    return manifest;
  }

  /// 描画距離の外にある区画は読み込まないため、far面も描画距離に合わせる。
  /// 読み込んだ区画の遠い端まで描くよう、ヒステリシスと区画の対角を足す。
  /// 地面が霧に溶ける前に切れないよう、霧の終端より手前にはしない。
  void _applyFarPlane() {
    final diagonal = _maxTileDiagonalMeters;
    if (diagonal == null) {
      return;
    }
    _projection.far = math.max(
      _fogEnd,
      kSceneStreamingSettings.drawDistanceMeters +
          kSceneStreamingSettings.hysteresisMeters +
          diagonal,
    );
  }

  void _addGround() {
    final transform = vm.Matrix4.identity()
      ..setTranslation(vm.Vector3(0, kGroundTopY - 0.05, 0));
    final ground = Node(
      name: 'ground',
      mesh: Mesh(
        CuboidGeometry(vm.Vector3(6000, 0.1, 6000)),
        PhysicallyBasedMaterial()
          ..baseColorFactor = _groundColor.clone()
          ..metallicFactor = 0
          ..roughnessFactor = 0.95,
      ),
      localTransform: transform,
    );
    scene.add(ground);
  }

  void _addWaterPlaza() {
    // 水盤の輪郭（kWaterPlazaOutline）の北端と南端を結ぶ帯状の面で描く。
    // 輪郭表は水域判定（isInWaterPlaza）と共用で、形が常に対になる。
    final outline = kWaterPlazaOutline;
    final positions = Float32List(outline.length * 2 * 3);
    final normals = Float32List(outline.length * 2 * 3);
    for (var i = 0; i < outline.length; i++) {
      final point = outline[i];
      positions.setAll(i * 6, [point.x, 0, point.northZ, point.x, 0, point.southZ]);
      normals.setAll(i * 6, [0, 1, 0, 0, 1, 0]);
    }
    final indices = <int>[];
    for (var i = 0; i < outline.length - 1; i++) {
      final northA = i * 2;
      final southA = i * 2 + 1;
      final northB = i * 2 + 2;
      final southB = i * 2 + 3;
      indices.addAll([northA, northB, southA, northB, southB, southA]);
    }
    final transform = vm.Matrix4.identity()
      ..setTranslation(vm.Vector3(0, kGroundTopY + 0.06, 0));
    final water = Node(
      name: 'water_plaza',
      mesh: Mesh(
        MeshGeometry.fromArrays(
          positions: positions,
          normals: normals,
          indices: indices,
        ),
        PhysicallyBasedMaterial()
          ..baseColorFactor = _waterColor.clone()
          ..metallicFactor = 0
          ..roughnessFactor = 0.35
          // 平らな面なので、裏側から見えても描く。
          ..doubleSided = true,
      ),
      localTransform: transform,
    );
    scene.add(water);
  }
}
