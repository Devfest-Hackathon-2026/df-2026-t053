import 'package:app/model/play/model.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/components/app_dialog.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// 起動時に見つかった保留中の撮影への対応を案内する。
/// 破棄は明示操作のときだけ行い、結果不明の撮影は探索を開いて確認する。
class PendingShotDialog extends StatelessWidget {
  const PendingShotDialog({
    super.key,
    required this.phase,
    required this.onOpen,
    required this.onDiscard,
    required this.onLater,
  });

  final PlayPhase phase;
  final VoidCallback onOpen;
  final VoidCallback onDiscard;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final content = switch (phase) {
      .submitUnknown => (
        title: '前回の撮影結果が未確認です',
        body:
            '前回の撮影は、保存されたかどうか確認できていません。'
            '探索を開いて、結果の確認か再送をしてください。',
        primaryLabel: '探索を開く',
        primary: onOpen,
        secondaryLabel: '後で',
        secondary: onLater,
      ),
      .sessionExpired => (
        title: '前回の撮影は期限切れです',
        body:
            '前回の撮影は有効期限が切れており、新しく撮影できません。'
            '記録を破棄して、新しく始めてください。',
        primaryLabel: '記録を破棄する',
        primary: onDiscard,
        secondaryLabel: null,
        secondary: null,
      ),
      _ => (
        title: '前回の撮影記録を引き継げません',
        body:
            '認証情報を失ったため、前回の撮影結果を確認できません。'
            '記録を破棄して、新しく始めてください。',
        primaryLabel: '記録を破棄する',
        primary: onDiscard,
        secondaryLabel: null,
        secondary: null,
      ),
    };
    return AppDialogBarrier(
      child: Center(
        child: AppDialog(
          maxWidth: 420,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: .w800,
                  height: 1.2,
                ),
              ),
              const Gap(9),
              Text(
                content.body,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
              const Gap(13),
              Row(
                mainAxisAlignment: .end,
                children: [
                  if ((content.secondaryLabel, content.secondary) case (
                    final label?,
                    final secondary?,
                  )) ...[
                    AppButton(
                      label: label,
                      onTap: secondary,
                      variant: .outlined,
                    ),
                    const Gap(9),
                  ],
                  AppButton(
                    label: content.primaryLabel,
                    onTap: content.primary,
                    variant: phase == .submitUnknown ? .filled : .danger,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
