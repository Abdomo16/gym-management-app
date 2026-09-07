import 'package:gym_management_app/features/employees/domain/entities/employee_invitation.dart';

abstract final class EmployeeInvitationMapper {
  static EmployeeInvitation fromToken(String token) {
    return EmployeeInvitation(token: token);
  }
}
