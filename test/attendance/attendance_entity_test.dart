import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';

void main() {
  final checkInDay = DateTime(2026, 9, 6);
  final checkedInAt = DateTime(2026, 9, 6, 9, 42);

  test('stores business day and check-in timestamp separately', () {
    final attendance = Attendance(
      id: 'attendance-1',
      organizationId: 'org-1',
      memberId: 'member-1',
      branchId: 'branch-1',
      checkedInBy: 'profile-1',
      checkInDay: checkInDay,
      checkInAt: checkedInAt,
    );

    expect(attendance.checkInDay, checkInDay);
    expect(attendance.checkInAt, checkedInAt);
    expect(attendance.branchId, 'branch-1');
  });

  test('supports value equality and copyWith', () {
    final attendance = Attendance(
      id: 'attendance-1',
      organizationId: 'org-1',
      memberId: 'member-1',
      checkedInBy: 'profile-1',
      checkInDay: checkInDay,
      checkInAt: checkedInAt,
    );

    expect(
      attendance,
      equals(
        Attendance(
          id: 'attendance-1',
          organizationId: 'org-1',
          memberId: 'member-1',
          checkedInBy: 'profile-1',
          checkInDay: checkInDay,
          checkInAt: checkedInAt,
        ),
      ),
    );
    expect(attendance.copyWith(branchId: 'branch-1').branchId, 'branch-1');
  });
}