import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

part 'employee.freezed.dart';

@freezed
abstract class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String organizationId,
    String? branchId,
    required String fullName,
    String? phone,
    required UserRole role,
    String? branchName,
    String? email,
    String? avatarUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Employee;
}
