import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/router/route_guards.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_placeholder_screen.dart';
import 'package:gym_management_app/core/widgets/app_scaffold.dart';
import 'package:gym_management_app/core/widgets/app_splash_screen.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:gym_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:gym_management_app/features/settings/presentation/screens/settings_screen.dart';

/// The single source of truth for navigation.
///
/// The router is created once; when the auth state changes, a refresh
/// listener re-evaluates the redirect so guards react to sign-in/out.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);

  ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (previous, next) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: RoutePaths.root,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => appRedirect(ref, state),
    errorBuilder: (context, state) => const AppErrorState(
      message: 'The page you requested could not be found.',
    ),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const AppSplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.members,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Members'),
          ),
          GoRoute(
            path: RoutePaths.checkIn,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Check-in'),
          ),
          GoRoute(
            path: RoutePaths.attendance,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Attendance'),
          ),
          GoRoute(
            path: RoutePaths.subscriptions,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Subscriptions'),
          ),
          GoRoute(
            path: RoutePaths.payments,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Payments'),
          ),
          GoRoute(
            path: RoutePaths.employees,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Employees'),
          ),
          GoRoute(
            path: RoutePaths.reports,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Reports'),
          ),
          GoRoute(
            path: RoutePaths.notifications,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Notifications'),
          ),
          GoRoute(
            path: RoutePaths.branches,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Branches'),
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Profile'),
          ),
        ],
      ),
    ],
  );
});
