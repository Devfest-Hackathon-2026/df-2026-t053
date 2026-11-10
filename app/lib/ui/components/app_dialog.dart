import 'package:gap/gap.dart';
import 'package:app/utils/color.dart';
import 'package:material_ui/material_ui.dart';

class AppDialogBarrier extends StatelessWidget {
  const AppDialogBarrier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: const Color(0x8C222426),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: child,
        ),
      ),
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.maxWidth = 860,
  });

  final String? title;
  final VoidCallback? onClose;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final hasHead = title != null || onClose != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Material(
          color: AppColor.surface,
          shape: RoundedRectangleBorder(borderRadius: .circular(28)),
          clipBehavior: .antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  const Gap(18),
                  if (hasHead) ...[
                    _AppDialogHead(title: title, onClose: onClose),
                    const Gap(12),
                  ],
                  Flexible(child: SingleChildScrollView(child: child)),
                  const Gap(18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDialogHead extends StatelessWidget {
  const _AppDialogHead({required this.title, required this.onClose});

  final String? title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title ?? '',
            maxLines: 1,
            overflow: .ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: .w800,
              height: 1.2,
            ),
          ),
        ),
        if (onClose != null) ...[
          const Gap(10),
          _AppDialogCloseButton(onTap: onClose!),
        ],
      ],
    );
  }
}

class _AppDialogCloseButton extends StatelessWidget {
  const _AppDialogCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: AppColor.surfaceMid,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          child: const Icon(Icons.close, size: 20, color: AppColor.onSurface),
        ),
      ),
    );
  }
}
