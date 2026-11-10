import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class SpotSelectPanel extends StatelessWidget {
  const SpotSelectPanel({
    super.key,
    required this.entrances,
    required this.onEntrance,
    required this.onClose,
  });

  final List<SpawnEntrance> entrances;
  final ValueChanged<SpawnEntrance> onEntrance;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 480,
          title: '移動先を選ぶ',
          onClose: onClose,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              for (final (index, entrance) in entrances.indexed) ...[
                if (index > 0) const Gap(10),
                AppButton(
                  label: entrance.label,
                  variant: .tonal,
                  minHeight: 54,
                  onTap: () => onEntrance(entrance),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
