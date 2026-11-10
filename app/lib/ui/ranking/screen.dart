import 'package:app/model/exploration_mode.dart';
import 'package:app/ui/ranking/components/ranking_content.dart';
import 'package:app/ui/ranking/components/ranking_controls.dart';
import 'package:app/ui/ranking/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const RankingScreen({
  super.key,
  required final VoidCallback onClose,
  final int? revisionId,
  final ExplorationMode initialMode = .free,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = rankingViewModelProvider(
      revisionId: revisionId,
      initialMode: initialMode,
    );
    final state = ref.watch(provider);
    final vm = ref.watch(provider.notifier);
    return Scaffold(
      backgroundColor: AppColor.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                const Gap(14),
                RankingControls(
                  mode: state.mode,
                  isLoading: state.isLoading,
                  onClose: onClose,
                  onModeChanged: vm.switchMode,
                  onReload: vm.reload,
                ),
                const Gap(14),
                RankingContent(
                  state: state,
                  revisionLabel: vm.revisionLabel,
                  myRankLabel: vm.myRankLabel,
                  formatTime: vm.formatTime,
                  onRetry: vm.reload,
                ),
                const Gap(18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
