import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeRemoteDataSource {
  EmployeeRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _profilesTable = 'profiles';
  static const String _branchesTable = 'branches';
  static const String _invitationRpc = 'create_employee_invitation';
  static const String _updateRpc = 'update_employee_profile';
  static const String _activeRpc = 'set_employee_active';

  Future<List<Map<String, dynamic>>> getEmployees({int limit = 100}) async {
    try {
      final rows = await _client
          .from(_profilesTable)
          .select(
            'id,organization_id,branch_id,full_name,phone,role,avatar_url,'
            'is_active,created_at,updated_at',
          )
          .neq('role', 'owner')
          .order('full_name')
          .limit(limit);
      return await _attachBranchNames(_asList(rows));
    } on PostgrestException catch (error) {
      throw _mapError(error, 'Unable to load employees.');
    }
  }

  Future<Map<String, dynamic>?> getEmployee(String id) async {
    try {
      final row = await _client
          .from(_profilesTable)
          .select(
            'id,organization_id,branch_id,full_name,phone,role,avatar_url,'
            'is_active,created_at,updated_at',
          )
          .eq('id', id)
          .neq('role', 'owner')
          .maybeSingle();
      if (row == null) {
        return null;
      }
      final rows = await _attachBranchNames([row]);
      return rows.single;
    } on PostgrestException catch (error) {
      throw _mapError(error, 'Unable to load the employee.');
    }
  }

  Future<Map<String, dynamic>> inviteEmployee({
    required String fullName,
    required String email,
    required UserRole role,
    String? branchId,
  }) async {
    _validateEmployeeRole(role);
    try {
      final row = await _client.rpc<Map<String, dynamic>>(
        _invitationRpc,
        params: {
          'p_full_name': fullName.trim(),
          'p_email': email.trim().toLowerCase(),
          'p_role': role.name,
          'p_branch_id': branchId,
        },
      );
      return row;
    } on PostgrestException catch (error) {
      throw _mapError(error, 'Unable to create the employee invitation.');
    }
  }

  Future<Map<String, dynamic>> updateEmployee({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) async {
    _validateEmployeeRole(role);
    try {
      return await _client.rpc<Map<String, dynamic>>(
        _updateRpc,
        params: {
          'p_employee_id': id,
          'p_full_name': fullName.trim(),
          'p_phone': phone?.trim(),
          'p_role': role.name,
          'p_branch_id': branchId,
        },
      );
    } on PostgrestException catch (error) {
      throw _mapError(error, 'Unable to update the employee.');
    }
  }

  Future<Map<String, dynamic>> setEmployeeActive({
    required String id,
    required bool isActive,
  }) async {
    try {
      return await _client.rpc<Map<String, dynamic>>(
        _activeRpc,
        params: {'p_employee_id': id, 'p_is_active': isActive},
      );
    } on PostgrestException catch (error) {
      throw _mapError(error, 'Unable to update the employee status.');
    }
  }

  Future<List<Map<String, dynamic>>> _attachBranchNames(
    List<Map<String, dynamic>> rows,
  ) async {
    final branchIds = rows
        .map((row) => row['branch_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (branchIds.isEmpty) {
      return rows;
    }
    final branchRows = await _client
        .from(_branchesTable)
        .select('id,name')
        .inFilter('id', branchIds);
    final branches = {
      for (final row in _asList(branchRows)) row['id'] as String: row['name'],
    };
    return [
      for (final row in rows)
        {...row, 'branch_name': branches[row['branch_id']]},
    ];
  }

  static void _validateEmployeeRole(UserRole role) {
    if (role == UserRole.owner) {
      throw const ValidationFailure(
        message: 'Owner cannot be assigned through employee management.',
      );
    }
  }

  static AppFailure _mapError(PostgrestException error, String fallback) {
    final message = error.message.toLowerCase();
    if (error.code == 'pgrst202' ||
        message.contains('could not find the function')) {
      return const SupabaseFailure(
        message:
            'Employee management is not available until the backend invitation and profile management functions are configured.',
      );
    }
    if (error.code == '42501' ||
        message.contains('not authorized') ||
        message.contains('permission denied')) {
      return const SupabaseFailure(
        message: 'You are not authorized to manage employees.',
      );
    }
    if (error.code == '23505') {
      return const SupabaseFailure(
        message: 'An invitation for this employee already exists.',
      );
    }
    return SupabaseFailure(message: fallback, code: error.code, cause: error);
  }

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }
}
