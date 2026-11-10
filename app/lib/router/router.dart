import 'package:app/model/exploration_mode.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/ui/exploration/screen.dart';
import 'package:app/ui/mode_select/screen.dart';
import 'package:app/ui/ranking/screen.dart';
import 'package:app/ui/settings/screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _ModeSelectPage()),
    GoRoute(
      path: '/exploration',
      builder: (context, state) {
        final extra = state.extra;
        final mode = extra is Map<String, dynamic>
            ? extra['mode'] as ExplorationMode?
            : null;
        final spot = extra is Map<String, dynamic>
            ? extra['spot'] as String?
            : null;
        return ExplorationScreen(
          mode: mode ?? ExplorationMode.free,
          spot: spot,
        );
      },
    ),
    GoRoute(
      path: '/ranking',
      builder: (context, state) => RankingScreen(onClose: () => context.pop()),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => SettingsScreen(
          credits: ref.watch(challengeProvider).revision?.credits ?? const [],
          onClose: () => context.pop(),
        ),
      ),
    ),
  ],
);

class _ModeSelectPage extends StatelessWidget {
  const _ModeSelectPage();

  @override
  Widget build(BuildContext context) {
    return ModeSelectScreen(
      onStartPlay: (mode, spot) =>
          context.push('/exploration', extra: {'mode': mode, 'spot': spot}),
      onOpenRanking: () => context.push('/ranking'),
      onOpenSettings: () => context.push('/settings'),
    );
  }
}
