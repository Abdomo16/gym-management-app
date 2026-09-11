import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Loads one page of members for the current organization.
class GetMembers {
  const GetMembers(this._repository);

  final MembersRepository _repository;

  Future<List<Member>> call({int limit = 50, int offset = 0}) {
    return _repository.getMembers(limit: limit, offset: offset);
  }
}
