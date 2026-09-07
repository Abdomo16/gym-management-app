import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';

abstract final class EmployeeInvitationMapper {
  static EmployeeInvitation fromMap(Map<String, dynamic> map) {
    final role = UserRoleX.fromWireName(map['role'] as String?);
    final status = EmployeeInvitationStatusX.fromWireName(
      map['status'] as String?,
    );
    if (role == null || role == UserRole.owner) {
      throw const ValidationFailure(
        message: 'The invitation has an unsupported employee role.',
      );
    }
    if (status == null) {
      throw const ValidationFailure(
        message: 'The invitation has an unsupported status.',
      );
    }
    return EmployeeInvitation(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      branchId: map['branch_id'] as String?,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: role,
      token: map['token'] as String,
      status: status,
      expiresAt: _parseDate(map['expires_at']),
      createdAt: _parseDate(map['created_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
