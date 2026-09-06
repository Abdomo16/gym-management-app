import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/attendance/data/mappers/attendance_mapper.dart';

void main() {
  final base = <String, dynamic>{
    'id': 'attendance-1',
    'organization_id': 'org-1',
    'member_id': 'member-1',
    'branch_id': 'branch-1',
    'check_in_day': '2026-09-06',
    'checked_in_by': 'profile-1',
    'check_in_at': '2026-09-06T09:42:00.000Z',
  };

  test('maps attendance fields from the database row', () {
    final attendance = AttendanceMapper.fromMap(base);

    expect(attendance.id, 'attendance-1');
    expect(attendance.organizationId, 'org-1');
    expect(attendance.memberId, 'member-1');
    expect(attendance.branchId, 'branch-1');
    expect(attendance.checkInDay, DateTime(2026, 9, 6));
    expect(attendance.checkedInBy, 'profile-1');
    expect(attendance.checkInAt, DateTime.parse('2026-09-06T09:42:00.000Z'));
  });

  test('allows a missing optional branch', () {
    final attendance = AttendanceMapper.fromMap({
      ...base,
      'branch_id': null,
    });

    expect(attendance.branchId, isNull);
    expect(attendance.checkInAt, isNotNull);
  });

  test('rejects a row without a business day', () {
    expect(
      () => AttendanceMapper.fromMap({...base, 'check_in_day': null}),
      throwsA(isA<ValidationFailure>()),
    );
  });
}