import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Minimum access requirement for a route.
///
/// Only the requirements used in this phase are enforced (everything in the
/// authenticated shell requires [RouteRequirement.authenticated]). Owner-only
/// routes can opt into stricter requirements by extending
/// [routeRequirementFor].
enum RouteRequirement { authenticated, owner, managerOrOwner, receptionist }

extension RouteRequirementX on RouteRequirement {
  /// Whether [role] may access this requirement.
  ///
  /// This is a UI/navigation decision only. Supabase RLS is the real
  /// security boundary for every operation.
  bool allows(UserRole role) {
    return switch (this) {
      RouteRequirement.authenticated => true,
      RouteRequirement.owner => role.isOwner,
      RouteRequirement.managerOrOwner => role.isOwnerOrManager,
      RouteRequirement.receptionist => role.isReceptionist,
    };
  }
}

/// Returns the requirement for a location, or `null` when the location is
/// open to any authenticated user.
RouteRequirement? routeRequirementFor(String location) {
  // Phase 02: every shell route requires authentication only. Role-gated
  // routes (owner/manager) will be added here in later phases.
  return null;
}

/// Global navigation guard wired into GoRouter.
///
/// Every auth state maps to exactly one allowed destination, which prevents
/// redirect loops and startup flicker:
///
/// * initializing → splash
/// * unauthenticated → login
/// * needs onboarding (session, no profile/org) → onboarding (or invite)
/// * disabled account → account-disabled screen
/// * error → auth-error screen (retry)
/// * authenticated → shell; public/auth routes bounce to the dashboard
String? appRedirect(Ref ref, GoRouterState state) {
  final location = state.uri.path;
  final authState = ref.read(authControllerProvider);

  return switch (authState) {
    AuthInitializing() =>
      location == RoutePaths.splash ? null : RoutePaths.splash,
    AuthUnauthenticated() =>
      location == RoutePaths.login ? null : RoutePaths.login,
    AuthNeedsOnboarding() =>
      (location == RoutePaths.onboarding ||
          location == RoutePaths.invitationAccept)
      ? null
      : RoutePaths.onboarding,
    AuthDisabled() =>
      location == RoutePaths.accountDisabled ? null : RoutePaths.accountDisabled,
    AuthError() =>
      location == RoutePaths.authError ? null : RoutePaths.authError,
    AuthAuthenticated(:final user) => _authenticatedRedirect(
      location,
      user.role,
    ),
  };
}

String? _authenticatedRedirect(String location, UserRole role) {
  const outsideShell = {
    RoutePaths.root,
    RoutePaths.splash,
    RoutePaths.login,
    RoutePaths.onboarding,
    RoutePaths.accountDisabled,
    RoutePaths.authError,
    RoutePaths.invitationAccept,
  };
  if (outsideShell.contains(location)) {
    return RoutePaths.dashboard;
  }
  final requirement = routeRequirementFor(location);
  if (requirement != null && !requirement.allows(role)) {
    return RoutePaths.dashboard;
  }
  return null;
}
