import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Creates a member.
///
/// [organizationId] must come from the authenticated tenant context, never
/// from user input. The database generates the member code server-side.
class CreateMember {
  const CreateMember(this._repository);

  final MembersRepository _repository;

  Future<Member> call({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) {
    return _repository.createMember(
      organizationId: organizationId,
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
