import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_search_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_list_provider.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_empty_state.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_list_item.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_search_bar.dart';

/// Main members list screen with integrated search.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(membersListProvider);
    final searchAsync = ref.watch(memberSearchProvider);
    final searchController = ref.read(memberSearchProvider.notifier);

    // Whether the user has typed something into the search bar.
    final isSearching = searchAsync.when(
      data: (data) => data.isNotEmpty,
      loading: () => true,
      error: (e, _) => false,
    );

    return Scaffold(
      body: Column(
        children: [
          // Header toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: MemberSearchBar(
                    onChanged: searchController.onQueryChanged,
                    onClear: searchController.clear,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Add Member',
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(RoutePaths.membersCreate),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: _buildContent(
              context,
              ref,
              listAsync: listAsync,
              searchAsync: searchAsync,
              isSearching: isSearching,
              onRetry: () => ref.invalidate(membersListProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<MembersListPage> listAsync,
    required AsyncValue<List<Member>> searchAsync,
    required bool isSearching,
    required VoidCallback onRetry,
  }) {
    Widget listContent() {
      return listAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) =>
            AppErrorState(message: _errorMessage(error), onRetry: onRetry),
        data: (page) {
          final members = page.members;
          if (members.isEmpty) {
            return MemberEmptyState.noMembers(
              onAdd: () => context.push(RoutePaths.membersCreate),
            );
          }
          final loadMoreStatus = page.loadMoreStatus;
          final showFooter =
              loadMoreStatus == MembersLoadMoreStatus.loading ||
              loadMoreStatus == MembersLoadMoreStatus.error;
          return RefreshIndicator(
            onRefresh: () => ref.read(membersListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: members.length + (showFooter ? 1 : 0),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                if (index >= members.length) {
                  return _LoadMoreFooter(
                    status: loadMoreStatus,
                    onRetry: () =>
                        ref.read(membersListProvider.notifier).loadMore(),
                  );
                }
                // Near the bottom of the list, queue the next page.
                if (index >= members.length - 10) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(membersListProvider.notifier).loadMore();
                  });
                }
                final member = members[index];
                return MemberListItem(
                  member: member,
                  onTap: () => context.push(RoutePaths.memberDetail(member.id)),
                );
              },
            ),
          );
        },
      );
    }

    Widget searchContent() {
      return searchAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) =>
            AppErrorState(message: _errorMessage(error), onRetry: onRetry),
        data: (members) {
          if (members.isEmpty) {
            return MemberEmptyState.noSearchResults();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
            ),
            itemBuilder: (context, index) {
              final member = members[index];
              return MemberListItem(
                member: member,
                onTap: () => context.push(RoutePaths.memberDetail(member.id)),
              );
            },
          );
        },
      );
    }

    // While the user is typing, show search results over the full list.
    return isSearching ? searchContent() : listContent();
  }

  static String _errorMessage(Object error) => error is Exception
      ? error.toString().replaceFirst('Exception: ', '')
      : 'Something went wrong. Please try again.';
}

/// Bottom-of-list pagination footer: a spinner while the next page loads
/// or a retry row when loading it failed.
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.status, required this.onRetry});

  final MembersLoadMoreStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: status == MembersLoadMoreStatus.error
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Could not load more members.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              )
            : const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
      ),
    );
  }
}
