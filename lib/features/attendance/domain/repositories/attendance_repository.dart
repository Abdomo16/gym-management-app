import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';

abstract interface class AttendanceRepository {
  Future<Attendance> checkIn({required String memberId});

  Future<List<Attendance>> getMemberAttendance(
    String memberId, {
    int limit = 20,
  });
}
