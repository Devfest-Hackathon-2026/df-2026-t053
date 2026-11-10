import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:app/ui/exploration/components/map_pin_widget.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/utils/color.dart';

/// 探索画面の右上に常時表示するミニマップ（現在地周辺の拡大表示）。
/// タップすると全体会場マップダイアログ（[ExplorationMapPanel]）を開く。
class ExplorationMiniMap extends ConsumerWidget {
  const ExplorationMiniMap({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  /// ミニマップウィジェットの幅
  static const double width = 128.0;

  /// ミニマップウィジェットの高さ
  static const double height = 96.0;

  /// ミニマップ内部に描画する仮想マップの拡大倍率（現在地周辺をズーム表示）
  static const double _zoomScale = 3.6;

  /// 地図画像の比率（3139 x 2472）
  static const double _mapAspect = 3139.0 / 2472.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationViewModelProvider);
    final pins = state.mapPins;
    final playerPos = state.playerPosition;
    final playerUv = playerPos != null
        ? worldXzToMapUv(playerPos.x, playerPos.y)
        : (u: -1.0, v: -1.0);
    final cameraForwardX = state.cameraForwardX;
    final cameraForwardZ = state.cameraForwardZ;
    final playerHeadingRadians =
        (cameraForwardX != 0 || cameraForwardZ != 0)
            ? math.atan2(cameraForwardX, cameraForwardZ)
            : 0.0;

    final mapW = width * _zoomScale;
    final mapH = mapW / _mapAspect;

    // プレイヤー位置がミニマップ中央に来るようオフセットし、地図端ではクランプする
    final focusU = playerUv.u.clamp(0.0, 1.0);
    final focusV = playerUv.v.clamp(0.0, 1.0);
    final mapLeft = (width / 2 - focusU * mapW).clamp(width - mapW, 0.0);
    final mapTop = (height / 2 - focusV * mapH).clamp(height - mapH, 0.0);

    // ミニマップでは現在地周辺のピンのみ表示し、遠いピンは省略する。
    const visibleRadiusSq = 0.0225; // 0.15 * 0.15
    final pinWidth = MapPinWidget.pinWidthFor(scale: _zoomScale);
    final anchorTopOffset =
        MapPinWidget.anchorTopOffsetFor(scale: _zoomScale);

    return GestureDetector(
      onTap: onTap,
      behavior: .opaque,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColor.surfaceMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.white,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40222426),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: .hardEdge,
            children: [
              Positioned(
                left: mapLeft,
                top: mapTop,
                width: mapW,
                height: mapH,
                child: Stack(
                  clipBehavior: .none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/map/yumeshima_map_zones.png',
                        fit: .fill,
                      ),
                    ),
                    for (final pin in pins)
                      if (pin.uv case final uv?)
                        if ((uv.u - focusU) * (uv.u - focusU) +
                                (uv.v - focusV) * (uv.v - focusV) <=
                            visibleRadiusSq)
                          Positioned(
                            left: uv.u * mapW - pinWidth / 2,
                            top: uv.v * mapH - anchorTopOffset,
                            width: pinWidth,
                            child: IgnorePointer(
                              child: MapPinWidget(
                                pin: pin,
                                scale: _zoomScale,
                              ),
                            ),
                          ),
                    if (playerUv.u >= 0.0 &&
                        playerUv.u <= 1.0 &&
                        playerUv.v >= 0.0 &&
                        playerUv.v <= 1.0)
                      Positioned(
                        left: playerUv.u * mapW - MapPlayerMarkerWidget.size / 2,
                        top: playerUv.v * mapH - MapPlayerMarkerWidget.size / 2,
                        width: MapPlayerMarkerWidget.size,
                        height: MapPlayerMarkerWidget.size,
                        child: MapPlayerMarkerWidget(
                          headingRadians: playerHeadingRadians,
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 5,
                bottom: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: .circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.open_in_full,
                      size: 11,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
