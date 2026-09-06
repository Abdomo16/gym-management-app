import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

enum CheckInEligibilityReason {
  eligible,
  inactiveMember,
  blockedMember,
  noSubscription,
  subscriptionExpired,
  subscriptionFrozen,
  subscriptionCancelled,
  alreadyCheckedInToday,
}

extension CheckInEligibilityReasonX on CheckInEligibilityReason {
  String get label {
    return switch (this) {
      CheckInEligibilityReason.eligible => 'Eligible for Check-In',
      CheckInEligibilityReason.inactiveMember => 'Check-In Not Allowed',
      CheckInEligibilityReason.blockedMember => 'Check-In Not Allowed',
      CheckInEligibilityReason.noSubscription => 'Check-In Not Allowed',
      CheckInEligibilityReason.subscriptionExpired =>
        'Check-In Not Allowed',
      CheckInEligibilityReason.subscriptionFrozen => 'Check-In Not Allowed',
      CheckInEligibilityReason.subscriptionCancelled =>
        'Check-In Not Allowed',
      CheckInEligibilityReason.alreadyCheckedInToday =>
        'Already Checked In',
    };
  }

  String get message {
    return switch (this) {
      CheckInEligibilityReason.eligible =>
        'This member can check in today.',
      CheckInEligibilityReason.inactiveMember =>
        'Member is inactive.',
      CheckInEligibilityReason.blockedMember =>
        'Member is blocked.',
      CheckInEligibilityReason.noSubscription =>
        'No active subscription.',
      CheckInEligibilityReason.subscriptionExpired =>
        'Subscription expired.',
      CheckInEligibilityReason.subscriptionFrozen =>
        'Subscription is frozen.',
      CheckInEligibilityReason.subscriptionCancelled =>
        'Subscription is cancelled.',
      CheckInEligibilityReason.alreadyCheckedInToday =>
        'This member has already checked in today.',
    };
  }
}

class CheckInEligibility {
  const CheckInEligibility({
    required this.reason,
    this.attendanceToday,
  });

  final CheckInEligibilityReason reason;
  final Attendance? attendanceToday;

  bool get isEligible => reason == CheckInEligibilityReason.eligible;

  String get title => reason.label;

  String get message => reason.message;

  factory CheckInEligibility.evaluate({
    required Member member,
    required Subscription? subscription,
    required Attendance? attendanceToday,
  }) {
    if (!member.status.isActive) {
      return CheckInEligibility(
        reason: member.status.isBlocked
            ? CheckInEligibilityReason.blockedMember
            : CheckInEligibilityReason.inactiveMember,
        attendanceToday: attendanceToday,
      );
    }
    if (subscription == null) {
      return CheckInEligibility(
        reason: CheckInEligibilityReason.noSubscription,
        attendanceToday: attendanceToday,
      );
    }
    if (!subscription.isValid()) {
      final reason = switch (subscription.displayStatus) {
        SubscriptionStatus.frozen =>
          CheckInEligibilityReason.subscriptionFrozen,
        SubscriptionStatus.cancelled =>
          CheckInEligibilityReason.subscriptionCancelled,
        _ => CheckInEligibilityReason.subscriptionExpired,
      };
      return CheckInEligibility(
        reason: reason,
        attendanceToday: attendanceToday,
      );
    }
    if (attendanceToday != null) {
      return CheckInEligibility(
        reason: CheckInEligibilityReason.alreadyCheckedInToday,
        attendanceToday: attendanceToday,
      );
    }
    return const CheckInEligibility(
      reason: CheckInEligibilityReason.eligible,
    );
  }
}
