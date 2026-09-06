import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Accepts an employee invitation using the database's invitation mechanism.
class AcceptInvitation {
  const AcceptInvitation(this._repository);

  final AuthRepository _repository;

  Future<AuthState> call(String token) => _repository.acceptInvitation(token);
}
