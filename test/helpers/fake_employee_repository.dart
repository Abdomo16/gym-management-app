import 'dart:async';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository({
    List<Employee> employees = const [],
    this.listError,
    this.inviteError,
    this.updateError,
    this.activeError,
    this.mutationGate,
  }) : _employees = List<Employee>.from(employees);

  final List<Employee> _employees;
  final AppFailure? listError;
  final AppFailure? inviteError;
  final AppFailure? updateError;
  final AppFailure? activeError;
  final Completer<void>? mutationGate;
  int updateCalls = 0;

  static Employee makeEmployee({
    String id = 'employee-1',
    String fullName = 'Sara Ali',
    UserRole role = UserRole.receptionist,
    bool isActive = true,
  }) {
    return Employee(
      id: id,
      organizationId: 'org-1',
      branchId: 'branch-1',
      branchName: 'Main Branch',
      fullName: fullName,
      phone: '01012345678',
      role: role,
      isActive: isActive,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<List<Employee>> getEmployees({int limit = 100}) async {
    final error = listError;
    if (error != null) throw error;
    return _employees.take(limit).toList();
  }

  @override
  Future<Employee?> getEmployee(String id) async {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<EmployeeInvitation> inviteEmployee({
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) async {
    final error = inviteError;
    if (error != null) throw error;
    return EmployeeInvitation(token: 'token-1');
  }

  @override
  Future<Employee> updateEmployee({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) async {
    updateCalls++;
    final gate = mutationGate;
    if (gate != null) await gate.future;
    final error = updateError;
    if (error != null) throw error;
    final current = await getEmployee(id) ?? makeEmployee(id: id);
    return current.copyWith(
      fullName: fullName,
      phone: phone,
      role: role,
      branchId: branchId,
    );
  }

  @override
  Future<Employee> setEmployeeActive({
    required String id,
    required bool isActive,
  }) async {
    final error = activeError;
    if (error != null) throw error;
    final current = await getEmployee(id) ?? makeEmployee(id: id);
    return current.copyWith(isActive: isActive);
  }
}
