import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

part 'app_user.freezed.dart';

/// The authenticated application user.
///
/// `id` and `email` come from Supabase Auth; the business identity
/// (organization, branch, role, active status) comes exclusively from the
/// user's `public.profiles` record via [profile].
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required UserProfile profile,
  }) = _AppUser;

  const AppUser._();

  String get fullName => profile.fullName ?? email;

  String? get phone => profile.phone;
  String? get avatarUrl => profile.avatarUrl;
  String? get organizationId => profile.organizationId;
  String? get branchId => profile.branchId;
  bool get isActive => profile.isActive;
  UserRole get role => profile.role;
}
