import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class GetEmployees {
  const GetEmployees(this._repository);

  final EmployeeRepository _repository;

  Future<List<Employee>> call({int limit = 100}) {
    return _repository.getEmployees(limit: limit);
  }
}
