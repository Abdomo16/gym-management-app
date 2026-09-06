import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Restores the current session and profile into an explicit [AuthState].
///
/// This is the single decision point that maps "has a Supabase session" into
/// "is a usable application user".
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<AuthState> call() => _repository.restoreSession();
}
