import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/data/mappers/employee_invitation_mapper.dart';
import 'package:gym_management_app/features/employees/data/mappers/employee_mapper.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';

void main() {
  test('maps employee profile and branch fields', () {
    final employee = EmployeeMapper.fromMap({
      'id': 'employee-1',
      'organization_id': 'org-1',
      'branch_id': 'branch-1',
      'branch_name': 'Main Branch',
      'full_name': 'Sara Ali',
      'phone': '01012345678',
      'role': 'manager',
      'is_active': false,
      'created_at': '2026-01-01T10:00:00Z',
      'updated_at': '2026-01-02T10:00:00Z',
    });

    expect(employee.role, UserRole.manager);
    expect(employee.branchName, 'Main Branch');
    expect(employee.isActive, isFalse);
    expect(employee.createdAt, DateTime.parse('2026-01-01T10:00:00Z'));
  });

  test('maps invitation role and status', () {
    final invitation = EmployeeInvitationMapper.fromMap({
      'id': 'invitation-1',
      'organization_id': 'org-1',
      'branch_id': 'branch-1',
      'full_name': 'Sara Ali',
      'email': 'sara@gym.test',
      'role': 'receptionist',
      'token': 'token-1',
      'status': 'pending',
      'expires_at': '2026-01-08T10:00:00Z',
    });

    expect(invitation.role, UserRole.receptionist);
    expect(invitation.status, EmployeeInvitationStatus.pending);
    expect(invitation.email, 'sara@gym.test');
  });
}
