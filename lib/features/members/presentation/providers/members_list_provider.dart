import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_members.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// State of the "load more" flow at the bottom of the member list.
enum MembersLoadMoreStatus { idle, loading, error, exhausted }

/// One snapshot of the member list: the members loaded so far plus the
/// state of pagination at the bottom of that list.
class MembersListPage {
  const MembersListPage({
    required this.members,
    this.loadMoreStatus = MembersLoadMoreStatus.idle,
  });

  final List<Member> members;
  final MembersLoadMoreStatus loadMoreStatus;

  bool get hasMore => loadMoreStatus != MembersLoadMoreStatus.exhausted;
}

/// Drives the member list page.
///
/// Exposes the standard async states (loading / data / empty / error), a
/// [refresh] action, and [loadMore] pagination: pages are appended as the
/// user scrolls until a shorter-than-page-size page signals the end.
class MembersListController extends AsyncNotifier<MembersListPage> {
  static const int pageSize = 50;

  bool _isLoadingMore = false;

  @override
  Future<MembersListPage> build() async {
    final page = await GetMembers(ref.read(membersRepositoryProvider))(
      limit: pageSize,
    );
    final hasMore = page.length == pageSize;
    return MembersListPage(
      members: page,
      loadMoreStatus: hasMore
          ? MembersLoadMoreStatus.idle
          : MembersLoadMoreStatus.exhausted,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Appends the next page to the current list. No-op while a page is
  /// already in flight or the end of the list has been reached.
  Future<void> loadMore() async {
    final current = state.value;
    if (_isLoadingMore || current == null || !current.hasMore) return;
    _isLoadingMore = true;
    state = AsyncData(
      MembersListPage(
        members: current.members,
        loadMoreStatus: MembersLoadMoreStatus.loading,
      ),
    );
    try {
      final next = await GetMembers(ref.read(membersRepositoryProvider))(
        limit: pageSize,
        offset: current.members.length,
      );
      final hasMore = next.length == pageSize;
      state = AsyncData(
        MembersListPage(
          members: [...current.members, ...next],
          loadMoreStatus: hasMore
              ? MembersLoadMoreStatus.idle
              : MembersLoadMoreStatus.exhausted,
        ),
      );
    } catch (_) {
      // Keep the already-loaded list visible; the footer offers a retry.
      state = AsyncData(
        MembersListPage(
          members: current.members,
          loadMoreStatus: MembersLoadMoreStatus.error,
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// The member list for the current organization.
final membersListProvider =
    AsyncNotifierProvider<MembersListController, MembersListPage>(
      MembersListController.new,
    );
