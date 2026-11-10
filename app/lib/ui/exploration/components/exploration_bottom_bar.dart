import 'package:gap/gap.dart';
import 'package:app/utils/color.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationBottomBar extends StatelessWidget {
  const ExplorationBottomBar({
    super.key,
    required this.showTeleport,
    required this.onTeleport,
    required this.onGuide,
    required this.onShutter,
  });

  final bool showTeleport;
  final VoidCallback onTeleport;
  final VoidCallback onGuide;
  final VoidCallback onShutter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .end,
      children: [
        if (showTeleport) ...[
          _GhostButton(
            label: 'テレポート',
            icon: Icons.place_outlined,
            onTap: onTeleport,
          ),
          const Gap(14),
        ],
        _GhostButton(
          label: 'この辺りを解説',
          icon: Icons.chat_bubble_outline,
          onTap: onGuide,
        ),
        const Gap(14),
        _ShutterButton(onTap: onShutter),
      ],
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColor.surface,
          foregroundColor: AppColor.onSurface,
          side: const BorderSide(color: AppColor.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            Icon(icon, size: 18, color: AppColor.onSurface),
            const Gap(6),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: .w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: AppColor.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59222426),
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: AppColor.expoRed,
        shape: const CircleBorder(),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Icon(
            Icons.photo_camera,
            size: 32,
            color: AppColor.white,
          ),
        ),
      ),
    );
  }
}
