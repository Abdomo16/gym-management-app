import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/router/route_guards.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_placeholder_screen.dart';
import 'package:gym_management_app/core/widgets/app_scaffold.dart';
import 'package:gym_management_app/core/widgets/app_splash_screen.dart';
import 'package:gym_management_app/features/attendance/presentation/screens/check_in_screen.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/screens/account_disabled_screen.dart';
import 'package:gym_management_app/features/auth/presentation/screens/auth_error_screen.dart';
import 'package:gym_management_app/features/auth/presentation/screens/invitation_accept_screen.dart';
import 'package:gym_management_app/features/auth/presentation/screens/login_screen.dart';
import 'package:gym_management_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:gym_management_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:gym_management_app/features/employees/presentation/screens/edit_employee_screen.dart';
import 'package:gym_management_app/features/employees/presentation/screens/employee_details_screen.dart';
import 'package:gym_management_app/features/employees/presentation/screens/employees_screen.dart';
import 'package:gym_management_app/features/employees/presentation/screens/invite_employee_screen.dart';
import 'package:gym_management_app/features/members/presentation/screens/create_member_screen.dart';
import 'package:gym_management_app/features/members/presentation/screens/edit_member_screen.dart';
import 'package:gym_management_app/features/members/presentation/screens/member_details_screen.dart';
import 'package:gym_management_app/features/members/presentation/screens/members_screen.dart';
import 'package:gym_management_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/plan_form_screen.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/subscription_form_screen.dart';
import 'package:gym_management_app/features/subscriptions/presentation/screens/subscriptions_screen.dart';

/// The single source of truth for navigation.
///
/// The router is created once; when the auth state changes, a refresh
/// listener re-evaluates the redirect so guards react to sign-in/out,
/// onboarding and account state transitions.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
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
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountDisabled,
        builder: (context, state) => const AccountDisabledScreen(),
      ),
      GoRoute(
        path: RoutePaths.authError,
        builder: (context, state) => const AuthErrorScreen(),
      ),
      GoRoute(
        path: RoutePaths.invitationAccept,
        builder: (context, state) => const InvitationAcceptScreen(),
      ),
      GoRoute(
        path: RoutePaths.subscriptionPlanCreate,
        builder: (context, state) => const PlanFormScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),

          // Members: list, create, detail, edit
          GoRoute(
            path: RoutePaths.members,
            builder: (context, state) => const MembersScreen(),
          ),
          GoRoute(
            path: RoutePaths.membersCreate,
            builder: (context, state) => const CreateMemberScreen(),
          ),
          GoRoute(
            path: '/members/:id',
            builder: (context, state) =>
                MemberDetailsScreen(memberId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/members/:id/edit',
            builder: (context, state) =>
                EditMemberScreen(memberId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/members/:id/subscriptions/new',
            builder: (context, state) =>
                SubscriptionFormScreen(memberId: state.pathParameters['id']!),
          ),

          GoRoute(
            path: RoutePaths.checkIn,
            builder: (context, state) => CheckInScreen(
              initialMemberId: state.uri.queryParameters['memberId'],
            ),
          ),
          GoRoute(
            path: RoutePaths.attendance,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Attendance'),
          ),
          GoRoute(
            path: RoutePaths.subscriptions,
            builder: (context, state) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path: RoutePaths.payments,
            builder: (context, state) =>
                const AppPlaceholderScreen(featureName: 'Payments'),
          ),
          GoRoute(
            path: RoutePaths.employees,
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: RoutePaths.employeeInvite,
            builder: (context, state) => const InviteEmployeeScreen(),
          ),
          GoRoute(
            path: '/admin/employees/:id',
            builder: (context, state) =>
                EmployeeDetailsScreen(employeeId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin/employees/:id/edit',
            builder: (context, state) =>
                EditEmployeeScreen(employeeId: state.pathParameters['id']!),
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
