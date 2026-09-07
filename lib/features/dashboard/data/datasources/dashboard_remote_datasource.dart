import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/utils/organization_calendar.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRemoteData {
  const DashboardRemoteData({
    required this.summary,
    required this.businessDate,
    required this.recentCheckIns,
    required this.expiringSubscriptions,
  });

  final Map<String, int> summary;
  final DateTime businessDate;
  final List<Map<String, dynamic>> recentCheckIns;
  final List<Map<String, dynamic>> expiringSubscriptions;
}

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _organizationsTable = 'organizations';
  static const String _profilesTable = 'profiles';
  static const String _membersTable = 'members';
  static const String _subscriptionsTable = 'subscriptions';
  static const String _attendanceTable = 'attendance';

  Future<DashboardRemoteData> getDashboard() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(
          message: 'Your session has expired. Please sign in again.',
        );
      }
      final profile = await _client
          .from(_profilesTable)
          .select('organization_id')
          .eq('id', userId)
          .single();
      final organizationId = profile['organization_id'] as String?;
      if (organizationId == null) {
        throw const AuthFailure(
          message: 'Your organization profile is unavailable.',
        );
      }
      final organization = await _client
          .from(_organizationsTable)
          .select('timezone,expiring_soon_days')
          .eq('id', organizationId)
          .single();
      final timezone = organization['timezone'] as String? ?? 'UTC';
      final expiringSoonDays =
          (organization['expiring_soon_days'] as num?)?.toInt() ?? 7;
      final businessDate = OrganizationCalendar.businessDate(timezone);
      final businessDateString = _dateOnly(businessDate);
      final expirationDate = businessDate.add(Duration(days: expiringSoonDays));
      final expirationDateString = _dateOnly(expirationDate);

      final counts = await Future.wait<int>([
        _countMembers(),
        _countActiveMembers(),
        _countValidSubscriptions(businessDateString),
        _countExpiringSubscriptions(businessDateString, expirationDateString),
        _countExpiredSubscriptions(businessDateString),
        _countTodayCheckIns(businessDateString),
      ]);

      final recentCheckIns = await _getRecentCheckIns(businessDateString);
      final expiringSubscriptions = await _getExpiringSubscriptions(
        businessDateString,
        expirationDateString,
      );

      return DashboardRemoteData(
        summary: {
          'total_members': counts[0],
          'active_members': counts[1],
          'active_subscriptions': counts[2],
          'expiring_soon_subscriptions': counts[3],
          'expired_subscriptions': counts[4],
          'today_check_ins': counts[5],
        },
        businessDate: businessDate,
        recentCheckIns: recentCheckIns,
        expiringSubscriptions: expiringSubscriptions,
      );
    } on PostgrestException catch (error) {
      throw SupabaseFailure(
        message: 'Unable to load the dashboard. Please try again.',
        code: error.code,
        cause: error,
      );
    }
  }

  Future<int> _countValidSubscriptions(String businessDate) {
    return _count(
      _client
          .from(_subscriptionsTable)
          .select('id')
          .inFilter('status', ['active', 'expiring'])
          .lte('start_date', businessDate)
          .gt('end_date', businessDate),
    );
  }

  Future<int> _countExpiringSubscriptions(
    String businessDate,
    String expirationDate,
  ) {
    return _count(
      _client
          .from(_subscriptionsTable)
          .select('id')
          .inFilter('status', ['active', 'expiring'])
          .lte('start_date', businessDate)
          .gt('end_date', businessDate)
          .lte('end_date', expirationDate),
    );
  }

  Future<int> _countExpiredSubscriptions(String businessDate) async {
    final storedExpired = await _count(
      _client.from(_subscriptionsTable).select('id').eq('status', 'expired'),
    );
    final elapsedActive = await _count(
      _client
          .from(_subscriptionsTable)
          .select('id')
          .inFilter('status', ['active', 'expiring'])
          .lte('start_date', businessDate)
          .lte('end_date', businessDate),
    );
    return storedExpired + elapsedActive;
  }

  Future<int> _countMembers() {
    return _count(_client.from(_membersTable).select('id'));
  }

  Future<int> _countActiveMembers() {
    return _count(
      _client.from(_membersTable).select('id').eq('status', 'active'),
    );
  }

  Future<int> _countTodayCheckIns(String businessDate) {
    return _count(
      _client
          .from(_attendanceTable)
          .select('id')
          .eq('check_in_day', businessDate),
    );
  }

  Future<int> _count(PostgrestFilterBuilder<PostgrestList> query) async {
    final response = await query.count(CountOption.exact);
    return response.count;
  }

  Future<List<Map<String, dynamic>>> _getRecentCheckIns(
    String businessDate,
  ) async {
    final rows = await _client
        .from(_attendanceTable)
        .select(
          'id,organization_id,member_id,branch_id,checked_in_by,'
          'check_in_at,check_in_day',
        )
        .eq('check_in_day', businessDate)
        .order('check_in_at', ascending: false)
        .limit(10);
    final attendance = _asList(rows);
    final memberIds = attendance
        .map((row) => row['member_id'] as String)
        .toSet()
        .toList();
    final members = await _getMemberSummaries(memberIds);
    return [
      for (final row in attendance)
        {
          ...row,
          'member_name': members[row['member_id']]?['full_name'] ?? 'Member',
          'member_code': members[row['member_id']]?['member_code'],
        },
    ];
  }

  Future<List<Map<String, dynamic>>> _getExpiringSubscriptions(
    String businessDate,
    String expirationDate,
  ) async {
    final rows = await _client
        .from(_subscriptionsTable)
        .select()
        .inFilter('status', ['active', 'expiring'])
        .lte('start_date', businessDate)
        .gt('end_date', businessDate)
        .lte('end_date', expirationDate)
        .order('end_date')
        .limit(10);
    final subscriptions = _asList(rows);
    final memberIds = subscriptions
        .map((row) => row['member_id'] as String)
        .toSet()
        .toList();
    final planIds = subscriptions
        .map((row) => row['plan_id'] as String)
        .toSet()
        .toList();
    final members = await _getMemberSummaries(memberIds);
    final plans = await _getPlanSummaries(planIds);
    return [
      for (final row in subscriptions)
        {
          ...row,
          'member_name': members[row['member_id']]?['full_name'] ?? 'Member',
          'member_code': members[row['member_id']]?['member_code'],
          'plan_name': plans[row['plan_id']]?['name'],
        },
    ];
  }

  Future<Map<String, Map<String, dynamic>>> _getMemberSummaries(
    List<String> memberIds,
  ) async {
    if (memberIds.isEmpty) {
      return const {};
    }
    final rows = await _client
        .from(_membersTable)
        .select('id,full_name,member_code')
        .inFilter('id', memberIds);
    return {for (final row in _asList(rows)) row['id'] as String: row};
  }

  Future<Map<String, Map<String, dynamic>>> _getPlanSummaries(
    List<String> planIds,
  ) async {
    if (planIds.isEmpty) {
      return const {};
    }
    final rows = await _client
        .from('subscription_plans')
        .select('id,name')
        .inFilter('id', planIds);
    return {for (final row in _asList(rows)) row['id'] as String: row};
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }
}
