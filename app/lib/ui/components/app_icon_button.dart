import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onTap,
    this.icon,
    this.label,
    this.iconOnly = false,
  });

  final VoidCallback? onTap;
  final IconData? icon;
  final String? label;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final content = iconOnly
        ? Icon(icon, size: 22, color: AppColor.onSurface)
        : Row(
            mainAxisSize: .min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColor.onSurface),
                const Gap(6),
              ],
              Text(
                label ?? '',
                style: const TextStyle(fontSize: 13, fontWeight: .w700),
              ),
            ],
          );
    return Material(
      color: AppColor.surface,
      shape: const StadiumBorder(),
      clipBehavior: .antiAlias,
      elevation: 1,
      shadowColor: const Color(0x2E222426),
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minWidth: iconOnly ? 48 : 0,
            minHeight: 48,
          ),
          padding: EdgeInsets.symmetric(horizontal: iconOnly ? 0 : 16),
          alignment: .center,
          child: content,
        ),
      ),
    );
  }
}

class AppDarkChip extends StatelessWidget {
  const AppDarkChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: .center,
      decoration: BoxDecoration(
        color: AppColor.expoDarkGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: .w700,
          color: AppColor.white,
        ),
      ),
    );
  }
}

class AppTonalChip extends StatelessWidget {
  const AppTonalChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(minHeight: 28),
      alignment: .center,
      decoration: BoxDecoration(
        color: AppColor.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: .w700,
          color: AppColor.onPrimaryContainer,
        ),
      ),
    );
  }
}

class AppBestChip extends StatelessWidget {
  const AppBestChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(minHeight: 28),
      alignment: .center,
      decoration: BoxDecoration(
        color: AppColor.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: .w700,
          color: AppColor.onSecondaryContainer,
        ),
      ),
    );
  }
}

class AppNoteText extends StatelessWidget {
  const AppNoteText({super.key, required this.text, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 12,
        height: 1.6,
        color: AppColor.onSurfaceVariant,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColor.surfaceHigh, width: 1.5),
      ),
      child: child,
    );
  }
}
