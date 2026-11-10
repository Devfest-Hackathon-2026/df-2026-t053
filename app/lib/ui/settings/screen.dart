import 'package:app/ui/components/app_back_button.dart';
import 'package:app/ui/settings/components/nickname_section.dart';
import 'package:app/ui/settings/components/sources_section.dart';
import 'package:app/ui/settings/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

class const SettingsScreen({
  super.key,
  required final VoidCallback onClose,
  final List<Credit> credits = const [],
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColor.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  const Gap(14),
                  Row(
                    children: [
                      AppBackButton(onTap: onClose),
                      const Gap(10),
                      const Expanded(
                        child: Text(
                          '設定',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: .w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide =
                      MediaQuery.sizeOf(context).width >
                      MediaQuery.sizeOf(context).height;

                  final nicknameSection = NicknameSection(
                    state: state,
                    canSave: vm.canSave,
                    nicknameLength: vm.nicknameLength,
                    onChanged: vm.updateNickname,
                    onSave: vm.save,
                    onReload: vm.reload,
                  );
                  final sourcesSection = SourcesSection(
                    credits: credits,
                    sourceUrl: vm.sourceUrl,
                  );

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          const Gap(8),
                          if (wide)
                            Row(
                              crossAxisAlignment: .start,
                              children: [
                                Expanded(child: nicknameSection),
                                const Gap(16),
                                Expanded(child: sourcesSection),
                              ],
                            )
                          else ...[
                            nicknameSection,
                            const Gap(16),
                            sourcesSection,
                          ],
                          const Gap(18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
