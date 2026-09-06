import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';

/// Contract for authentication operations.
///
/// Implementations must translate low-level errors into [AppFailure]
/// subtypes before they reach the rest of the application.
abstract interface class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Stream<AppUser?> onAuthStateChanged();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
