import 'dart:async';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

import 'auth_fixtures.dart';

/// In-memory [AuthRepository] for widget and controller tests.
///
/// Emulates the real repository's contract: after a successful sign-in the
/// fake emits `signedIn` and the controller restores the state set via
/// [setRestoreResult], mirroring how Supabase emits auth events and the real
/// repository then reloads the profile.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthState initialRestore = const AuthUnauthenticated(),
    this.signInError,
    this.restoreError,
    this.createOrganizationError,
    this.acceptInvitationError,
  }) : _restoreResult = initialRestore;

  AuthState _restoreResult;
  AppFailure? signInError;
  AppFailure? restoreError;
  AppFailure? createOrganizationError;
  AppFailure? acceptInvitationError;

  final _events = StreamController<AuthEvent>.broadcast();

  /// Overrides what [restoreSession] returns after an auth event.
  void setRestoreResult(AuthState state) {
    _restoreResult = state;
  }

  AuthState get restoreResult => _restoreResult;

  void emit(AuthEvent event) {
    _events.add(event);
  }

  @override
  Future<AuthState> restoreSession() async {
    final error = restoreError;
    if (error != null) {
      throw error;
    }
    return _restoreResult;
  }

  @override
  Stream<AuthEvent> onAuthStateChanged() => _events.stream;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final error = signInError;
    if (error != null) {
      throw error;
    }
    emit(AuthEvent.signedIn);
  }

  @override
  Future<void> signOut() async {
    setRestoreResult(const AuthUnauthenticated());
    emit(AuthEvent.signedOut);
  }

  @override
  Future<UserProfile> getCurrentProfile() async {
    final state = _restoreResult;
    if (state is AuthAuthenticated) {
      return state.user.profile;
    }
    throw const AuthFailure(message: 'You are not signed in.');
  }

  @override
  Future<AuthState> createOrganizationWithOwner({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  }) async {
    final error = createOrganizationError;
    if (error != null) {
      throw error;
    }
    setRestoreResult(
      AuthAuthenticated(
        makeAppUser(fullName: ownerFullName),
      ),
    );
    return _restoreResult;
  }

  @override
  Future<AuthState> acceptInvitation(String token) async {
    final error = acceptInvitationError;
    if (error != null) {
      throw error;
    }
    setRestoreResult(
      AuthAuthenticated(
        makeAppUser(
          fullName: 'New Employee',
          role: UserRole.manager,
          email: 'employee@gym.test',
        ),
      ),
    );
    return _restoreResult;
  }

  void dispose() {
    _events.close();
  }
}
