import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:gym_management_app/features/attendance/data/mappers/attendance_mapper.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';
import 'package:gym_management_app/features/attendance/domain/repositories/attendance_repository.dart';

class SupabaseAttendanceRepository implements AttendanceRepository {
  SupabaseAttendanceRepository(this._dataSource);

  final AttendanceRemoteDataSource _dataSource;

  @override
  Future<Attendance> checkIn({required String memberId}) async {
    try {
      final row = await _dataSource.checkIn(memberId: memberId);
      return AttendanceMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<List<Attendance>> getMemberAttendance(
    String memberId, {
    int limit = 20,
  }) async {
    try {
      final rows = await _dataSource.getMemberAttendance(
        memberId,
        limit: limit,
      );
      return rows.map(AttendanceMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}