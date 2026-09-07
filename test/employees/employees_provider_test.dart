import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/employees/domain/usecases/get_employees.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_list_provider.dart';

import '../helpers/fake_employee_repository.dart';

ProviderContainer makeContainer(FakeEmployeeRepository repository) {
  final container = ProviderContainer(
    overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('employee list loads successfully', () async {
    final container = makeContainer(
      FakeEmployeeRepository(
        employees: [FakeEmployeeRepository.makeEmployee()],
      ),
    );

    final employees = await container.read(employeesListProvider.future);

    expect(employees, hasLength(1));
    expect(employees.single.fullName, 'Sara Ali');
  });

  test('employee list exposes repository errors', () async {
    final repository = FakeEmployeeRepository(
      listError: const SupabaseFailure(message: 'Unable to load employees.'),
    );

    await expectLater(
      GetEmployees(repository)(),
      throwsA(
        isA<SupabaseFailure>().having(
          (failure) => failure.message,
          'message',
          'Unable to load employees.',
        ),
      ),
    );
  });

  test('employee list supports a legitimate empty state', () async {
    final container = makeContainer(FakeEmployeeRepository());

    final employees = await container.read(employeesListProvider.future);

    expect(employees, isEmpty);
  });
}
