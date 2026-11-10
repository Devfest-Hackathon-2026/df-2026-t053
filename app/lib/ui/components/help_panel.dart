import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class HelpPanel extends StatelessWidget {
  const HelpPanel({super.key});

  static const _entries = <(String, String)>[
    ('歩く：', '左下のパッドを倒す'),
    ('見回す：', '画面をドラッグする'),
    ('写真と地図：', '右側のボタンで開く。開いている間は歩行が止まる'),
    ('撮影：', '赤いシャッターで1回だけ。位置と向きの近さが点数になる'),
    ('通信：', '撮影の確定・順位・新しいガイドには通信が必要'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        for (final (index, entry) in _entries.indexed) ...[
          if (index > 0) const Gap(10),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14, height: 1.6),
              children: [
                TextSpan(
                  text: entry.$1,
                  style: const TextStyle(fontWeight: .w700),
                ),
                TextSpan(text: entry.$2),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
