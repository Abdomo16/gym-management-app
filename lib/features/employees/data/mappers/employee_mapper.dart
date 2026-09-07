import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';

abstract final class EmployeeMapper {
  static Employee fromMap(Map<String, dynamic> map) {
    final role = UserRoleX.fromWireName(map['role'] as String?);
    if (role == null) {
      throw const ValidationFailure(
        message: 'An employee has an unsupported role.',
      );
    }
    final branch = map['branch'] as Map<String, dynamic>?;
    return Employee(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      branchId: map['branch_id'] as String?,
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String?,
      role: role,
      branchName: map['branch_name'] as String? ?? branch?['name'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
