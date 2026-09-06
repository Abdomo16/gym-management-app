import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Signs the user out and lets the auth stream reset the application state.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
