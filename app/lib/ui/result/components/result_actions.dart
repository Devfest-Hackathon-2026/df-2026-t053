import 'package:app/ui/components/app_button.dart';
import 'package:material_ui/material_ui.dart';

class const ResultActions({
  super.key,
  required final VoidCallback onRetry,
  required final VoidCallback onModeSelect,
  required final VoidCallback onRanking,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      spacing: 9,
      alignment: .end,
      overflowAlignment: .end,
      children: [
        AppButton(
          label: 'ランキング',
          icon: Icons.emoji_events,
          variant: .tonal,
          onTap: onRanking,
        ),
        AppButton(label: 'モード選択', variant: .outlined, onTap: onModeSelect),
        AppButton(label: 'もう一度挑戦', variant: .danger, onTap: onRetry),
      ],
    );
  }
}
