import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';
import 'package:gym_management_app/features/employees/domain/usecases/invite_employee.dart';
import 'package:gym_management_app/features/employees/domain/usecases/set_employee_active.dart';
import 'package:gym_management_app/features/employees/domain/usecases/update_employee.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_details_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_list_provider.dart';

enum EmployeeActionStatus { idle, busy }

class EmployeesController extends Notifier<EmployeeActionStatus> {
  @override
  EmployeeActionStatus build() => EmployeeActionStatus.idle;

  Future<EmployeeInvitation> invite({
    required String fullName,
    required String email,
    required UserRole role,
    String? branchId,
  }) {
    return _run(
      () => InviteEmployee(ref.read(employeeRepositoryProvider))(
        fullName: fullName,
        email: email,
        role: role,
        branchId: branchId,
      ),
    );
  }

  Future<Employee> update({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) {
    return _run(
      () => UpdateEmployee(ref.read(employeeRepositoryProvider))(
        id: id,
        fullName: fullName,
        phone: phone,
        role: role,
        branchId: branchId,
      ),
      employeeId: id,
    );
  }

  Future<Employee> setActive({required String id, required bool isActive}) {
    return _run(
      () => SetEmployeeActive(ref.read(employeeRepositoryProvider))(
        id: id,
        isActive: isActive,
      ),
      employeeId: id,
    );
  }

  Future<T> _run<T>(Future<T> Function() action, {String? employeeId}) async {
    if (state == EmployeeActionStatus.busy) {
      throw StateError('An employee action is already in progress.');
    }
    state = EmployeeActionStatus.busy;
    try {
      final result = await action();
      ref.invalidate(employeesListProvider);
      if (employeeId != null) {
        ref.invalidate(employeeDetailsProvider(employeeId));
      }
      return result;
    } finally {
      state = EmployeeActionStatus.idle;
    }
  }
}

final employeesControllerProvider =
    NotifierProvider<EmployeesController, EmployeeActionStatus>(
      EmployeesController.new,
    );
