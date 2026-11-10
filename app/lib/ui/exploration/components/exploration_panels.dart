import 'dart:io';
import 'dart:math' as math;

import 'package:app/model/map/model.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/ui/components/clue_photo_message.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:app/ui/components/clue_photo_view.dart';
import 'package:app/ui/components/help_panel.dart';
import 'package:app/ui/exploration/components/map_pin_widget.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class ExplorationPhotoPanel extends StatelessWidget {
  const ExplorationPhotoPanel({
    super.key,
    required this.photo,
    required this.onClose,
  });

  final CluePhotoState photo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final path = photo.path;
    final alt = photo.alt ?? '';
    final body = switch (photo.phase) {
      .ready when path != null => Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            height: 220,
            child: CluePhotoView(file: File(path), alt: alt),
          ),
          if (alt.isNotEmpty) ...[
            const Gap(10),
            Text(
              alt,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColor.onSurface,
              ),
            ),
          ],
        ],
      ),
      .failed => Text(
        cluePhotoFailureMessage(photo.failure ?? .unavailable),
        style: const TextStyle(fontSize: 13, height: 1.5),
      ),
      _ => const Text(
        '写真を読み込んでいます',
        style: TextStyle(fontSize: 13, fontWeight: .w700),
      ),
    };
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(title: 'お手本写真', onClose: onClose, child: body),
      ),
    );
  }
}

class ExplorationMapPanel extends HookConsumerWidget {
  const ExplorationMapPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPinState = useState<MapPinData?>(null);

    final state = ref.watch(explorationViewModelProvider);
    final pins = state.mapPins;
    final playerPos = state.playerPosition;
    final playerUv = playerPos != null
        ? worldXzToMapUv(playerPos.x, playerPos.y)
        : (u: -1.0, v: -1.0);
    final cameraForwardX = state.cameraForwardX;
    final cameraForwardZ = state.cameraForwardZ;
    // 3D空間は +X が東（地図右）、+Z が北（地図上）。
    // atan2(forward.x, forward.z) により北向き=0、東向き=+π/2（時計回り）となる。
    final playerHeadingRadians =
        (cameraForwardX != 0 || cameraForwardZ != 0)
            ? math.atan2(cameraForwardX, cameraForwardZ)
            : 0.0;

    final transformationController = useMemoized(TransformationController.new);
    final mapScale = useState(1.0);

    useEffect(
      () {
        void listener() {
          mapScale.value = transformationController.value.getMaxScaleOnAxis();
        }

        transformationController.addListener(listener);
        return () => transformationController.removeListener(listener);
      },
      [transformationController],
    );

    return AppDialogBarrier(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _ExplorationMapDialogBody(
                  constraints: constraints,
                  onClose: onClose,
                  pins: pins,
                  playerUv: playerUv,
                  playerHeadingRadians: playerHeadingRadians,
                  transformationController: transformationController,
                  mapScale: mapScale,
                  selectedPinState: selectedPinState,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ExplorationMapDialogBody extends HookWidget {
  const _ExplorationMapDialogBody({
    required this.constraints,
    required this.onClose,
    required this.pins,
    required this.playerUv,
    required this.playerHeadingRadians,
    required this.transformationController,
    required this.mapScale,
    required this.selectedPinState,
  });

  final BoxConstraints constraints;
  final VoidCallback onClose;
  final List<MapPinData> pins;
  final ({double u, double v}) playerUv;
  final double playerHeadingRadians;
  final TransformationController transformationController;
  final ValueNotifier<double> mapScale;
  final ValueNotifier<MapPinData?> selectedPinState;

  static const double _mapAspect = 3139.0 / 2472.0;

  @override
  Widget build(BuildContext context) {
    final selectedPin = selectedPinState.value;

    // ヘッダー・パディング・2行テキスト等のマージン(約170px)を差し引いた安全な高さ
    final availableHeight = (constraints.maxHeight - 170).clamp(60.0, 720.0);

    // アスペクト比を保った初期表示サイズを算出
    final containerW = constraints.maxWidth;
    final containerH = availableHeight;
    double displayW;
    double displayH;
    if (containerW / containerH > _mapAspect) {
      displayH = containerH;
      displayW = displayH * _mapAspect;
    } else {
      displayW = containerW;
      displayH = displayW / _mapAspect;
    }

    // 初回描画後、現在地が有効ならそこを中心にズームインする。
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (playerUv.u >= 0.0 &&
              playerUv.u <= 1.0 &&
              playerUv.v >= 0.0 &&
              playerUv.v <= 1.0) {
            const initialScale = 2.5;
            final scaledW = displayW * initialScale;
            final scaledH = displayH * initialScale;
            final dx = playerUv.u * scaledW - displayW / 2;
            final dy = playerUv.v * scaledH - displayH / 2;
            transformationController.value = Matrix4.identity()
              ..translate(-dx, -dy, 0)
              ..scale(initialScale);
          }
        });
        return null;
      },
      [playerUv.u, playerUv.v, displayW, displayH],
    );

    final pinWidth = MapPinWidget.pinWidthFor(scale: mapScale.value);
    final anchorTopOffset =
        MapPinWidget.anchorTopOffsetFor(scale: mapScale.value);

