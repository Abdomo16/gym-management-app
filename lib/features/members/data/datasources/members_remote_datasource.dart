import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data access for `public.members` and branch lookup.
///
/// Every query is tenant-scoped: the current organization is enforced by
/// RLS, and branch lookups filter by the authenticated organization
/// server-side. The client never selects an organization.
class MembersRemoteDataSource {
  MembersRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _membersTable = 'members';
  static const String _branchesTable = 'branches';

  /// Loads the first page of members (newest first) for the current org.
  Future<List<Map<String, dynamic>>> getMembers({int limit = 50}) async {
    final rows = await _client
        .from(_membersTable)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return _asList(rows);
  }

  /// Searches members by name, phone or member code.
  ///
  /// The approved `search_members` RPC is not yet present in the production
  /// database (verified via the schema cache), so the search is performed as
  /// an RLS-scoped table query with a bounded limit. The tenant boundary is
  /// still enforced by the database, never by client-side filtering.
  Future<List<Map<String, dynamic>>> searchMembers(
    String query, {
    int limit = 20,
  }) async {
    final term = _escapeLike(query.trim());
    final rows = await _client
        .from(_membersTable)
        .select()
        .or(
          'full_name.ilike.%$term%,phone.ilike.%$term%,'
          'member_code.ilike.%$term%',
        )
        .order('full_name')
        .limit(limit);
    return _asList(rows);
  }

  /// Loads a single member row, or `null` when not found.
  Future<Map<String, dynamic>?> getMemberById(String id) async {
    final row = await _client
        .from(_membersTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    return row;
  }

  /// Inserts a member and returns the created row, including the
  /// database-generated `member_code`.
  Future<Map<String, dynamic>> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      final row = await _client
          .from(_membersTable)
          .insert({
            'organization_id': organizationId,
            'branch_id': branchId,
            'full_name': fullName,
            'phone': phone,
            'gender': gender,
            'date_of_birth': dateOfBirth?.toIso8601String(),
            'photo_url': photoUrl,
            'notes': notes,
          })
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Updates mutable fields of an existing member.
  Future<Map<String, dynamic>> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      final row = await _client
          .from(_membersTable)
          .update({
            'branch_id': branchId,
            'full_name': fullName,
            'phone': phone,
            'gender': gender,
            'date_of_birth': dateOfBirth?.toIso8601String(),
            'photo_url': photoUrl,
            'notes': notes,
          })
          .eq('id', id)
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Updates only the `status` column (active/inactive/blocked).
  Future<Map<String, dynamic>> updateMemberStatus({
    required String id,
    required String status,
  }) async {
    try {
      final row = await _client
          .from(_membersTable)
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Branches belonging to the authenticated organization.
  Future<List<BranchSummary>> getOrganizationBranches(
    String organizationId,
  ) async {
    final rows = await _client
        .from(_branchesTable)
        .select('id,name')
        .eq('organization_id', organizationId)
        .order('name');
    return [
      for (final row in _asList(rows))
        BranchSummary(id: row['id'] as String, name: row['name'] as String),
    ];
  }

  /// Maps PostgREST failures to friendly, non-technical messages.
  AppFailure _mapPostgrestError(PostgrestException error) {
    // 23505 = unique_violation. The members table has
    // unique (organization_id, phone), so this is a duplicate phone.
    if (error.code == '23505') {
      return const SupabaseFailure(
        message: 'A member with this phone number already exists.',
      );
    }
    return SupabaseFailure(
      message: 'Unable to save the member. Please try again.',
      code: error.code,
      cause: error,
    );
  }

  static String _escapeLike(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }
}
