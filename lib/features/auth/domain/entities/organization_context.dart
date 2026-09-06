import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

/// Immutable snapshot of the authenticated user's tenant context.
///
/// [organizationId] and [branchId] come from `public.profiles` — never from
/// client-supplied input or `user_metadata`. RLS enforces that these values
/// are valid for the user.
class OrganizationContext {
  const OrganizationContext({
    required this.organizationId,
    required this.role,
    required this.profile,
    this.branchId,
  });

  final String organizationId;
  final String? branchId;
  final UserRole role;
  final UserProfile profile;
}
