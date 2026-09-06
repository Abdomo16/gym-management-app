import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Signs the user in with email/password via Supabase Auth.
class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
