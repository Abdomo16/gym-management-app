import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _attendanceTable = 'attendance';
  static const String _checkInRpc = 'check_in_member';

  Future<Map<String, dynamic>> checkIn({required String memberId}) async {
    try {
      final result = await _client.rpc<dynamic>(
        _checkInRpc,
        params: {'p_member_id': memberId},
      );
      if (result is Map) {
        return result.cast<String, dynamic>();
      }
      if (result is List && result.isNotEmpty && result.first is Map) {
        return (result.first as Map).cast<String, dynamic>();
      }
      throw const ValidationFailure(
        message: 'The check-in response was incomplete.',
      );
    } on PostgrestException catch (error) {
      throw _mapCheckInError(error);
    }
  }

  Future<List<Map<String, dynamic>>> getMemberAttendance(
    String memberId, {
    int limit = 20,
  }) async {
    try {
      final rows = await _client
          .from(_attendanceTable)
          .select()
          .eq('member_id', memberId)
          .order('check_in_day', ascending: false)
          .order('check_in_at', ascending: false)
          .limit(limit);
      return _asList(rows);
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const SupabaseFailure(
          message: 'You do not have permission to view attendance history.',
          code: 'attendance_forbidden',
          cause: null,
        );
      }
      throw SupabaseFailure(
        message: 'Unable to load attendance history. Please try again.',
        code: error.code,
        cause: error,
      );
    }
  }

  AppFailure _mapCheckInError(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (error.code == '23505' || message.contains('already checked in')) {
      return const SupabaseFailure(
        message: 'This member has already checked in today.',
        code: 'duplicate_attendance',
        cause: null,
      );
    }
    if (error.code == '42501') {
      return const SupabaseFailure(
        message: 'You do not have permission to check in this member.',
        code: 'attendance_forbidden',
        cause: null,
      );
    }
    if (error.code == '23503') {
      return const SupabaseFailure(
        message: 'This member could not be checked in.',
        code: 'attendance_reference_error',
        cause: null,
      );
    }
    if (error.code == '23514') {
      return const SupabaseFailure(
        message: 'Check-in is not allowed for this member today.',
        code: 'attendance_not_allowed',
        cause: null,
      );
    }
    if (error.code == 'P0001' ||
        message.contains('inactive') ||
        message.contains('blocked') ||
        message.contains('subscription') ||
        message.contains('not allowed')) {
      return const SupabaseFailure(
        message: 'Check-in is not allowed for this member today.',
        code: 'attendance_not_allowed',
        cause: null,
      );
    }
    return SupabaseFailure(
      message: 'Unable to check in this member. Please try again.',
      code: error.code,
      cause: error,
    );
  }

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }
}