import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/usecases/get_member_attendance.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/attendance_provider.dart';

final memberAttendanceProvider =
    FutureProvider.family.autoDispose<List<Attendance>, String>((
      ref,
      memberId,
    ) {
      return GetMemberAttendance(ref.read(attendanceRepositoryProvider))(
        memberId,
      );
    });