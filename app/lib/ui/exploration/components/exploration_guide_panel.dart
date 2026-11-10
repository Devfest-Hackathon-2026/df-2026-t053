import 'package:app/model/guide/model.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const ExplorationGuidePanel({
  super.key,
  required final GuideState state,
  required final String message,
  required final VoidCallback onPlayback,
  required final VoidCallback? onRegenerate,
  required final VoidCallback onClose,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = state.text;
    return AppDialogBarrier(
      child: Align(
        alignment: .centerRight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 600
                ? constraints.maxWidth
                : (constraints.maxWidth * 0.46).clamp(360.0, 640.0);
            return SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Material(
                color: AppColor.surface,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const Gap(24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                if (text != null) ...[
                                  Text(
                                    text.structures.join('・'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: .w800,
                                    ),
                                  ),
                                  const Gap(16),
                                  Text(
                                    text.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.7,
                                    ),
                                  ),
                                  const Gap(16),
                                  for (final source in text.sources) ...[
                                    Text(
                                      '出典：${source.title}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColor.onSurfaceVariant,
                                      ),
                                    ),
                                    SelectableText(
                                      source.url,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColor.onSurfaceVariant,
                                      ),
                                    ),
                                    const Gap(8),
                                  ],
                                ],
                                if (message.isNotEmpty) ...[
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                  const Gap(16),
                                ],
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    AppButton(
                                      label: state.phase == .playing
                                          ? '音声を停止'
                                          : '音声を再生',
                                      onTap:
                                          state.phase == .ready ||
                                              state.phase == .playing
                                          ? onPlayback
                                          : null,
                                    ),
                                    AppButton(
                                      label: 'ガイドを再生成',
                                      variant: .outlined,
                                      onTap: onRegenerate,
                                    ),
                                  ],
                                ),
                                const Gap(16),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: .centerLeft,
                          child: AppButton(
                            label: '閉じる',
                            variant: .ghost,
                            onTap: onClose,
                          ),
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
