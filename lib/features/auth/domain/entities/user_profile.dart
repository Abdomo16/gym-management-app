import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// Roles supported by the multi-tenant system.
///
/// Role values match the `role` column in `public.profiles`, which is the
/// single source of truth for authorization-related identity. The database
/// RLS remains the final security boundary; these helpers only drive UI and
/// navigation decisions.
enum UserRole { owner, manager, receptionist }

extension UserRoleX on UserRole {
  /// Maps a database role string to a [UserRole].
  ///
  /// Returns `null` for unknown values so callers can fail safely instead of
  /// silently downgrading to a lower-privilege role.
  static UserRole? fromWireName(String? value) {
    for (final role in UserRole.values) {
      if (role.name == value) {
        return role;
      }
    }
    return null;
  }

  /// Human-readable role label for the UI.
  String get label {
    return switch (this) {
      UserRole.owner => 'Owner',
      UserRole.manager => 'Manager',
      UserRole.receptionist => 'Receptionist',
    };
  }

  bool get isOwner => this == UserRole.owner;
  bool get isManager => this == UserRole.manager;
  bool get isReceptionist => this == UserRole.receptionist;
  bool get isOwnerOrManager => isOwner || isManager;

  // UI/navigation capability helpers. These are NOT a security boundary —
  // Supabase RLS is authoritative for every operation.
  bool get canManageEmployees => isOwnerOrManager;
  bool get canManageBranches => isOwnerOrManager;
  bool get canManagePlans => isOwnerOrManager;
}

/// The user's record in `public.profiles`.
///
/// This is the source of truth for the user's organization, branch, role and
/// active status. Auth (Supabase) only establishes *who* the user is; the
/// profile establishes *what they may do*.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? organizationId,
    String? branchId,
    String? fullName,
    String? phone,
    required UserRole role,
    String? avatarUrl,
    @Default(true) bool isActive,
  }) = _UserProfile;

  const UserProfile._();
}
