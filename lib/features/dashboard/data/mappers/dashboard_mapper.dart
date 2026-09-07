import 'package:gym_management_app/features/attendance/data/mappers/attendance_mapper.dart';
import 'package:gym_management_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_expiring_subscription.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_recent_check_in.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:gym_management_app/features/subscriptions/data/mappers/subscription_mapper.dart';

abstract final class DashboardMapper {
  static DashboardSnapshot fromRemoteData(DashboardRemoteData data) {
    return DashboardSnapshot(
      summary: DashboardSummary(
        totalMembers: data.summary['total_members'] ?? 0,
        activeMembers: data.summary['active_members'] ?? 0,
        activeSubscriptions: data.summary['active_subscriptions'] ?? 0,
        expiringSoonSubscriptions:
            data.summary['expiring_soon_subscriptions'] ?? 0,
        expiredSubscriptions: data.summary['expired_subscriptions'] ?? 0,
        todayCheckIns: data.summary['today_check_ins'] ?? 0,
      ),
      businessDate: data.businessDate,
      recentCheckIns: data.recentCheckIns
          .map(
            (row) => DashboardRecentCheckIn(
              attendance: AttendanceMapper.fromMap(row),
              memberName: row['member_name'] as String? ?? 'Member',
              memberCode: row['member_code'] as String?,
            ),
          )
          .toList(),
      expiringSubscriptions: data.expiringSubscriptions
          .map(
            (row) => DashboardExpiringSubscription(
              subscription: SubscriptionMapper.fromMap(row),
              memberName: row['member_name'] as String? ?? 'Member',
              memberCode: row['member_code'] as String?,
              planName: row['plan_name'] as String?,
              remainingDays: _remainingDays(row['end_date'], data.businessDate),
            ),
          )
          .toList(),
    );
  }

  static int _remainingDays(Object? value, DateTime businessDate) {
    final endDate = value is String ? DateTime.tryParse(value) : null;
    if (endDate == null) {
      return 0;
    }
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final date = DateTime(
      businessDate.year,
      businessDate.month,
      businessDate.day,
    );
    final days = end.difference(date).inDays;
    return days < 0 ? 0 : days;
  }
}
