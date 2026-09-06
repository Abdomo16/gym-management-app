import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Loads a single member by id, or `null` when not found.
class GetMember {
  const GetMember(this._repository);

  final MembersRepository _repository;

  Future<Member?> call(String id) {
    return _repository.getMemberById(id);
  }
}
