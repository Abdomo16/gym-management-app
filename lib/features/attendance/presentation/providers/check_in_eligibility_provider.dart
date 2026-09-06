import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/attendance/domain/entities/check_in_eligibility.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/member_attendance_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/member_subscriptions_provider.dart';

final checkInEligibilityProvider =
    FutureProvider.family.autoDispose<CheckInEligibility, String>((
      ref,
      memberId,
    ) async {
      final member = await ref.watch(memberDetailsProvider(memberId).future);
      final subscriptions = await ref.watch(
        memberSubscriptionsProvider(memberId).future,
      );
      final attendance = await ref.watch(
        memberAttendanceProvider(memberId).future,
      );

      final attendanceToday = attendance
          .where((record) => _isSameCalendarDay(record.checkInDay))
          .firstOrNull;

      return CheckInEligibility.evaluate(
        member: member,
        subscription: subscriptions.firstOrNull,
        attendanceToday: attendanceToday,
      );
    });

bool _isSameCalendarDay(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}