    return AppDialog(
      title: '会場マップ',
      onClose: onClose,
      maxWidth: 920,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            height: availableHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColor.surfaceMid,
                ),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 6.0,
                      clipBehavior: .hardEdge,
                      transformationController:
                          transformationController,
                      boundaryMargin: const EdgeInsets.all(64),
                      child: Center(
                        child: SizedBox(
                          width: displayW,
                          height: displayH,
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
                                  Positioned(
                                    left:
                                        uv.u * displayW -
                                        pinWidth / 2,
                                    top:
                                        uv.v * displayH -
                                        anchorTopOffset,
                                    width: pinWidth,
                                    child: MapPinWidget(
                                      pin: pin,
                                      scale: mapScale.value,
                                      onTap: () {
                                        selectedPinState.value = pin;
                                      },
                                    ),
                                  ),
                              if (playerUv.u >= 0.0 &&
                                  playerUv.u <= 1.0 &&
                                  playerUv.v >= 0.0 &&
                                  playerUv.v <= 1.0)
                                Positioned(
                                  left:
                                      playerUv.u * displayW -
                                      MapPlayerMarkerWidget.size /
                                          2,
                                  top:
                                      playerUv.v * displayH -
                                      MapPlayerMarkerWidget.size /
                                          2,
                                  width: MapPlayerMarkerWidget.size,
                                  height:
                                      MapPlayerMarkerWidget.size,
                                  child: MapPlayerMarkerWidget(
                                    headingRadians:
                                        playerHeadingRadians,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (selectedPin != null)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.95,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                const Gap(6),
                                Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: selectedPin.color,
                                        shape: .circle,
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        selectedPin.name,
                                        maxLines: 1,
                                        overflow: .ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: .bold,
                                          color: AppColor.onSurface,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        selectedPinState.value = null;
                                      },
                                    ),
                                  ],
                                ),
                                const Gap(6),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(8),
          const Text(
            'ピンチやドラッグで拡大・縮小・移動ができます',
            textAlign: .center,
            style: TextStyle(
              fontSize: 12,
              color: AppColor.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ExplorationHelpPanel extends StatelessWidget {
  const ExplorationHelpPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          title: '操作方法',
          onClose: onClose,
          child: const HelpPanel(),
        ),
      ),
    );
  }
}

class ExplorationTeleportPanel extends StatelessWidget {
  const ExplorationTeleportPanel({
    super.key,
    required this.spots,
    required this.onTeleport,
  });

  final List<String> spots;
  final ValueChanged<String> onTeleport;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          title: 'テレポート先',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 9) / 2;
              return Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  for (final spot in spots)
                    SizedBox(
                      width: width,
                      child: _TeleportButton(
                        label: spot,
                        onTap: () => onTeleport(spot),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TeleportButton extends StatelessWidget {
  const _TeleportButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColor.primaryContainer,
          foregroundColor: AppColor.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: .ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: .w700),
        ),
      ),
    );
  }
}

class ExplorationExitPanel extends StatelessWidget {
  const ExplorationExitPanel({
    super.key,
    required this.onContinue,
    required this.onExit,
  });

  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 420,
          title: '探索を終了しますか？',
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              const Text(
                '撮影はまだしていません。このプレイは順位に入りません。',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: AppColor.onSurfaceVariant,
                ),
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: .end,
                children: [
                  OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.onSurface,
                      side: const BorderSide(color: AppColor.outline, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '続ける',
                      style: TextStyle(fontSize: 14, fontWeight: .w700),
                    ),
                  ),
                  const Gap(9),
                  FilledButton(
                    onPressed: onExit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColor.expoRed,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '終了する',
                      style: TextStyle(fontSize: 14, fontWeight: .w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorationSubmittingOverlay extends StatelessWidget {
  const ExplorationSubmittingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 420,
          child: Row(
            mainAxisSize: .min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppColor.primary,
                ),
              ),
              const Gap(13),
              const Text(
                '撮影を送信しています…',
                style: TextStyle(fontSize: 15, fontWeight: .w800, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 撮影の結果が不明なときの確認パネル。別の姿勢での撮り直しは出さず、
/// 保存済み結果の照会と同じ撮影の再送だけを提供する。
class ExplorationSubmitPendingOverlay extends StatelessWidget {
  const ExplorationSubmitPendingOverlay({
    super.key,
    required this.onCheck,
    required this.onResend,
  });

  final VoidCallback onCheck;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 420,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              const Text(
                '撮影の結果を確認できていません',
                style: TextStyle(fontSize: 15, fontWeight: .w800, height: 1.2),
              ),
              const Gap(9),
              const Text(
                '通信が切れたため、撮影が保存されたかどうか分かりません。'
                '撮影した姿勢のまま、結果の確認か再送をしてください。',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const Gap(13),
              Row(
                mainAxisAlignment: .end,
                children: [
                  OutlinedButton(
                    onPressed: onCheck,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '結果を確認',
                      style: TextStyle(fontSize: 14, fontWeight: .w700),
                    ),
                  ),
                  const Gap(9),
                  FilledButton(
                    onPressed: onResend,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '再送する',
                      style: TextStyle(fontSize: 14, fontWeight: .w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// セッションの有効期限切れを案内し、再挑戦へ誘導するパネル。
class ExplorationSessionExpiredOverlay extends StatelessWidget {
  const ExplorationSessionExpiredOverlay({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 420,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              const Text(
                'プレイの有効期限が切れました',
                style: TextStyle(fontSize: 15, fontWeight: .w800, height: 1.2),
              ),
              const Gap(9),
              const Text(
                'このプレイでは新しく撮影できません。モード選択へ戻って再挑戦してください。',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const Gap(13),
              Row(
                mainAxisAlignment: .end,
                children: [
                  FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'モード選択へ戻る',
                      style: TextStyle(fontSize: 14, fontWeight: .w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
