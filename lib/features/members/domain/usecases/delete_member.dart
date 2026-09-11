import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Permanently deletes a member and all related records (subscriptions,
/// attendance, payments, notifications cascade server-side).
///
/// The database's RLS delete policy (owner/manager of the current
/// organization) remains the authority; failures surface as typed
/// [AppFailure]s.
class DeleteMember {
  const DeleteMember(this._repository);

  final MembersRepository _repository;

  Future<void> call(String memberId) {
    return _repository.deleteMember(memberId);
  }
}
