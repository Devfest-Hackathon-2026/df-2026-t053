import 'package:app/model/photo/model.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/ui/exploration/components/exploration_camera_drag_view.dart';
import 'package:app/ui/exploration/components/exploration_bottom_bar.dart';
import 'package:app/ui/exploration/components/exploration_joy_stick.dart';
import 'package:app/ui/exploration/components/exploration_panels.dart';
import 'package:app/ui/exploration/components/exploration_guide_panel.dart';
import 'package:app/ui/exploration/components/exploration_side_actions.dart';
import 'package:app/ui/exploration/components/exploration_top_bar.dart';
import 'package:app/ui/exploration/components/exploration_result_overlay.dart';
import 'package:app/model/exploration_mode.dart';
import 'package:app/ui/exploration/view_model.dart';
import 'package:app/ui/mode_select/screen.dart';
import 'package:app/ui/ranking/screen.dart';
import 'package:app/ui/settings/screen.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_scene/scene.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationScreen extends HookConsumerWidget {
  const ExplorationScreen({
    super.key,
    this.mode = ExplorationMode.free,
    this.spot,
  });

  final ExplorationMode mode;
  final String? spot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationViewModelProvider);
    final vm = ref.watch(explorationViewModelProvider.notifier);
    final photo = ref.watch(cluePhotoProvider);
    final guide = ref.watch(guidePanelViewModelProvider);
    final guideVm = ref.watch(guidePanelViewModelProvider.notifier);
    final modeSelectVisible = useState(false);
    final rankOverlayVisible = useState(false);
    final settingsOverlayVisible = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.startPlay(mode: mode, spot: spot);
        vm.loadModel();
      });
      return null;
    }, const []);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // 同じSceneの描画先を競合させず、結果比較中は探索を保持したまま止める。
            child: Offstage(
              offstage: state.showResult,
              child: TickerMode(
                enabled: !state.showResult,
                child: _ShotFrame(
                  photo: photo,
                  showFrame: state.showShotFrame,
                  child: ExplorationCameraDragView(
                    child: SceneView(
                      vm.scene,
                      onTick: vm.onTick,
                      warmUp: true,
                      loading: vm.loading,
                      loadingBuilder: (context, progress) => ColoredBox(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              const CircularProgressIndicator(),
                              const Gap(16),
                              Text(
                                '${state.asset.title} '
                                'を読み込み中… ${(progress * 100).toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 120,
            left: 100,
            child: ExplorationJoyStick(),
          ),
          if (!state.isLoading) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: ExplorationTopBar(
                  modeLabel: vm.modeLabel,
                  onBack: () => vm.openPanel(ExplorationPanel.exitConfirm),
                  onHelp: () => vm.openPanel(ExplorationPanel.help),
                  onMap: () => vm.openPanel(ExplorationPanel.map),
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: ExplorationSideActions(
                  onPhoto: () => vm.openPanel(ExplorationPanel.photo),
                  showFrame: state.showShotFrame,
                  onToggleFrame: vm.toggleShotFrame,
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: ExplorationBottomBar(
                  showTeleport: state.mode == .free,
                  onTeleport: () => vm.openPanel(ExplorationPanel.teleport),
                  onGuide: () => vm.openPanel(ExplorationPanel.guide),
                  onShutter: vm.submitShot,
                ),
              ),
            ),
          ],
          switch (state.panel) {
            ExplorationPanel.photo => ExplorationPhotoPanel(
              photo: photo,
              onClose: vm.closePanel,
            ),
            ExplorationPanel.map => ExplorationMapPanel(onClose: vm.closePanel),
            ExplorationPanel.help => ExplorationHelpPanel(
              onClose: vm.closePanel,
            ),
            ExplorationPanel.guide => ExplorationGuidePanel(
              state: guide,
              message: guideVm.message,
              onPlayback: guideVm.togglePlayback,
              onRegenerate: guideVm.canRegenerate ? guideVm.generate : null,
              onClose: vm.closePanel,
            ),
            ExplorationPanel.teleport => ExplorationTeleportPanel(
              spots: kTeleportSpots,
              onTeleport: vm.teleportTo,
            ),
            ExplorationPanel.exitConfirm => ExplorationExitPanel(
              onContinue: vm.closePanel,
              onExit: () {
                vm.endPlay();
                context.go('/');
              },
            ),
            ExplorationPanel.submitting => const ExplorationSubmittingOverlay(),
            ExplorationPanel.submitPending => ExplorationSubmitPendingOverlay(
              onCheck: vm.checkShotResult,
              onResend: vm.resendShot,
            ),
            ExplorationPanel.none => const SizedBox.expand(),
          },
          if (state.sessionExpired)
            Positioned.fill(
              child: ExplorationSessionExpiredOverlay(
                onRetry: () {
                  vm.acknowledgeSessionExpired();
                  context.go('/');
                },
              ),
            ),
          if (vm.shotMessage case final message?)
            Positioned(
              left: 0,
              bottom: 24,
              right: 0,
              child: Center(child: Text(message)),
            ),
          Positioned.fill(
            child: ExplorationResultOverlay(
              onModeSelect: () => modeSelectVisible.value = true,
              onRanking: () => rankOverlayVisible.value = true,
            ),
          ),
          if (state.loadFailed && !state.isLoading)
            const Positioned(
              left: 0,
              bottom: 24,
              right: 0,
              child: Center(child: Text('モデルの読み込みに失敗しました')),
            ),
          if (rankOverlayVisible.value)
            Positioned.fill(
              child: RankingScreen(
                revisionId: state.session?.revisionId,
                initialMode: state.mode,
                onClose: () => rankOverlayVisible.value = false,
              ),
            ),
          if (settingsOverlayVisible.value)
            Positioned.fill(
              child: SettingsScreen(
                credits: state.revision?.credits ?? const [],
                onClose: () => settingsOverlayVisible.value = false,
              ),
            ),
          if (modeSelectVisible.value)
            ModeSelectScreen(
              onStartPlay: (mode, spot) {
                modeSelectVisible.value = false;
                vm.startPlay(mode: mode, spot: spot);
              },
              onOpenRanking: () => rankOverlayVisible.value = true,
              onOpenSettings: () => settingsOverlayVisible.value = true,
            ),
        ],
      ),
    );
  }
}

