import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_members.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// Drives the member list page.
///
/// Exposes the standard async states (loading / data / empty / error) and a
/// [refresh] action so the list can be reloaded after mutations elsewhere.
class MembersListController extends AsyncNotifier<List<Member>> {
  static const int _pageSize = 50;

  @override
  Future<List<Member>> build() {
    return GetMembers(ref.read(membersRepositoryProvider))(
      limit: _pageSize,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// The member list for the current organization.
final membersListProvider =
    AsyncNotifierProvider<MembersListController, List<Member>>(
      MembersListController.new,
    );
