import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/auth/data/mappers/supabase_user_mapper.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user?.toAppUser();
  }

  @override
  Stream<AppUser?> onAuthStateChanged() {
    return _client.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      return user?.toAppUser();
    });
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure(
          message: 'Sign-in completed but no session was returned.',
        );
      }
      return user.toAppUser();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
