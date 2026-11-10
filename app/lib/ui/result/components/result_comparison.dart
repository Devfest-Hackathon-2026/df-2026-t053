import 'dart:io';
import 'dart:math' as math;

import 'package:app/model/photo/model.dart';
import 'package:app/ui/components/clue_photo_view.dart';
import 'package:app/ui/result/view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class const ResultComparison({
  super.key,
  required final CluePhotoState photo,
  required final SubmitShotResponse result,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = photo.width;
    final height = photo.height;
    final path = photo.path;
    if (photo.phase != .ready ||
        path == null ||
        width == null ||
        height == null ||
        width <= 0 ||
        height <= 0) {
      return const Text('比較用の写真を準備できませんでした。点数と解説は確認できます。');
    }
    final state = ref.watch(
      resultComparisonViewModelProvider(result, width, height),
    );
    Widget rendered(bool shot) => state.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: (images) =>
          RawImage(image: shot ? images.shot : images.goal, fit: .contain),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Text(
          '3Dを表示できませんでした',
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: .center,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelHeight =
            MediaQuery.textScalerOf(context).scale(12) * 2.8 + 4;
        final availableWidth = constraints.hasBoundedHeight
            ? math.min(
                constraints.maxWidth,
                math.max(1.0, constraints.maxHeight - labelHeight) *
                        width /
                        height *
                        3 +
                    16,
              )
            : constraints.maxWidth;
        return Align(
          alignment: .topCenter,
          child: SizedBox(
            width: availableWidth,
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: _ComparisonImage(
                    label: '自分の撮影（3D）',
                    ratio: width / height,
                    child: rendered(true),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _ComparisonImage(
                    label: 'お手本（3D）',
                    ratio: width / height,
                    child: rendered(false),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _ComparisonImage(
                    label: '実写写真',
                    ratio: width / height,
                    child: CluePhotoView(
                      file: File(path),
                      alt: photo.alt ?? '実写写真',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class const _ComparisonImage({
  required final String label,
  required final double ratio,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .stretch,
    children: [
      SizedBox(
        height: MediaQuery.textScalerOf(context).scale(12) * 2.8,
        child: Center(
          child: Text(
            label,
            textAlign: .center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: .w700,
            ),
          ),
        ),
      ),
      const Gap(4),
      AspectRatio(
        aspectRatio: ratio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(color: Colors.black, child: child),
        ),
      ),
    ],
  );
}
