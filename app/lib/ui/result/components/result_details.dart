import 'package:app/ui/result/view_model.dart';
import 'package:app/ui/components/app_icon_button.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const ResultScorePanel({
  super.key,
  required final ResultState state,
  final bool compact = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        if (compact)
          Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    '${state.score}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: .w900,
                      height: 1,
                      color: AppColor.primary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '/ ${state.maxScore} 点',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (state.isPersonalBest) ...[
                const Gap(2),
                const Text(
                  '自己ベスト更新',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: .w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ],
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 4,
            crossAxisAlignment: .end,
            children: [
              Text(
                '${state.score}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: .w900,
                  height: 1,
                  color: AppColor.primary,
                ),
              ),
              Text(
                '/ ${state.maxScore} 点',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.onSurfaceVariant,
                ),
              ),
              if (state.isPersonalBest) const AppBestChip(label: '自己ベスト更新'),
            ],
          ),
        Gap(compact ? 2 : 9),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Gap(compact ? 6 : 11),
                _ScoreRow(
                  name: 'お手本との距離',
                  value: '${state.distanceMeters.toStringAsFixed(1)} m',
                ),
                Gap(compact ? 2 : 5),
                _ScoreRow(name: '向きのずれ（左右）', value: '${state.yawDegrees}°'),
                Gap(compact ? 2 : 5),
                _ScoreRow(name: '向きのずれ（上下）', value: '${state.pitchDegrees}°'),
                Gap(compact ? 2 : 5),
                Container(height: 1, color: AppColor.surfaceMid),
                Gap(compact ? 2 : 5),
                _ScoreRow(name: '撮影時の順位', value: '${state.rank} 位'),
                Gap(compact ? 6 : 11),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.name, required this.value});

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
        const Gap(8),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: .w800)),
      ],
    );
  }
}

class const ResultEpisodeSection({super.key, required final ResultState state})
    extends StatelessWidget {
  static const _style = TextStyle(fontSize: 13.5, height: 1.7);

  TextSpan _span(String heading, String body) => TextSpan(
    style: _style,
    children: [
      TextSpan(
        text: heading,
        style: const TextStyle(fontWeight: .w700),
      ),
      TextSpan(text: body),
    ],
  );

  TextSpan get _episode => _span('撮影者のエピソード：', state.episode);
  TextSpan get _highlight => _span('建築の見どころ：', state.highlight);

  /// 文字数ではなく実際の折り返しで、全文が固定領域に入るか判定する。
  double heightFor(BuildContext context, double width) {
    double measure(TextSpan text) {
      final painter = TextPainter(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [text],
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: width);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    return measure(_episode) + 4 + measure(_highlight);
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: .min,
    crossAxisAlignment: .start,
    children: [Text.rich(_episode), const Gap(4), Text.rich(_highlight)],
  );
}
