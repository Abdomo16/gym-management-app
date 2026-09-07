import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/data/datasources/employee_remote_datasource.dart';
import 'package:gym_management_app/features/employees/data/mappers/employee_invitation_mapper.dart';
import 'package:gym_management_app/features/employees/data/mappers/employee_mapper.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class SupabaseEmployeeRepository implements EmployeeRepository {
  SupabaseEmployeeRepository(this._dataSource);

  final EmployeeRemoteDataSource _dataSource;

  @override
  Future<List<Employee>> getEmployees({int limit = 100}) async {
    try {
      final rows = await _dataSource.getEmployees(limit: limit);
      return rows.map(EmployeeMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Employee?> getEmployee(String id) async {
    try {
      final row = await _dataSource.getEmployee(id);
      return row == null ? null : EmployeeMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<EmployeeInvitation> inviteEmployee({
    required String fullName,
    required String email,
    required UserRole role,
    String? branchId,
  }) async {
    try {
      final row = await _dataSource.inviteEmployee(
        fullName: fullName,
        email: email,
        role: role,
        branchId: branchId,
      );
      return EmployeeInvitationMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Employee> updateEmployee({
    required String id,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) async {
    try {
      final row = await _dataSource.updateEmployee(
        id: id,
        fullName: fullName,
        phone: phone,
        role: role,
        branchId: branchId,
      );
      return EmployeeMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Employee> setEmployeeActive({
    required String id,
    required bool isActive,
  }) async {
    try {
      final row = await _dataSource.setEmployeeActive(
        id: id,
        isActive: isActive,
      );
      return EmployeeMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
