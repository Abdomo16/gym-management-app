import 'dart:async';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for widget tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.initialUser});

  AppUser? initialUser;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Future<AppUser?> getCurrentUser() async => initialUser;

  @override
  Stream<AppUser?> onAuthStateChanged() => _controller.stream;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (password == 'wrong-password') {
      throw const AuthFailure(message: 'Invalid login credentials.');
    }
    final user = AppUser(
      id: 'user-1',
      email: email,
      displayName: 'Test Manager',
      role: UserRole.manager,
    );
    initialUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    initialUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
