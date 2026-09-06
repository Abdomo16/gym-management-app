import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';

abstract final class AttendanceMapper {
  static Attendance fromMap(Map<String, dynamic> map) {
    final checkInDay = _parseDate(map['check_in_day']);
    if (checkInDay == null) {
      throw const ValidationFailure(
        message: 'An attendance record is missing its business day.',
      );
    }

    return Attendance(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      memberId: map['member_id'] as String,
      branchId: map['branch_id'] as String?,
      checkedInBy: map['checked_in_by'] as String,
      checkInDay: checkInDay,
      checkInAt: _parseDateTime(map['check_in_at']) ??
          (throw const ValidationFailure(
            message: 'An attendance record is missing its check-in time.',
          )),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}