import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/organization_context.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// The current authenticated user, or `null` when not authenticated.
final currentUserProvider = Provider<AppUser?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
});

/// The current user's `public.profiles` record, or `null`.
final currentProfileProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated(:final user) => user.profile,
    _ => null,
  };
});

/// The current tenant context (organization, branch, role), or `null`.
///
/// Values originate from the authenticated profile — never from client input
/// or `user_metadata`.
final organizationContextProvider = Provider<OrganizationContext?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated(:final user) => OrganizationContext(
      // restoreSession guarantees a non-null organization id when
      // authenticated.
      organizationId: user.profile.organizationId!,
      branchId: user.profile.branchId,
      role: user.profile.role,
      profile: user.profile,
    ),
    _ => null,
  };
});
