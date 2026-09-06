import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/entities/check_in_eligibility.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

void main() {
  final now = DateTime(2026, 9, 6, 10);
  final activeMember = Member(
    id: 'member-1',
    organizationId: 'org-1',
    fullName: 'Ahmed Mohamed',
    phone: '01012345678',
  );
  final activeSubscription = Subscription(
    id: 'sub-1',
    organizationId: 'org-1',
    memberId: 'member-1',
    planId: 'plan-1',
    startDate: DateTime(2020, 1, 1),
    endDate: DateTime.now().add(const Duration(days: 30)),
    status: SubscriptionStatus.active,
  );

  CheckInEligibility evaluate({
    Member? member,
    Subscription? subscription,
    bool noSubscription = false,
    Attendance? attendanceToday,
  }) {
    return CheckInEligibility.evaluate(
      member: member ?? activeMember,
      subscription: noSubscription ? null : subscription ?? activeSubscription,
      attendanceToday: attendanceToday,
    );
  }

  test('active member with valid subscription is eligible', () {
    expect(evaluate().reason, CheckInEligibilityReason.eligible);
    expect(evaluate().isEligible, isTrue);
  });

  test('inactive and blocked members are blocked before subscription checks', () {
    expect(
      evaluate(member: activeMember.copyWith(status: MemberStatus.inactive))
          .reason,
      CheckInEligibilityReason.inactiveMember,
    );
    expect(
      evaluate(member: activeMember.copyWith(status: MemberStatus.blocked)).reason,
      CheckInEligibilityReason.blockedMember,
    );
  });

  test('missing and expired subscriptions are blocked', () {
    expect(
      evaluate(noSubscription: true).reason,
      CheckInEligibilityReason.noSubscription,
    );
    expect(
      evaluate(
        subscription: activeSubscription.copyWith(
          endDate: DateTime(2026, 9, 5),
        ),
      ).reason,
      CheckInEligibilityReason.subscriptionExpired,
    );
  });

  test('frozen and cancelled subscriptions are blocked with their reasons', () {
    expect(
      evaluate(
        subscription: activeSubscription.copyWith(
          status: SubscriptionStatus.frozen,
        ),
      ).reason,
      CheckInEligibilityReason.subscriptionFrozen,
    );
    expect(
      evaluate(
        subscription: activeSubscription.copyWith(
          status: SubscriptionStatus.cancelled,
        ),
      ).reason,
      CheckInEligibilityReason.subscriptionCancelled,
    );
  });

  test('an attendance record for today blocks a second check-in', () {
    final existing = Attendance(
      id: 'attendance-1',
      organizationId: 'org-1',
      memberId: 'member-1',
      checkInDay: DateTime(now.year, now.month, now.day),
      checkedInBy: 'profile-1',
      checkInAt: now,
    );

    final result = evaluate(attendanceToday: existing);

    expect(result.reason, CheckInEligibilityReason.alreadyCheckedInToday);
    expect(result.attendanceToday, existing);
  });
}