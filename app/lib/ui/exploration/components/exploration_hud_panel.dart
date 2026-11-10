import 'package:app/ui/exploration/view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationHudPanel extends HookConsumerWidget {
  const ExplorationHudPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorationViewModelProvider);
    final position = state.playerPosition;
    final positionLabel = position == null
        ? '位置: --'
        : '位置: ${position.x.toStringAsFixed(0)}, ${position.y.toStringAsFixed(0)}';
    final loadLabel = state.isLoading
        ? '読み込み中…'
        : state.importSeconds == null
        ? 'インポート時間: 計測なし'
        : 'インポート時間: ${state.importSeconds!.toStringAsFixed(1)} 秒';

    return Align(
      alignment: .topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: .circular(12),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            const Gap(12),
            Text(state.asset.title),
            const Gap(4),
            Text('容量: ${state.asset.sizeLabel}'),
            Text(loadLabel),
            Text(positionLabel),
            Text('FPS: ${state.fps.toStringAsFixed(0)}'),
            Text('フレーム時間: ${state.frameMs.toStringAsFixed(1)} ms'),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
