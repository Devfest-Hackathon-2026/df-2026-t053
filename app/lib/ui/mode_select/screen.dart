import 'dart:io';
import 'dart:math' as math;

import 'package:app/model/exploration_mode.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/model/play/model.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:app/ui/components/preparing_overlay.dart';
import 'package:app/ui/components/help_panel.dart';
import 'package:app/ui/components/clue_photo_view.dart';
import 'package:app/ui/mode_select/components/boot_overlay.dart';
import 'package:app/ui/mode_select/components/mode_card.dart';
import 'package:app/ui/mode_select/components/mode_record_summary.dart';
import 'package:app/ui/mode_select/components/mode_select_header.dart';
import 'package:app/ui/mode_select/components/pending_shot_dialog.dart';
import 'package:app/ui/mode_select/components/spot_select_panel.dart';
import 'package:app/ui/mode_select/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class ModeSelectScreen extends HookConsumerWidget {
  const ModeSelectScreen({
    super.key,
    required this.onStartPlay,
    required this.onOpenRanking,
    required this.onOpenSettings,
  });

  final void Function(ExplorationMode mode, String? spot) onStartPlay;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modeSelectViewModelProvider);
    final vm = ref.watch(modeSelectViewModelProvider.notifier);
    final photo = ref.watch(cluePhotoProvider);
    final helpVisible = useState(false);
    final pendingDismissed = useState(false);
    final resumedCompleted = useRef(false);

    ref.listen(modeSelectViewModelProvider.select((state) => state.flow), (
      previous,
      next,
    ) {
      // push後も背後の画面は残る。表示中のルートだけが遷移を担当する。
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (next == ModeSelectFlow.done && previous != ModeSelectFlow.done) {
        final target = ref.read(modeSelectViewModelProvider);
        // この画面から開始した後のcompletedは、起動時の結果復旧ではない。
        resumedCompleted.value = true;
        vm.resetFlow();
        onStartPlay(target.mode, target.spot);
      }
    });

    // 復旧した保存済み結果は、その版の写真が揃ってから探索を開く。
    void resumeCompleted() {
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (resumedCompleted.value) return;
      final current = ref.read(modeSelectViewModelProvider);
      final currentPhoto = ref.read(cluePhotoProvider);
      if (current.boot != .ready ||
          current.playPhase != .completed ||
          currentPhoto.phase != .ready) {
        return;
      }
      resumedCompleted.value = true;
      onStartPlay(_explorationModeOf(current.pendingSessionMode), null);
    }

    ref.listen(
      modeSelectViewModelProvider.select(
        (state) => (boot: state.boot, playPhase: state.playPhase),
      ),
      (previous, next) {
        resumeCompleted();
      },
    );
    ref.listen(cluePhotoProvider, (previous, next) {
      resumeCompleted();
    });

    final showPending =
        state.boot == .ready &&
        !pendingDismissed.value &&
        (state.playPhase == .submitUnknown ||
            state.playPhase == .sessionExpired ||
            state.playPhase == .pendingAuthMismatch);

    return Scaffold(
      backgroundColor: AppColor.surfaceMid,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Gap(14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: ModeSelectHeader(
                            nickname: state.nickname,
                            onHelp: () => helpVisible.value = true,
                            onRanking: onOpenRanking,
                            onSettings: onOpenSettings,
                          ),
                        ),
                        const Gap(8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardConstraints = BoxConstraints(
                            minHeight: math.max(
                              0,
                              (constraints.maxHeight - 8 - 12 - 18) / 2,
                            ),
                          );
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: .stretch,
                              children: [
                                ConstrainedBox(
                                  constraints: cardConstraints,
                                  child: ModeCard(
                                    title: '自由探索',
                                    record: const ModeRecordSummary(
                                      mode: .free,
                                    ),
                                    note: '入場は東ゲート／西ゲートから。入場後は各ゾーンとリング上へテレポートできます。',
                                    danger: true,
                                    onTap: () => vm.startPlay(.free),
                                  ),
                                ),
                                const Gap(12),
                                ConstrainedBox(
                                  constraints: cardConstraints,
                                  child: ModeCard(
                                    title: 'ゴール周辺探索',
                                    record: const ModeRecordSummary(
                                      mode: .near,
                                    ),
                                    note: '撮影地点の近くの、決まった位置から始めます。',
                                    onTap: () => vm.startPlay(.near),
                                  ),
                                ),
                                const Gap(18),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.flow == ModeSelectFlow.preparing)
            Positioned.fill(
              child: PreparingOverlay(
                progress: state.progress,
                onCancel: vm.cancelPrepare,
                preview: _photoPreview(photo),
              ),
            ),
          if (state.flow == ModeSelectFlow.chooseSpot)
            SpotSelectPanel(
              entrances: state.entrances,
              onEntrance: vm.chooseEntrance,
              onClose: vm.closeEntranceChoice,
            ),
          if (helpVisible.value)
            AppDialogBarrier(
              child: Center(
                child: AppDialog(
                  maxWidth: 520,
                  title: '遊び方',
                  onClose: () => helpVisible.value = false,
                  child: const HelpPanel(),
                ),
              ),
            ),
          if (state.boot != .ready)
            Positioned.fill(
              child: ModeSelectBootOverlay(
                failed: state.boot == .failed,
                message: state.notice ?? '通信または認証に失敗しました',
                onRetry: vm.retryBoot,
              ),
            ),
          if (state.notice case final notice?)
            Positioned(
              left: 0,
              bottom: 24,
              right: 0,
              child: Center(child: Text(notice)),
            ),
          if (showPending)
            PendingShotDialog(
              phase: state.playPhase,
              onOpen: () async {
                // 明示的な再照会の完了は、このコールバックが一度だけ開く。
                resumedCompleted.value = true;
                final mode = await vm.resumePending();
                if (!context.mounted || mode == null) return;
                pendingDismissed.value = true;
                onStartPlay(mode, null);
              },
              onDiscard: () {
                vm.discardPending();
              },
              onLater: () => pendingDismissed.value = true,
            ),
        ],
      ),
    );
  }
}

Widget? _photoPreview(CluePhotoState photo) {
  final path = photo.path;
  if (photo.phase != .ready || path == null) return null;
  return CluePhotoView(file: File(path), alt: photo.alt ?? '');
}

ExplorationMode _explorationModeOf(PlayMode? mode) {
  return switch (mode) {
    .near => ExplorationMode.near,
    .free => ExplorationMode.free,
    .unknown || null => throw const PlayFailure(.rejected),
  };
}
