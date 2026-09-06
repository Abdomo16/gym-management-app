import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// Roles supported by the multi-tenant system.
///
/// Role values match the `role` claim stored in Supabase user metadata and
/// are the basis for future role-based authorization.
enum UserRole { owner, manager, receptionist }

extension UserRoleX on UserRole {
  static UserRole fromWireName(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      // Unknown or missing roles default to the least-privileged role.
      orElse: () => UserRole.receptionist,
    );
  }
}

/// The authenticated user in the context of the application.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    @Default(UserRole.receptionist) UserRole role,
  }) = _AppUser;

  const AppUser._();
}
