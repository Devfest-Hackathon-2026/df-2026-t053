import 'package:app/ui/exploration/view_model.dart';
import 'package:app/ui/result/screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// 結果の表示と操作通知。プレイごとの表示状態は探索ViewModelが所有する。
class const ExplorationResultOverlay({
  super.key,
  required final VoidCallback onModeSelect,
  required final VoidCallback onRanking,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationViewModelProvider);
    final result = state.result;
    if (!state.showResult || result == null) return const SizedBox.shrink();
    final vm = ref.read(explorationViewModelProvider.notifier);
    return ResultScreen(
      mode: state.mode,
      result: result,
      onRetry: vm.retryPlay,
      onModeSelect: () {
        vm.endPlay();
        onModeSelect();
      },
      onRanking: onRanking,
      onClose: vm.dismissResult,
    );
  }
}
