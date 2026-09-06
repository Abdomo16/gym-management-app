import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

/// Contract for authentication and profile operations.
///
/// Implementations must translate low-level errors into [AppFailure]
/// subtypes before they reach the rest of the application. Session
/// restoration is the single entry point that decides whether the current
/// Supabase session maps to a usable application user (see [restoreSession]).
abstract interface class AuthRepository {
  /// Resolves the current session into an explicit [AuthState].
  ///
  /// * No session → [AuthUnauthenticated]
  /// * Session but missing/incomplete profile → [AuthNeedsOnboarding]
  /// * Session with inactive profile → [AuthDisabled]
  /// * Session with valid active profile → [AuthAuthenticated]
  Future<AuthState> restoreSession();

  /// Stream of authentication events (signed in/out, token refresh, update).
  Stream<AuthEvent> onAuthStateChanged();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Loads the current user's profile from `public.profiles`.
  Future<UserProfile> getCurrentProfile();

  /// Creates the first organization for a fresh owner through the approved
  /// `create_organization_with_owner` RPC, then reloads the session state.
  Future<AuthState> createOrganizationWithOwner({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  });

  /// Accepts an employee invitation, attaching the user to an organization.
  Future<AuthState> acceptInvitation(String token);
}
