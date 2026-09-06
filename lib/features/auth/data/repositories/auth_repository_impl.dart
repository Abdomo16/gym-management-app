import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gym_management_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Supabase-backed implementation of [AuthRepository].
///
/// Authorization-relevant identity (organization, branch, role, active
/// status) comes exclusively from `public.profiles`; `user_metadata` is never
/// trusted for authorization.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required AuthRemoteDataSource authDataSource,
    required ProfileRemoteDataSource profileDataSource,
  }) : _auth = authDataSource,
       _profile = profileDataSource;

  final AuthRemoteDataSource _auth;
  final ProfileRemoteDataSource _profile;

  @override
  Future<AuthState> restoreSession() async {
    try {
      final userId = await _auth.getCurrentUserId();
      if (userId == null) {
        return const AuthUnauthenticated();
      }
      final email = await _auth.getCurrentUserEmail() ?? '';

      final profile = await _profile.getProfileById(userId);
      if (profile == null ||
          profile.organizationId == null ||
          profile.organizationId!.isEmpty) {
        return AuthNeedsOnboarding(email: email);
      }
      if (!profile.isActive) {
        return AuthDisabled(email: email);
      }
      return AuthAuthenticated(
        AppUser(id: userId, email: email, profile: profile),
      );
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Stream<AuthEvent> onAuthStateChanged() => _auth.onAuthStateChanged();

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmail(email: email, password: password);
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<UserProfile> getCurrentProfile() async {
    try {
      final userId = await _auth.getCurrentUserId();
      if (userId == null) {
        throw const AuthFailure(message: 'You are not signed in.');
      }
      final profile = await _profile.getProfileById(userId);
      if (profile == null) {
        throw const AuthFailure(message: 'Your profile could not be found.');
      }
      return profile;
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<AuthState> createOrganizationWithOwner({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  }) async {
    try {
      await _profile.createOrganizationWithOwner(
        orgName: orgName,
        ownerFullName: ownerFullName,
        ownerPhone: ownerPhone,
        timezone: timezone,
      );
      // Reload the profile; the RPC created the owner profile and the
      // organization.
      return await restoreSession();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<AuthState> acceptInvitation(String token) async {
    try {
      await _profile.acceptInvitation(token);
      return await restoreSession();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
