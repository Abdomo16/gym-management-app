import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth primitives.
///
/// Keeps Supabase types out of the repository layer and normalizes auth
/// events into the domain's [AuthEvent].
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<String?> getCurrentUserId() async {
    return _client.auth.currentUser?.id;
  }

  Future<String?> getCurrentUserEmail() async {
    return _client.auth.currentUser?.email;
  }

  Stream<AuthEvent> onAuthStateChanged() {
    return _client.auth.onAuthStateChange.map((authState) {
      return switch (authState.event) {
        AuthChangeEvent.signedIn => AuthEvent.signedIn,
        AuthChangeEvent.signedOut => AuthEvent.signedOut,
        AuthChangeEvent.userUpdated => AuthEvent.userUpdated,
        // The initial session and token refreshes do not change the user's
        // profile; the controller performs its own restoration on startup.
        _ => AuthEvent.tokenRefreshed,
      };
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
