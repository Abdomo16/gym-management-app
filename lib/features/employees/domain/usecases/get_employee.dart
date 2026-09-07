import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class GetEmployee {
  const GetEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<Employee?> call(String id) {
    return _repository.getEmployee(id);
  }
}
