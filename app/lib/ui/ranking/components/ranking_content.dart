import 'package:app/model/ranking/model.dart';
import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/ranking/components/ranking_table.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const RankingContent({
  super.key,
  required final RankingState state,
  required final String revisionLabel,
  required final String myRankLabel,
  required final String Function(DateTime) formatTime,
  required final VoidCallback onRetry,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      Text(revisionLabel),
      const Gap(8),
      const Text('最新の順位（取得時点）', style: TextStyle(fontWeight: .w700)),
      const Gap(4),
      const Text('撮影結果の「撮影時の順位」とは異なる場合があります。'),
      if (state.isLoading) ...[
        const Gap(12),
        const LinearProgressIndicator(),
        const Gap(6),
        const Text('ランキングを取得中…'),
      ],
      if (state.errorMessage case final message?) ...[
        const Gap(12),
        Text(message, style: const TextStyle(color: AppColor.expoRed)),
        const Gap(8),
        Align(
          alignment: .centerLeft,
          child: AppButton(
            label: '再試行',
            onTap: state.isLoading ? null : onRetry,
          ),
        ),
      ],
      if (state.noPublishedChallenge && !state.isLoading) ...[
        const Gap(12),
        const Text('公開中の出題はありません'),
      ],
      if (state.fetchedAt case final fetchedAt?) ...[
        const Gap(12),
        Text('取得時刻：${formatTime(fetchedAt)}（端末の時刻）'),
        if (state.errorMessage != null)
          const Text('更新できなかったため、前回取得した順位を表示しています。'),
        const Gap(14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColor.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const Gap(13),
              const Text('あなたの最新順位・自己ベスト', style: TextStyle(fontWeight: .w700)),
              const Gap(4),
              Text(
                myRankLabel,
                style: const TextStyle(fontSize: 22, fontWeight: .w900),
              ),
              if (state.myEntry case final entry?) ...[
                const Gap(4),
                Text(entry.nickname),
                Text('達成時刻：${formatTime(entry.achieveTime)}'),
              ] else ...[
                const Gap(4),
                const Text('この出題版・モードの自己記録はまだありません'),
              ],
              const Gap(13),
            ],
          ),
        ),
        const Gap(14),
        const Text('上位100件', style: TextStyle(fontWeight: .w700)),
        const Gap(4),
        const Text('101位以下は一覧に表示されません。あなたの順位は別途取得して上に表示します。'),
        const Gap(8),
        RankingTable(entries: state.entries, formatTime: formatTime),
      ],
    ],
  );
}
