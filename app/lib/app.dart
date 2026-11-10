import 'package:app/router/router.dart';
import 'package:app/utils/color.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const ColorScheme _appColorScheme = ColorScheme(
  brightness: .light,
  primary: AppColor.primary,
  onPrimary: AppColor.onPrimary,
  primaryContainer: AppColor.primaryContainer,
  onPrimaryContainer: AppColor.onPrimaryContainer,
  secondary: AppColor.secondary,
  onSecondary: AppColor.onSecondary,
  secondaryContainer: AppColor.secondaryContainer,
  onSecondaryContainer: AppColor.onSecondaryContainer,
  error: AppColor.expoRed,
  onError: AppColor.onSecondary,
  surface: AppColor.surface,
  onSurface: AppColor.onSurface,
);

class GdgHackApp extends StatelessWidget {
  const GdgHackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'かさね旅',
        theme: ThemeData(colorScheme: _appColorScheme),
        routerConfig: router,
      ),
    );
  }
}
