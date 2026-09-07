import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

part 'employee_invitation.freezed.dart';

enum EmployeeInvitationStatus { pending, accepted, revoked, expired }

extension EmployeeInvitationStatusX on EmployeeInvitationStatus {
  static EmployeeInvitationStatus? fromWireName(String? value) {
    for (final status in EmployeeInvitationStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return null;
  }

  String get label {
    return switch (this) {
      EmployeeInvitationStatus.pending => 'Pending',
      EmployeeInvitationStatus.accepted => 'Accepted',
      EmployeeInvitationStatus.revoked => 'Revoked',
      EmployeeInvitationStatus.expired => 'Expired',
    };
  }
}

@freezed
abstract class EmployeeInvitation with _$EmployeeInvitation {
  const factory EmployeeInvitation({
    required String id,
    required String organizationId,
    String? branchId,
    required String fullName,
    required String email,
    required UserRole role,
    required String token,
    required EmployeeInvitationStatus status,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) = _EmployeeInvitation;
}
