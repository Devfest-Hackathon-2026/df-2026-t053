import 'package:app/ui/components/app_button.dart';
import 'package:app/ui/settings/view_model.dart';
import 'package:app/utils/color.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const NicknameSection({
  super.key,
  required final SettingsState state,
  required final bool canSave,
  required final int nicknameLength,
  required final ValueChanged<String> onChanged,
  required final VoidCallback onSave,
  required final VoidCallback onReload,
}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: state.nickname);
    useEffect(() {
      if (controller.text != state.nickname) {
        controller.value = TextEditingValue(
          text: state.nickname,
          selection: TextSelection.collapsed(offset: state.nickname.length),
        );
      }
      return null;
    }, [state.nickname]);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        const Text(
          'ニックネーム（ランキングに公開されます）',
          style: TextStyle(
            fontSize: 11,
            fontWeight: .w700,
            letterSpacing: .08,
            color: AppColor.onSurfaceVariant,
          ),
        ),
        const Gap(9),
        if (state.isLoading) ...[
          Semantics(liveRegion: true, child: const Text('プロフィールを読み込んでいます')),
          const Gap(9),
        ],
        if (state.errorMessage case final String message) ...[
          Semantics(liveRegion: true, child: Text(message)),
          const Gap(9),
          if (state.profile == null && !state.isLoading) ...[
            AppButton(label: '再読み込み', onTap: onReload),
            const Gap(9),
          ],
        ],
        TextField(
          controller: controller,
          enabled: state.profile != null && !state.isLoading && !state.isSaving,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'ニックネーム',
            counterText: '$nicknameLength/20',
            errorText: state.nicknameError,
            errorMaxLines: 3,
            filled: true,
            fillColor: AppColor.surfaceLow,
            isCollapsed: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.outline, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primary, width: 1.5),
            ),
          ),
        ),
        const Gap(9),
        Align(
          alignment: .centerLeft,
          child: AppButton(
            label: state.isSaving ? '保存中…' : '保存',
            onTap: canSave ? onSave : null,
          ),
        ),
        if (state.saved) ...[
          const Gap(9),
          Semantics(liveRegion: true, child: const Text('保存しました')),
        ],
        const Gap(9),
        const Text(
          '匿名アカウントのため、アプリを削除すると記録を引き継げません。',
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            color: AppColor.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
