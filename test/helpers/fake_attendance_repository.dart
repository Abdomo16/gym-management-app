import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/repositories/attendance_repository.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository({
    List<Attendance> attendance = const [],
    this.throwOnCheckIn = false,
    this.throwOnHistory = false,
  }) : _attendance = List<Attendance>.from(attendance);

  final List<Attendance> _attendance;
  bool throwOnCheckIn;
  bool throwOnHistory;

  List<Attendance> get records => List.unmodifiable(_attendance);

  @override
  Future<Attendance> checkIn({required String memberId}) async {
    if (throwOnCheckIn) {
      throw const SupabaseFailure(
        message: 'This member has already checked in today.',
        code: 'duplicate_attendance',
      );
    }
    final today = DateTime.now();
    final record = Attendance(
      id: 'attendance-${_attendance.length + 1}',
      organizationId: 'org-from-profile',
      memberId: memberId,
      branchId: 'branch-from-profile',
      checkedInBy: 'profile-1',
      checkInDay: DateTime(today.year, today.month, today.day),
      checkInAt: today,
    );
    _attendance.insert(0, record);
    return record;
  }

  @override
  Future<List<Attendance>> getMemberAttendance(
    String memberId, {
    int limit = 20,
  }) async {
    if (throwOnHistory) {
      throw const SupabaseFailure(message: 'Failed to load attendance.');
    }
    return _attendance.where((record) => record.memberId == memberId).take(limit).toList();
  }
}