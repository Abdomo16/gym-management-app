import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_controller.dart';

import '../helpers/fake_employee_repository.dart';

void main() {
  test('successful invitation returns a pending invitation', () async {
    final repository = FakeEmployeeRepository();
    final container = ProviderContainer(
      overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final invitation = await container
        .read(employeesControllerProvider.notifier)
        .invite(
          fullName: 'Sara Ali',
          email: 'sara@gym.test',
          role: UserRole.receptionist,
          branchId: 'branch-1',
        );

    expect(invitation.status.name, 'pending');
    expect(
      container.read(employeesControllerProvider),
      EmployeeActionStatus.idle,
    );
  });

  test('concurrent employee mutations are rejected', () async {
    final gate = Completer<void>();
    final repository = FakeEmployeeRepository(mutationGate: gate);
    final container = ProviderContainer(
      overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(employeesControllerProvider.notifier);

    final first = controller.update(
      id: 'employee-1',
      fullName: 'Updated Name',
      role: UserRole.manager,
      branchId: 'branch-1',
    );
    await Future<void>.delayed(Duration.zero);

    await expectLater(
      controller.update(
        id: 'employee-1',
        fullName: 'Second Name',
        role: UserRole.manager,
        branchId: 'branch-1',
      ),
      throwsA(isA<StateError>()),
    );

    gate.complete();
    await first;
    expect(repository.updateCalls, 1);
    expect(
      container.read(employeesControllerProvider),
      EmployeeActionStatus.idle,
    );
  });
}
