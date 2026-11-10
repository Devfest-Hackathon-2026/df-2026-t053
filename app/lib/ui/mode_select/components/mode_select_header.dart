import 'package:app/ui/components/app_icon_button.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// タイトルを左に置き、名前と操作は右にまとめる。
/// 文字拡大時も操作を隠さず、右側だけを使える横幅に合わせて右寄せで折り返す。
class const ModeSelectHeader({
  super.key,
  required final String nickname,
  required final VoidCallback onHelp,
  required final VoidCallback onRanking,
  required final VoidCallback onSettings,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: .start,
    children: [
      // 右側の 1 行目（ボタンの最小の高さ 48）と縦の中央を揃える。
      Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: .centerLeft,
        child: const Text(
          'かさね旅',
          style: TextStyle(fontSize: 18, fontWeight: .w900, height: 1.2),
        ),
      ),
      const Gap(12),
      Expanded(
        child: Wrap(
          alignment: .end,
          crossAxisAlignment: .center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.surfaceMid,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: .min,
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColor.onSurfaceVariant,
                  ),
                  const Gap(4),
                  Flexible(
                    child: Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: .w700,
                        color: AppColor.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // AppIconButton は中央寄せの Container で横幅いっぱいに広がるため、内容幅に留める。
            IntrinsicWidth(
              child: AppIconButton(
                icon: Icons.help_outline,
                label: '遊び方',
                onTap: onHelp,
              ),
            ),
            IntrinsicWidth(
              child: AppIconButton(
                icon: Icons.emoji_events,
                label: 'ランキング',
                onTap: onRanking,
              ),
            ),
            IntrinsicWidth(
              child: AppIconButton(
                icon: Icons.settings,
                label: '設定',
                onTap: onSettings,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
