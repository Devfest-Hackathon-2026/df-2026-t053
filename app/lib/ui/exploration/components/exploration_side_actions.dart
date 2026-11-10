import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationSideActions extends StatelessWidget {
  const ExplorationSideActions({
    super.key,
    required this.onPhoto,
    required this.showFrame,
    required this.onToggleFrame,
  });

  final VoidCallback onPhoto;
  final bool showFrame;
  final VoidCallback onToggleFrame;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        _SideButton(
          icon: Icons.image_outlined,
          label: '写真',
          onTap: onPhoto,
        ),
        const Gap(10),
        _SideButton(
          icon: showFrame ? Icons.crop_free : Icons.crop_din,
          label: showFrame ? '枠ON' : '枠OFF',
          onTap: onToggleFrame,
        ),
      ],
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Material(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: .antiAlias,
        elevation: 1,
        shadowColor: const Color(0x2E222426),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Icon(icon, size: 22, color: AppColor.onSurface),
              const Gap(2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: .w700,
                  color: AppColor.onSurface,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
