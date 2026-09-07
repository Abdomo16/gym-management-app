import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class UpdateEmployee {
  const UpdateEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<Employee> call({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) {
    return _repository.updateEmployee(
      id: id,
      fullName: fullName,
      phone: phone,
      role: role,
      branchId: branchId,
    );
  }
}
