import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

/// Builds an authenticated user for tests.
AppUser makeAppUser({
  String id = 'user-1',
  String email = 'owner@gym.test',
  String? fullName = 'Alex Owner',
  String? organizationId = 'org-1',
  String? branchId,
  UserRole role = UserRole.owner,
  bool isActive = true,
}) {
  return AppUser(
    id: id,
    email: email,
    profile: UserProfile(
      id: id,
      organizationId: organizationId,
      branchId: branchId,
      fullName: fullName,
      role: role,
      isActive: isActive,
    ),
  );
}

/// Convenience for tests that need an authenticated state.
AuthAuthenticated authenticatedState({
  String? fullName = 'Alex Owner',
  UserRole role = UserRole.owner,
}) {
  return AuthAuthenticated(makeAppUser(fullName: fullName, role: role));
}
