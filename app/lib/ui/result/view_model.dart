import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app/model/result_comparison/model.dart';
import 'package:app/usecase/scene/scene_adapter.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vec;
import 'package:app/model/exploration_mode.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_model.freezed.dart';
part 'view_model.g.dart';

@freezed
abstract class ResultState with _$ResultState {
  const factory ResultState({
    required ExplorationMode mode,
    @Default(842) int score,
    @Default(1000) int maxScore,
    @Default(true) bool isPersonalBest,
    @Default(2.3) double distanceMeters,
    @Default(8) int yawDegrees,
    @Default(3) int pitchDegrees,
    @Default(12) int rank,
    @Default('開会前の朝、人がいない広場で輪の影が柱の列と重なる瞬間を待って撮られました。') String episode,
    @Default('木造の梁を組み上げた輪の構造は、下から見上げると継ぎ目のリズムが続いて見えます。') String highlight,
  }) = _ResultState;
}

@riverpod
class ResultViewModel extends _$ResultViewModel {
  @override
  ResultState build(ExplorationMode mode, SubmitShotResponse result) {
    // 正式な結果はプレイデータ層が保持するサーバーの結果DTOから表示する。
    final shot = result.shot;
    final entry = result.myRankingEntry;
    return ResultState(
      mode: mode,
      score: shot.score,
      isPersonalBest:
          entry.score == shot.score &&
          entry.achieveTime.isAtSameMomentAs(shot.createTime),
      distanceMeters: shot.distanceMeters,
      yawDegrees: shot.yawDiffDegrees.round(),
      pitchDegrees: shot.pitchDiffDegrees.round(),
      rank: entry.rank,
      episode: result.reveal.story,
      highlight: result.reveal.highlight,
    );
  }
}

/// 公開DTOの絶対視点位置をそのまま使う。歩行者の視点高さは加算しない。
///
/// 向きは探索の描画（`PlayController.buildPlayerRotation` を、前方 +Z のカメラに掛けたもの）と
/// 揃える。実行時の座標は +X 東・+Z 北なので、yaw 0° は +Z、90° は +X を向く
/// （content/provenance/README.md「実行時の座標の向き」）。pitch は仕様どおり上向きが正。
PerspectiveCamera resultCamera(CameraPose pose) {
  final yaw = vec.radians(pose.yawDegrees);
  final pitch = vec.radians(pose.pitchDegrees);
  final position = vec.Vector3(pose.positionX, pose.positionY, pose.positionZ);
  final forward = vec.Vector3(
    math.sin(yaw) * math.cos(pitch),
    math.sin(pitch),
    math.cos(yaw) * math.cos(pitch),
  );
  return PerspectiveCamera(
    position: position,
    target: position + forward,
    fovRadiansY: vec.radians(pose.verticalFovDegrees),
    fovNear: 1,
    fovFar: 8000,
  );
}

@Riverpod(retry: _noComparisonRetry)
class ResultComparisonViewModel extends _$ResultComparisonViewModel {
  @override
  Future<ResultComparisonImages> build(
    SubmitShotResponse result,
    int width,
    int height,
  ) async {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('比較写真の寸法が不正です');
    }
    // DTOはmutableなので、待機前に両方の姿勢を固定する。
    final shot = result.shot.camera.copyWith();
    final goal = result.reveal.goalCamera.copyWith();
    final adapter = ref.watch(sceneAdapterProvider.notifier);
    var current = true;
    final images = <ui.Image>[];
    void release() {
      for (final image in images) {
        image.dispose();
      }
      images.clear();
    }

    ref.onDispose(() {
      current = false;
      release();
    });
    Future<ui.Image> capture(CameraPose pose) async {
      final image = await adapter.captureResultCamera(
        resultCamera(pose),
        width: width,
        height: height,
        isCurrent: () => current,
      );
      if (!current) {
        image.dispose();
        throw StateError('結果比較の準備が取り消されました');
      }
      images.add(image);
      return image;
    }

    try {
      // 1枚目の画素が固定されてから2枚目の区画へ移る。描画先と区画を競合させない。
      final shotImage = await capture(shot);
      final goalImage = await capture(goal);
      return ResultComparisonImages(shot: shotImage, goal: goalImage);
    } catch (error, stack) {
      release();
      log('結果の3Dを準備できませんでした', error: error, stackTrace: stack);
      rethrow;
    }
  }
}

Duration? _noComparisonRetry(int retryCount, Object error) => null;
