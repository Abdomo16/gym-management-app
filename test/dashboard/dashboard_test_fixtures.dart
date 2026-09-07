import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_expiring_subscription.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_recent_check_in.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

DashboardSnapshot makeDashboardSnapshot({
  int totalMembers = 10,
  int activeMembers = 8,
  int activeSubscriptions = 7,
  int expiringSoonSubscriptions = 2,
  int expiredSubscriptions = 1,
  int todayCheckIns = 4,
  List<DashboardRecentCheckIn> recentCheckIns = const [],
  List<DashboardExpiringSubscription> expiringSubscriptions = const [],
}) {
  return DashboardSnapshot(
    summary: DashboardSummary(
      totalMembers: totalMembers,
      activeMembers: activeMembers,
      activeSubscriptions: activeSubscriptions,
      expiringSoonSubscriptions: expiringSoonSubscriptions,
      expiredSubscriptions: expiredSubscriptions,
      todayCheckIns: todayCheckIns,
    ),
    businessDate: DateTime(2026, 9, 7),
    recentCheckIns: recentCheckIns,
    expiringSubscriptions: expiringSubscriptions,
  );
}

DashboardRecentCheckIn makeRecentCheckIn({
  String memberId = 'member-1',
  String memberName = 'Ahmed Mohamed',
}) {
  return DashboardRecentCheckIn(
    attendance: Attendance(
      id: 'attendance-1',
      organizationId: 'org-1',
      memberId: memberId,
      branchId: 'branch-1',
      checkedInBy: 'staff-1',
      checkInDay: DateTime(2026, 9, 7),
      checkInAt: DateTime(2026, 9, 7, 9, 42),
    ),
    memberName: memberName,
    memberCode: 'GYM-000001',
  );
}

DashboardExpiringSubscription makeExpiringSubscription() {
  return DashboardExpiringSubscription(
    subscription: Subscription(
      id: 'subscription-1',
      organizationId: 'org-1',
      memberId: 'member-1',
      planId: 'plan-1',
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 9, 10),
      status: SubscriptionStatus.expiring,
    ),
    memberName: 'Ahmed Mohamed',
    memberCode: 'GYM-000001',
    planName: 'Monthly',
    remainingDays: 3,
  );
}
