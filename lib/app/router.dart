import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/preferences/app_preferences.dart';
import '../../presentation/main_scaffold.dart';
import '../../presentation/onboarding/welcome_screen.dart';
import '../../presentation/onboarding/goal_selection_screen.dart';
import '../../presentation/onboarding/app_selection_screen.dart';
import '../../presentation/onboarding/message_builder_screen.dart';
import '../../presentation/onboarding/countdown_setup_screen.dart';
import '../../presentation/onboarding/permission_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/apps/apps_screen.dart';
import '../../presentation/journal/journal_screen.dart';
import '../../presentation/journal/journal_form_screen.dart';
import '../../presentation/insights/insights_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/messages/messages_screen.dart';
import '../../presentation/messages/message_editor_screen.dart';
import '../../presentation/commitment/commitment_screen.dart';
import '../../presentation/focus/focus_screen.dart';
import '../../presentation/goals/goals_screen.dart';
import '../../presentation/achievements/achievements_screen.dart';
import '../../presentation/interstitial/interstitial_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = AppPreferences();
      final onboardingDone = await prefs.onboardingCompleted;
      final isOnboarding = state.uri.path.startsWith('/onboarding');
      final isInterstitial = state.uri.path == '/interstitial';

      if (isInterstitial) return null;
      if (!onboardingDone && !isOnboarding) return '/onboarding';
      if (onboardingDone && state.uri.path == '/onboarding') return '/';
      return null;
    },
    routes: [
      // Interstitial — standalone, no shell
      GoRoute(
        path: '/interstitial',
        builder: (_, __) => const InterstitialScreen(),
      ),

      // Onboarding flow
      GoRoute(path: '/onboarding', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/onboarding/goals', builder: (_, __) => const GoalSelectionScreen()),
      GoRoute(path: '/onboarding/apps', builder: (_, __) => const AppSelectionScreen()),
      GoRoute(path: '/onboarding/messages', builder: (_, __) => const MessageBuilderScreen()),
      GoRoute(path: '/onboarding/countdown', builder: (_, __) => const CountdownSetupScreen()),
      GoRoute(path: '/onboarding/permissions', builder: (_, __) => const PermissionScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/apps', builder: (_, __) => const AppsScreen()),
          GoRoute(path: '/journal', builder: (_, __) => const JournalScreen()),
          GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),

      // Modal / pushed routes (outside shell)
      GoRoute(path: '/commitment', builder: (_, __) => const CommitmentScreen()),
      GoRoute(path: '/focus', builder: (_, __) => const FocusScreen()),
      GoRoute(path: '/goals', builder: (_, __) => const GoalsScreen()),
      GoRoute(path: '/achievements', builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
      GoRoute(
        path: '/messages/edit',
        builder: (_, state) {
          final id = state.uri.queryParameters['id'];
          return MessageEditorScreen(messageId: id);
        },
      ),
      GoRoute(
        path: '/journal/new',
        builder: (_, __) => const JournalFormScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
            Text('Route not found: ${state.uri}'),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
