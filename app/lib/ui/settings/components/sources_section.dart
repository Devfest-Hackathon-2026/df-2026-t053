import 'package:app/ui/components/app_icon_button.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

const _kUsageNotes = <String>[
  '写真を手がかりに3D空間を探索し、同じ撮影視点を探すアプリです。端末のGPSは取得しません。',
  'ニックネームはランキングに公開されます。匿名アカウントの記録は、再インストールや別端末へ引き継げません。',
  '順位と自己ベストは出題版・モード別です。撮影時の順位と、後から取得する最新順位は異なる場合があります。',
];

class const SourcesSection({
  super.key,
  required final List<Credit> credits,
  required final String? Function(Credit) sourceUrl,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: .min,
    crossAxisAlignment: .stretch,
    children: [
      const Text(
        '出典・利用案内',
        style: TextStyle(
          fontSize: 11,
          fontWeight: .w700,
          letterSpacing: .08,
          color: AppColor.onSurfaceVariant,
        ),
      ),
      const Gap(9),
      AppCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              const Gap(12),
              if (credits.isEmpty)
                const Text('この画面で確認できる出典情報はありません。素材のクレジットと利用条件は確認中です。')
              else ...[
                for (final credit in credits) ...[
                  SelectableText(
                    credit.name,
                    style: const TextStyle(fontSize: 13.5, height: 1.6),
                  ),
                  if (sourceUrl(credit) case final url?)
                    SelectableText(
                      url,
                      style: const TextStyle(fontSize: 13.5, height: 1.6),
                    ),
                  const Gap(8),
                ],
                const Text('出典URLは長押しでコピーできます。素材の利用条件は各提供元でご確認ください。'),
              ],
              const Gap(16),
              const Text('利用案内', style: TextStyle(fontWeight: .w700)),
              for (final note in _kUsageNotes) ...[
                const Gap(8),
                Text(note, style: const TextStyle(fontSize: 13.5, height: 1.6)),
              ],
              const Gap(12),
            ],
          ),
        ),
      ),
    ],
  );
}
