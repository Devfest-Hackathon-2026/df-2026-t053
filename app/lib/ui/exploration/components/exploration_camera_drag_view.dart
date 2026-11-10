import 'package:app/ui/exploration/view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationCameraDragView extends ConsumerWidget {
  const ExplorationCameraDragView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(explorationViewModelProvider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => vm.rotateCamera(details.delta),
      child: child,
    );
  }
}
