import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/repositories/attendance_repository.dart';

class CheckInMember {
  const CheckInMember(this._repository);

  final AttendanceRepository _repository;

  Future<Attendance> call({required String memberId}) {
    return _repository.checkIn(memberId: memberId);
  }
}
