import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/create_member.dart';
import 'package:gym_management_app/features/members/domain/usecases/update_member.dart';
import 'package:gym_management_app/features/members/domain/usecases/update_member_status.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_search_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_list_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// Whether a member mutation (create/update/status) is in flight.
enum MemberActionStatus { idle, busy }

/// Performs member mutations and keeps related providers in sync.
///
/// Screens observe [status] to disable submit buttons and prevent duplicate
/// submissions; failures propagate to the caller as typed [AppFailure]s.
class MembersController extends Notifier<MemberActionStatus> {
  @override
  MemberActionStatus build() => MemberActionStatus.idle;

  Future<Member> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    return _run(() => CreateMember(ref.read(membersRepositoryProvider))(
      organizationId: organizationId,
      branchId: branchId,
      fullName: fullName,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
      notes: notes,
    ));
  }

  Future<Member> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    return _run(() => UpdateMember(ref.read(membersRepositoryProvider))(
      id: id,
      branchId: branchId,
      fullName: fullName,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
      notes: notes,
    ));
  }

  Future<Member> updateMemberStatus({
    required String id,
    required MemberStatus status,
  }) async {
    return _run(
      () => UpdateMemberStatus(ref.read(membersRepositoryProvider))(
        id: id,
        status: status,
      ),
    );
  }

  /// Runs [action] under the busy flag, refreshing the affected providers
  /// after a successful mutation.
  Future<Member> _run(Future<Member> Function() action) async {
    state = MemberActionStatus.busy;
    try {
      final member = await action();
      ref.invalidate(membersListProvider);
      ref.invalidate(memberSearchProvider);
      ref.invalidate(memberDetailsProvider(member.id));
      return member;
    } finally {
      state = MemberActionStatus.idle;
    }
  }
}

/// Tracks whether a member mutation is currently running.
final membersControllerProvider =
    NotifierProvider<MembersController, MemberActionStatus>(
      MembersController.new,
    );
