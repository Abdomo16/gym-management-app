import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_invitation.freezed.dart';

@freezed
abstract class EmployeeInvitation with _$EmployeeInvitation {
  const factory EmployeeInvitation({required String token}) =
      _EmployeeInvitation;
}
