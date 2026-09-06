import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Global navigation guard wired into GoRouter.
///
/// 1. While the initial auth check is running → show the splash screen.
/// 2. Unauthenticated users → redirected to sign-in.
/// 3. Authenticated users → kept inside the app shell, bounced away from
///    auth-related screens.
String? appRedirect(Ref ref, GoRouterState state) {
  final location = state.uri.path;
  final authState = ref.read(authControllerProvider);

  if (authState.isLoading) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  final user = authState.value;
  if (user == null) {
    return location == RoutePaths.signIn ? null : RoutePaths.signIn;
  }

  if (location == RoutePaths.root ||
      location == RoutePaths.signIn ||
      location == RoutePaths.splash) {
    return RoutePaths.dashboard;
  }

  return null;
}

/// Hook for future role-based authorization.
///
/// Callers decide whether [user] may access [location] and return a redirect
/// location when access must be denied (or `null` when access is allowed).
/// Wire this into [appRedirect] once the backend populates roles.
String? roleRedirect({required String location, required AppUser user}) {
  // Reserved for role enforcement in a later phase.
  return null;
}
