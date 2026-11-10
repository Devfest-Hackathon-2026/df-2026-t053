import 'package:app/ui/components/app_button.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// 起動時の認証・出題取得の読み込みと失敗を表示する。
class ModeSelectBootOverlay extends StatelessWidget {
  const ModeSelectBootOverlay({
    super.key,
    required this.failed,
    required this.message,
    required this.onRetry,
  });

  final bool failed;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.surfaceMid,
      child: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: .min,
                children: [
                  if (!failed) ...[
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: AppColor.primary,
                      ),
                    ),
                    const Gap(16),
                    const Text(
                      '準備しています…',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: .w800,
                        height: 1.2,
                      ),
                    ),
                  ] else ...[
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: .w800,
                        height: 1.2,
                      ),
                    ),
                    const Gap(9),
                    const Text(
                      '接続を確認して、最初から読み直してください。',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    const Gap(16),
                    AppButton(label: '最初から読み直す', onTap: onRetry),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
