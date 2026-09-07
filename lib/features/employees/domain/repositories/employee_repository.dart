import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';

abstract interface class EmployeeRepository {
  Future<List<Employee>> getEmployees({int limit = 100});

  Future<Employee?> getEmployee(String id);

  Future<EmployeeInvitation> inviteEmployee({
    required String fullName,
    required String email,
    required UserRole role,
    String? branchId,
  });

  Future<Employee> updateEmployee({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  });

  Future<Employee> setEmployeeActive({
    required String id,
    required bool isActive,
  });
}
