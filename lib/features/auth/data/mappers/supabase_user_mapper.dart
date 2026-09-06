import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps a Supabase [User] to the application's [AppUser] entity.
extension SupabaseUserMapper on User {
  AppUser toAppUser() {
    final metadata = userMetadata;
    return AppUser(
      id: id,
      email: email ?? '',
      displayName: metadata?['full_name'] as String?,
      role: UserRoleX.fromWireName(metadata?['role'] as String?),
    );
  }
}
