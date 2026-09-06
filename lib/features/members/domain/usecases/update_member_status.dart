import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Changes a member's status (active/inactive/blocked).
class UpdateMemberStatus {
  const UpdateMemberStatus(this._repository);

  final MembersRepository _repository;

  Future<Member> call({required String id, required MemberStatus status}) {
    return _repository.updateMemberStatus(id: id, status: status);
  }
}
