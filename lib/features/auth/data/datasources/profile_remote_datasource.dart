import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/data/mappers/profile_mapper.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data access for `public.profiles` and organization/invitation RPCs.
///
/// All queries are scoped by RLS; the current-user profile query filters by
/// the authenticated user's id server-side.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _profilesTable = 'profiles';
  static const String _createOrganizationRpc = 'create_organization_with_owner';
  static const String _acceptInvitationRpc = 'accept_employee_invitation';

  /// Loads the profile for [userId] from `public.profiles`, or `null` when
  /// the profile does not exist.
  Future<UserProfile?> getProfileById(String userId) async {
    final row = await _client
        .from(_profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return ProfileMapper.fromMap(row);
  }

  /// Calls the approved `create_organization_with_owner` RPC.
  ///
  /// The RPC is responsible for creating the organization and the owner
  /// profile; the client never writes to `organizations` directly.
  Future<void> createOrganizationWithOwner({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  }) async {
    try {
      await _client.rpc<void>(
        _createOrganizationRpc,
        params: {
          'p_org_name': orgName,
          'p_owner_full_name': ownerFullName,
          'p_owner_phone': ownerPhone,
          'p_timezone': timezone,
        },
      );
    } on PostgrestException catch (error) {
      throw SupabaseFailure(
        message: 'Could not create your gym. Please try again.',
        code: error.code,
        cause: error,
      );
    }
  }

  /// Accepts an employee invitation via the database's invitation mechanism.
  Future<void> acceptInvitation(String token) async {
    try {
      await _client.rpc<String>(
        _acceptInvitationRpc,
        params: {'p_token': token},
      );
    } on PostgrestException catch (error) {
      throw SupabaseFailure(
        message: 'Unable to accept the invitation. Please try again.',
        code: error.code,
        cause: error,
      );
    }
  }
}
