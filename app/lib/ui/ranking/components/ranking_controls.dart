import 'package:app/model/exploration_mode.dart';
import 'package:app/ui/components/app_back_button.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const RankingControls({
  super.key,
  required final ExplorationMode mode,
  required final bool isLoading,
  required final VoidCallback onClose,
  required final ValueChanged<ExplorationMode> onModeChanged,
  required final VoidCallback onReload,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Row(
        children: [
          AppBackButton(onTap: onClose),
          const Spacer(),
          AppButton(
            label: '更新',
            variant: .outlined,
            onTap: isLoading ? null : onReload,
          ),
        ],
      ),
      const Gap(10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('自由探索'),
            selected: mode == .free,
            showCheckmark: false,
            onSelected: (_) => onModeChanged(.free),
          ),
          ChoiceChip(
            label: const Text('ゴール周辺探索'),
            selected: mode == .near,
            showCheckmark: false,
            onSelected: (_) => onModeChanged(.near),
          ),
        ],
      ),
    ],
  );
}
