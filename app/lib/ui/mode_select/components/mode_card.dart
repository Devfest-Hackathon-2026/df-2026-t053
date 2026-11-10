import 'package:app/ui/components/app_button.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.title,
    required this.note,
    required this.onTap,
    this.danger = false,
    this.record,
  });

  final String title;
  final String note;
  final VoidCallback onTap;
  final bool danger;
  final Widget? record;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.surfaceHigh, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: .w900,
                        height: 1.2,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: AppColor.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              AppButton(
                label: '開始',
                variant: danger ? .danger : .outlined,
                onTap: onTap,
              ),
            ],
          ),
          if (record case final summary?) ...[
            const Gap(8),
            Align(alignment: .centerLeft, child: summary),
          ],
          const Gap(16),
        ],
      ),
    );
  }
}
