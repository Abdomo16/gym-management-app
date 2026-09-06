import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Tracks the current authenticated user and exposes auth actions.
///
/// The initial session is resolved once in [build]; afterwards the auth
/// stream keeps [state] in sync with sign-in and sign-out events. The router
/// guard watches this provider to enforce access.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final currentUser = await repository.getCurrentUser();
    final subscription = repository.onAuthStateChanged().listen((user) {
      state = AsyncData(user);
    });
    ref.onDispose(subscription.cancel);
    return currentUser;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signInWithEmail(email: email, password: password);
    // The auth stream updates [state]; the router guard reacts to it.
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
  }
}
