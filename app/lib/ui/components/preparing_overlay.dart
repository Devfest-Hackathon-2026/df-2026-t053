import 'package:app/ui/components/app_button.dart';
import 'package:gap/gap.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:app/utils/color.dart';
import 'package:material_ui/material_ui.dart';

String preparingLabelFor(double progress) {
  if (progress >= 0.99) {
    return '画面を描画しています…';
  }
  if (progress >= 0.3) {
    return '素材を取得しています…';
  }
  return '開始を受け付けています…';
}

class PreparingOverlay extends StatelessWidget {
  const PreparingOverlay({
    super.key,
    required this.progress,
    this.onCancel,
    this.preview,
    this.maxWidth = 440,
  });

  final double progress;
  final VoidCallback? onCancel;
  final Widget? preview;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: maxWidth,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              if (preview != null) ...[
                SizedBox(height: 120, child: preview),
                const Gap(16),
              ],
              Row(
                mainAxisSize: .min,
                children: [
                  const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColor.primary,
                      backgroundColor: AppColor.primaryContainer,
                    ),
                  ),
                  const Gap(13),
                  Expanded(
                    child: Text(
                      preparingLabelFor(progress),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: .w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress <= 0 ? null : progress,
                  minHeight: 10,
                  backgroundColor: AppColor.surfaceMid,
                  color: AppColor.primary,
                ),
              ),
              const Gap(16),
              if (onCancel != null)
                Align(
                  alignment: .centerLeft,
                  child: AppButton(
                    label: 'キャンセル',
                    variant: .outlined,
                    onTap: onCancel,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
