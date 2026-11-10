import 'package:app/ui/exploration/view_model.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ExplorationJoyStick extends HookConsumerWidget {
  const ExplorationJoyStick({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const size = 100.0;
    const knobSize = 50.0;
    const maxDistance = (size - knobSize) / 2;

    final knobOffset = useState(Offset.zero);
    final vm = ref.watch(explorationViewModelProvider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => knobOffset.value = vm.updateJoystickPan(
        details.localPosition,
        size: size,
        maxDistance: maxDistance,
      ),
      onPanUpdate: (details) => knobOffset.value = vm.updateJoystickPan(
        details.localPosition,
        size: size,
        maxDistance: maxDistance,
      ),
      onPanEnd: (_) {
        knobOffset.value = Offset.zero;
        vm.resetJoystickPan();
      },
      onPanCancel: () {
        knobOffset.value = Offset.zero;
        vm.resetJoystickPan();
      },
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Positioned(
                left: (size - knobSize) / 2 + knobOffset.value.dx,
                top: (size - knobSize) / 2 + knobOffset.value.dy,
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
