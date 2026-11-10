import 'package:app/ui/mode_select/view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class const ModeRecordSummary({super.key, required final PlayMode mode})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = modeRecordViewModelProvider(mode);
    final state = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    return Wrap(
      crossAxisAlignment: .center,
      spacing: 8,
      children: [
        Text(vm.label),
        TextButton(
          onPressed: state.isLoading ? null : vm.reload,
          child: Text(state.hasError ? '再試行' : '更新'),
        ),
      ],
    );
  }
}
