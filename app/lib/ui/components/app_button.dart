import 'package:gap/gap.dart';
import 'package:app/utils/color.dart';
import 'package:material_ui/material_ui.dart';

enum AppButtonVariant { filled, danger, tonal, outlined, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = .filled,
    this.minHeight = 48,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final double minHeight;
  final IconData? icon;

  ButtonStyle get _style {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
    return switch (variant) {
      .filled => FilledButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.onPrimary,
        minimumSize: Size(0, minHeight),
        shape: shape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: .w700),
      ),
      .danger => FilledButton.styleFrom(
        backgroundColor: AppColor.expoRed,
        foregroundColor: AppColor.onSecondary,
        minimumSize: Size(0, minHeight),
        shape: shape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: .w700),
      ),
      .tonal => FilledButton.styleFrom(
        backgroundColor: AppColor.primaryContainer,
        foregroundColor: AppColor.onPrimaryContainer,
        minimumSize: Size(0, minHeight),
        shape: shape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: .w700),
      ),
      .outlined => OutlinedButton.styleFrom(
        foregroundColor: AppColor.primary,
        minimumSize: Size(0, minHeight),
        side: const BorderSide(color: AppColor.primary, width: 1.5),
        shape: shape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: .w700),
      ),
      .ghost => OutlinedButton.styleFrom(
        backgroundColor: AppColor.surface,
        foregroundColor: AppColor.onSurface,
        minimumSize: Size(0, minHeight),
        side: const BorderSide(color: AppColor.outline, width: 1.5),
        shape: shape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: .w700),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: .min,
            children: [
              Icon(icon, size: 18),
              const Gap(6),
              Text(label),
            ],
          );
    return switch (variant) {
      .filled || .danger || .tonal => FilledButton(
        onPressed: onTap,
        style: _style,
        child: child,
      ),
      .outlined || .ghost => OutlinedButton(
        onPressed: onTap,
        style: _style,
        child: child,
      ),
    };
  }
}
