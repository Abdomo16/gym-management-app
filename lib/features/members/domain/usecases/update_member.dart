import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Updates mutable member fields. `member_code` and `organization_id` are
/// never editable.
class UpdateMember {
  const UpdateMember(this._repository);

  final MembersRepository _repository;

  Future<Member> call({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) {
    return _repository.updateMember(
      id: id,
      branchId: branchId,
      fullName: fullName,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
      notes: notes,
    );
  }
}
