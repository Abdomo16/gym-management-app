import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/usecases/check_in_member.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/check_in_eligibility_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/member_attendance_provider.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';

enum CheckInActionStatus { idle, busy }

class CheckInController extends Notifier<CheckInActionStatus> {
  @override
  CheckInActionStatus build() => CheckInActionStatus.idle;

  Future<Attendance> checkIn(Member member) async {
    if (state == CheckInActionStatus.busy) {
      throw const ValidationFailure(
        message: 'A check-in is already in progress.',
      );
    }
    if (ref.read(organizationContextProvider) == null) {
      throw const AuthFailure(
        message: 'Your session is no longer active. Please sign in again.',
      );
    }
    state = CheckInActionStatus.busy;
    try {
      final attendance = await CheckInMember(
        ref.read(attendanceRepositoryProvider),
      )(memberId: member.id);
      ref.invalidate(memberAttendanceProvider(member.id));
      ref.invalidate(checkInEligibilityProvider(member.id));
      ref.invalidate(memberDetailsProvider(member.id));
      return attendance;
    } finally {
      state = CheckInActionStatus.idle;
    }
  }
}

final checkInControllerProvider =
    NotifierProvider<CheckInController, CheckInActionStatus>(
      CheckInController.new,
    );