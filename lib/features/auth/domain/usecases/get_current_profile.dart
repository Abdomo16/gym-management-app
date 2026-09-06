import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Loads the current user's profile from `public.profiles`.
class GetCurrentProfile {
  const GetCurrentProfile(this._repository);

  final AuthRepository _repository;

  Future<UserProfile> call() => _repository.getCurrentProfile();
}
