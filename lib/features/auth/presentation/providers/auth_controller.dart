import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/usecases/accept_invitation.dart';
import 'package:gym_management_app/features/auth/domain/usecases/create_organization.dart';
import 'package:gym_management_app/features/auth/domain/usecases/restore_session.dart';
import 'package:gym_management_app/features/auth/domain/usecases/sign_in.dart';
import 'package:gym_management_app/features/auth/domain/usecases/sign_out.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Drives the application's authentication lifecycle.
///
/// [build] kicks off session restoration and subscribes to the auth stream —
/// the single source of auth-state synchronization. Every state transition
/// flows through [state] as an explicit [AuthState], which the router guard
/// consumes to enforce navigation.
class AuthController extends Notifier<AuthState> {
  StreamSubscription<AuthEvent>? _subscription;
  bool _restoring = false;

  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    _subscription = repository
        .onAuthStateChanged()
        .listen((event) => unawaited(_handleAuthEvent(event)));
    ref.onDispose(() {
      _subscription?.cancel();
    });
    unawaited(_restore());
    return const AuthInitializing();
  }

  Future<void> _handleAuthEvent(AuthEvent event) async {
    switch (event) {
      case AuthEvent.signedOut:
        state = const AuthUnauthenticated();
      case AuthEvent.signedIn:
      case AuthEvent.userUpdated:
        // Re-resolve the profile without flashing the loading screen.
        await _restore(silent: true);
      case AuthEvent.tokenRefreshed:
        // Session refresh only; the profile is unchanged.
        break;
    }
  }

  /// Resolves the current session + profile into an explicit state.
  ///
  /// When [silent] is true the current state is kept while restoring, so
  /// background events do not cause auth flicker.
  Future<void> _restore({bool silent = false}) async {
    if (_restoring) {
      return;
    }
    _restoring = true;
    try {
      if (!silent) {
        state = const AuthInitializing();
      }
      final result = await RestoreSession(ref.read(authRepositoryProvider))();
      state = result;
    } on AppFailure catch (failure) {
      state = AuthError(failure);
    } catch (error) {
      state = AuthError(ExceptionMapper.map(error));
    } finally {
      _restoring = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await SignIn(ref.read(authRepositoryProvider))(
      email: email,
      password: password,
    );
    // The auth stream emits signedIn, which triggers the profile restore.
  }

  Future<void> signOut() async {
    await SignOut(ref.read(authRepositoryProvider))();
  }

  /// Re-runs session restoration (used by the error state's retry action).
  Future<void> retry() => _restore();

  Future<void> createOrganization({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  }) async {
    final result = await CreateOrganization(ref.read(authRepositoryProvider))(
      orgName: orgName,
      ownerFullName: ownerFullName,
      ownerPhone: ownerPhone,
      timezone: timezone,
    );
    state = result;
  }

  Future<void> acceptInvitation(String token) async {
    final result = await AcceptInvitation(ref.read(authRepositoryProvider))(
      token,
    );
    state = result;
  }
}
