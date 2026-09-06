import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/repositories/attendance_repository.dart';

class GetMemberAttendance {
  const GetMemberAttendance(this._repository);

  final AttendanceRepository _repository;

  Future<List<Attendance>> call(String memberId, {int limit = 20}) {
    return _repository.getMemberAttendance(memberId, limit: limit);
  }
}
