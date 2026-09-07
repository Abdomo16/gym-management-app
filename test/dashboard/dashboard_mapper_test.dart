import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:gym_management_app/features/dashboard/data/mappers/dashboard_mapper.dart';

void main() {
  test('maps dashboard counts and operational lists', () {
    final snapshot = DashboardMapper.fromRemoteData(
      DashboardRemoteData(
        summary: {
          'total_members': 100,
          'active_members': 80,
          'active_subscriptions': 72,
          'expiring_soon_subscriptions': 5,
          'expired_subscriptions': 12,
          'today_check_ins': 25,
        },
        businessDate: DateTime(2026, 9, 7),
        recentCheckIns: [
          {
            'id': 'attendance-1',
            'organization_id': 'org-1',
            'member_id': 'member-1',
            'branch_id': 'branch-1',
            'checked_in_by': 'staff-1',
            'check_in_at': '2026-09-07T09:42:00Z',
            'check_in_day': '2026-09-07',
            'member_name': 'Ahmed Mohamed',
            'member_code': 'GYM-000001',
          },
        ],
        expiringSubscriptions: [
          {
            'id': 'subscription-1',
            'organization_id': 'org-1',
            'member_id': 'member-1',
            'plan_id': 'plan-1',
            'start_date': '2026-08-01',
            'end_date': '2026-09-10',
            'price': 500,
            'status': 'expiring',
            'member_name': 'Ahmed Mohamed',
            'member_code': 'GYM-000001',
            'plan_name': 'Monthly',
          },
        ],
      ),
    );

    expect(snapshot.summary.totalMembers, 100);
    expect(snapshot.summary.todayCheckIns, 25);
    expect(snapshot.recentCheckIns.single.memberName, 'Ahmed Mohamed');
    expect(snapshot.expiringSubscriptions.single.planName, 'Monthly');
    expect(snapshot.expiringSubscriptions.single.remainingDays, 3);
  });

  test('defaults missing summary values to zero', () {
    final snapshot = DashboardMapper.fromRemoteData(
      DashboardRemoteData(
        summary: const {},
        businessDate: DateTime(2026, 9, 7),
        recentCheckIns: const [],
        expiringSubscriptions: const [],
      ),
    );

    expect(snapshot.summary.totalMembers, 0);
    expect(snapshot.summary.expiredSubscriptions, 0);
  });
}
