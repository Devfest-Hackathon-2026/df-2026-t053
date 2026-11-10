import 'package:app/ui/components/app_back_button.dart';
import 'package:app/ui/components/app_icon_button.dart';
import 'package:app/ui/exploration/components/exploration_mini_map.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationTopBar extends StatelessWidget {
  const ExplorationTopBar({
    super.key,
    required this.modeLabel,
    required this.onBack,
    required this.onHelp,
    required this.onMap,
  });

  final String modeLabel;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          const Gap(12),
          Row(
            crossAxisAlignment: .start,
            children: [
              AppBackButton(onTap: onBack),
              const Gap(10),
              AppDarkChip(label: modeLabel),
              const Spacer(),
              AppIconButton(
                icon: Icons.help_outline,
                label: '操作方法',
                onTap: onHelp,
              ),
              const Gap(10),
              ExplorationMiniMap(onTap: onMap),
            ],
          ),
        ],
      ),
    );
  }
}
