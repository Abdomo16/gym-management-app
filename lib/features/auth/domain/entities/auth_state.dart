import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';

/// Authentication-related events surfaced from Supabase Auth.
enum AuthEvent { signedIn, signedOut, tokenRefreshed, userUpdated }

/// Explicit application authentication state.
///
/// One sealed hierarchy is shared by the repository (as the result of session
/// restoration), the controller, the providers and the router guard, so there
/// is a single source of truth for "where is the user in the auth lifecycle".
sealed class AuthState {
  const AuthState();
}

/// Initial session/profile restoration is still running.
class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// No valid Supabase session exists.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// The user has a session but no usable profile yet (e.g. a fresh signup or
/// an invited employee who has not accepted). They must be onboarded.
class AuthNeedsOnboarding extends AuthState {
  const AuthNeedsOnboarding({required this.email});

  final String email;
}

/// The user has a session but their profile is inactive/disabled.
class AuthDisabled extends AuthState {
  const AuthDisabled({required this.email});

  final String email;
}

/// Session restoration failed with a typed failure.
class AuthError extends AuthState {
  const AuthError(this.failure);

  final AppFailure failure;
}

/// The user has a session and a valid, active profile.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;
}
