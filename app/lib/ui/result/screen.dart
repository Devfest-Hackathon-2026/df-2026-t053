import 'package:app/model/exploration_mode.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/provider/photo/provider.dart';
import 'package:app/ui/result/components/result_actions.dart';
import 'package:app/ui/result/components/result_details.dart';
import 'package:app/ui/result/components/result_comparison.dart';
import 'package:app/ui/result/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.mode,
    required this.result,
    required this.onRetry,
    required this.onModeSelect,
    required this.onRanking,
    required this.onClose,
  });

  final ExplorationMode mode;
  final SubmitShotResponse result;
  final VoidCallback onRetry;
  final VoidCallback onModeSelect;
  final VoidCallback onRanking;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surface,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(resultViewModelProvider(mode, result));
            final photo = ref.watch(cluePhotoProvider);
            final wide =
                MediaQuery.sizeOf(context).width >
                MediaQuery.sizeOf(context).height;

            return wide
                ? _WideResultBody(
                    state: state,
                    photo: photo,
                    result: result,
                    onRetry: onRetry,
                    onModeSelect: onModeSelect,
                    onRanking: onRanking,
                  )
                : _PortraitResultBody(
                    state: state,
                    photo: photo,
                    result: result,
                    onRetry: onRetry,
                    onModeSelect: onModeSelect,
                    onRanking: onRanking,
                  );
          },
        ),
      ),
    );
  }
}

class _PortraitResultBody extends StatelessWidget {
  const _PortraitResultBody({
    required this.state,
    required this.photo,
    required this.result,
    required this.onRetry,
    required this.onModeSelect,
    required this.onRanking,
  });

  final ResultState state;
  final CluePhotoState photo;
  final SubmitShotResponse result;
  final VoidCallback onRetry;
  final VoidCallback onModeSelect;
  final VoidCallback onRanking;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const Gap(16),
            ResultComparison(photo: photo, result: result),
            const Gap(14),
            ResultScorePanel(state: state),
            const Gap(14),
            ResultEpisodeSection(state: state),
            const Gap(16),
            ResultActions(
              onRetry: onRetry,
              onModeSelect: onModeSelect,
              onRanking: onRanking,
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _WideResultBody extends StatelessWidget {
  const _WideResultBody({
    required this.state,
    required this.photo,
    required this.result,
    required this.onRetry,
    required this.onModeSelect,
    required this.onRanking,
  });

  final ResultState state;
  final CluePhotoState photo;
  final SubmitShotResponse result;
  final VoidCallback onRetry;
  final VoidCallback onModeSelect;
  final VoidCallback onRanking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(14) > 14;
          const detailsHeight = 144.0;
          final episode = ResultEpisodeSection(state: state);
          final needsScroll =
              largeText ||
              episode.heightFor(context, constraints.maxWidth - 252) >
                  detailsHeight ||
              constraints.maxHeight < 320;
          final details = Row(
            crossAxisAlignment: .start,
            children: [
              SizedBox(
                width: 238,
                child: ResultScorePanel(state: state, compact: !largeText),
              ),
              const Gap(14),
              Expanded(child: episode),
            ],
          );
          final actions = ResultActions(
            onRetry: onRetry,
            onModeSelect: onModeSelect,
            onRanking: onRanking,
          );
          if (needsScroll) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  const Gap(8),
                  ResultComparison(photo: photo, result: result),
                  const Gap(8),
                  details,
                  const Gap(8),
                  actions,
                  const Gap(8),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: .stretch,
            children: [
              const Gap(8),
              SizedBox(
                // 詳細144・操作48・上下と段間32を先に確保する。
                height: constraints.maxHeight - detailsHeight - 48 - 32,
                child: ResultComparison(photo: photo, result: result),
              ),
              const Gap(8),
              Expanded(child: details),
              const Gap(8),
              actions,
              const Gap(8),
            ],
          );
        },
      ),
    );
  }
}
