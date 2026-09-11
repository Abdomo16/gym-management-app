import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_members.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// State of the "load more" flow at the bottom of the member list.
enum MembersLoadMoreStatus { idle, loading, error, exhausted }

/// Drives the member list page.
///
/// Exposes the standard async states (loading / data / empty / error), a
/// [refresh] action, and [loadMore] pagination: pages are appended as the
/// user scrolls until a shorter-than-page-size page signals the end.
class MembersListController extends AsyncNotifier<List<Member>> {
  static const int pageSize = 50;

  bool _hasMore = false;
  bool _isLoadingMore = false;

  @override
  Future<List<Member>> build() async {
    ref.read(membersListLoadMoreProvider.notifier).update(
          MembersLoadMoreStatus.idle,
        );
    final page = await GetMembers(ref.read(membersRepositoryProvider))(
      limit: pageSize,
    );
    _hasMore = page.length == pageSize;
    return page;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  /// Appends the next page to the current list. No-op while a page is
  /// already in flight or the end of the list has been reached.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    final loadMoreState = ref.read(membersListLoadMoreProvider.notifier);
    loadMoreState.update(MembersLoadMoreStatus.loading);
    try {
      final current = state.value ?? const <Member>[];
      final next = await GetMembers(ref.read(membersRepositoryProvider))(
        limit: pageSize,
        offset: current.length,
      );
      _hasMore = next.length == pageSize;
      loadMoreState.update(
        _hasMore ? MembersLoadMoreStatus.idle : MembersLoadMoreStatus.exhausted,
      );
      state = AsyncData([...current, ...next]);
    } catch (_) {
      // Keep the already-loaded list visible; the footer offers a retry.
      loadMoreState.update(MembersLoadMoreStatus.error);
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// The member list for the current organization.
final membersListProvider =
    AsyncNotifierProvider<MembersListController, List<Member>>(
      MembersListController.new,
    );

/// Holds the bottom-of-list pagination state for the members screen.
class MembersLoadMoreController extends Notifier<MembersLoadMoreStatus> {
  @override
  MembersLoadMoreStatus build() => MembersLoadMoreStatus.idle;

  void update(MembersLoadMoreStatus status) => state = status;
}

/// Tracks the bottom-of-list pagination state for the members screen.
final membersListLoadMoreProvider =
    NotifierProvider<MembersLoadMoreController, MembersLoadMoreStatus>(
      MembersLoadMoreController.new,
    );
