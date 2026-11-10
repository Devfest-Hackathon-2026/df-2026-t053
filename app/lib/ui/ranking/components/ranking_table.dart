import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class const RankingTable({
  super.key,
  required final List<RankingEntry> entries,
  required final String Function(DateTime) formatTime,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const Text('この出題版・モードのランキングはまだありません');
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.surfaceHigh, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0) Container(height: 1, color: AppColor.surfaceMid),
            _RankingRow(
              entry: entry,
              achievedAt: formatTime(entry.achieveTime),
            ),
          ],
        ],
      ),
    );
  }
}

class const _RankingRow({
  required final RankingEntry entry,
  required final String achievedAt,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: entry.mine ? AppColor.primaryContainer : AppColor.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          const Gap(10),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                '${entry.rank} 位',
                style: const TextStyle(fontWeight: .w800),
              ),
              Text('${entry.score} 点'),
            ],
          ),
          const Gap(4),
          Text(
            entry.mine ? '${entry.nickname}（あなた）' : entry.nickname,
            style: TextStyle(fontWeight: entry.mine ? .w800 : .w400),
          ),
          const Gap(4),
          Text(
            '達成時刻：$achievedAt',
            style: const TextStyle(color: AppColor.onSurfaceVariant),
          ),
          const Gap(10),
        ],
      ),
    ),
  );
}
