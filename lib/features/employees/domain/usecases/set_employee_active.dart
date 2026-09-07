import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class SetEmployeeActive {
  const SetEmployeeActive(this._repository);

  final EmployeeRepository _repository;

  Future<Employee> call({required String id, required bool isActive}) {
    return _repository.setEmployeeActive(id: id, isActive: isActive);
  }
}
