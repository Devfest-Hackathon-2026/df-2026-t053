import 'package:app/ui/components/app_icon_button.dart';
import 'package:material_ui/material_ui.dart';

/// 戻るボタン（矢印のみ・丸背景）。全画面でこの形に統一する。
class const AppBackButton({
  super.key,
  required final VoidCallback? onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    label: '戻る',
    button: true,
    child: AppIconButton(iconOnly: true, icon: Icons.arrow_back, onTap: onTap),
  );
}
