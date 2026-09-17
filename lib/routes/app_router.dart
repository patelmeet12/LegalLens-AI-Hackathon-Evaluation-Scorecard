import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/landing_page.dart';
import '../presentation/pages/upload_page.dart';
import '../presentation/pages/snapshot_page.dart';
import '../presentation/pages/clauses_page.dart';
import '../presentation/pages/obligations_page.dart';
import '../presentation/pages/timeline_page.dart';
import '../presentation/pages/risk_map_page.dart';
import '../presentation/pages/qa_page.dart';
import '../presentation/pages/comparison_page.dart';
import '../presentation/pages/action_center_page.dart';
import '../presentation/pages/history_page.dart';
import '../presentation/pages/options_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/widgets/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(child: LandingPage()),
        ),
        GoRoute(
          path: '/upload',
          pageBuilder: (context, state) => const NoTransitionPage(child: UploadPage()),
        ),
        GoRoute(
          path: '/snapshot',
          pageBuilder: (context, state) => const NoTransitionPage(child: SnapshotPage()),
        ),
        GoRoute(
          path: '/clauses',
          pageBuilder: (context, state) => const NoTransitionPage(child: ClausesPage()),
        ),
        GoRoute(
          path: '/obligations',
          pageBuilder: (context, state) => const NoTransitionPage(child: ObligationsPage()),
        ),
        GoRoute(
          path: '/timeline',
          pageBuilder: (context, state) => const NoTransitionPage(child: TimelinePage()),
        ),
        GoRoute(
          path: '/risk-map',
          pageBuilder: (context, state) => const NoTransitionPage(child: RiskMapPage()),
        ),
        GoRoute(
          path: '/options',
          pageBuilder: (context, state) => const NoTransitionPage(child: OptionsPage()),
        ),
        GoRoute(
          path: '/qa',
          pageBuilder: (context, state) => const NoTransitionPage(child: QAPage()),
        ),
        GoRoute(
          path: '/comparison',
          pageBuilder: (context, state) => const NoTransitionPage(child: ComparisonPage()),
        ),
        GoRoute(
          path: '/action-center',
          pageBuilder: (context, state) => const NoTransitionPage(child: ActionCenterPage()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(child: HistoryPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);
