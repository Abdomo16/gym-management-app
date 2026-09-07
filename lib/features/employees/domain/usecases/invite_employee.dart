import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

class InviteEmployee {
  const InviteEmployee(this._repository);

  final EmployeeRepository _repository;

  Future<EmployeeInvitation> call({
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchId,
  }) {
    return _repository.inviteEmployee(
      fullName: fullName,
      phone: phone,
      role: role,
      branchId: branchId,
    );
  }
}
