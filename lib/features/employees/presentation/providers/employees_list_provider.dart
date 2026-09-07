import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/usecases/get_employees.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_provider.dart';

class EmployeesListController extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() {
    return GetEmployees(ref.read(employeeRepositoryProvider))();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final employeesListProvider =
    AsyncNotifierProvider<EmployeesListController, List<Employee>>(
      EmployeesListController.new,
    );
