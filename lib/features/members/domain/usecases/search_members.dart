import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Searches members by name, phone or member code.
class SearchMembers {
  const SearchMembers(this._repository);

  final MembersRepository _repository;

  Future<List<Member>> call(String query, {int limit = 20}) {
    return _repository.searchMembers(query, limit: limit);
  }
}