/// 写真と同じ縦横比の撮影枠。3Dは画面いっぱいに描き、その上に枠を重ねる。
class _ShotFrame extends StatelessWidget {
  const _ShotFrame({
    required this.photo,
    required this.showFrame,
    required this.child,
  });

  final CluePhotoState photo;
  final bool showFrame;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = photo.width;
    final height = photo.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (showFrame &&
            photo.phase == .ready &&
            width != null &&
            height != null &&
            width > 0 &&
            height > 0)
          LayoutBuilder(
            builder: (context, constraints) {
              final frameSize = _frameSize(
                viewport: constraints.biggest,
                aspectRatio: width / height,
              );
              return Center(
                child: IgnorePointer(
                  child: CustomPaint(
                    size: frameSize,
                    painter: _ShotFramePainter(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  static const double _frameVerticalPaddingRatio = 0.08;

  static Size _frameSize({
    required Size viewport,
    required double aspectRatio,
  }) {
    final viewportAspect = viewport.width / viewport.height;
    if (viewportAspect > aspectRatio) {
      // 画面が写真より横長：上下に余白を入れて、幅を比率で求める
      final height = viewport.height * (1 - _frameVerticalPaddingRatio * 2);
      final width = height * aspectRatio;
      return Size(width, height);
    } else {
      // 画面が写真より縦長または同じ：幅を画面いっぱいにして高さを比率で求める
      final width = viewport.width;
      final height = width / aspectRatio;
      return Size(width, height);
    }
  }
}

/// カメラファインダー風の撮影枠を描画する。
class _ShotFramePainter extends CustomPainter {
  _ShotFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    // 外枠
    canvas.drawRRect(rrect, borderPaint);

    // 四隅の L字マーカー
    final cornerLength = size.shortestSide * 0.12;
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    _drawCorner(canvas, Offset.zero, cornerLength, cornerPaint, 1, 1);
    _drawCorner(
      canvas,
      Offset(size.width, 0),
      cornerLength,
      cornerPaint,
      -1,
      1,
    );
    _drawCorner(
      canvas,
      Offset(0, size.height),
      cornerLength,
      cornerPaint,
      1,
      -1,
    );
    _drawCorner(
      canvas,
      Offset(size.width, size.height),
      cornerLength,
      cornerPaint,
      -1,
      -1,
    );

    // 中央の十字線
    final crosshairSize = size.shortestSide * 0.03;
    final crosshairPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx - crosshairSize, center.dy),
      Offset(center.dx + crosshairSize, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crosshairSize),
      Offset(center.dx, center.dy + crosshairSize),
      crosshairPaint,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Offset corner,
    double length,
    Paint paint,
    int directionX,
    int directionY,
  ) {
    canvas.drawLine(
      corner,
      Offset(corner.dx + length * directionX, corner.dy),
      paint,
    );
    canvas.drawLine(
      corner,
      Offset(corner.dx, corner.dy + length * directionY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShotFramePainter oldPainter) =>
      oldPainter.color != color;
}
