import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

/// Maps a `public.profiles` row (PostgREST map) into the [UserProfile]
/// entity.
abstract final class ProfileMapper {
  static UserProfile fromMap(Map<String, dynamic> map) {
    final role = UserRoleX.fromWireName(map['role'] as String?);
    if (role == null) {
      throw const ValidationFailure(
        message: 'This account has an unsupported role. Please contact your '
            'gym administrator.',
      );
    }
    return UserProfile(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String?,
      branchId: map['branch_id'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      role: role,
      avatarUrl: map['avatar_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
