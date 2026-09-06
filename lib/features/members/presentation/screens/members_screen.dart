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
    required AsyncValue<List<Member>> listAsync,
    required AsyncValue<List<Member>> searchAsync,
    required bool isSearching,
    required VoidCallback onRetry,
  }) {
    // While the user is typing, show search results (or loading/error states)
    final activeAsync = isSearching ? searchAsync : listAsync;

    return activeAsync.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppErrorState(
        message: error is Exception
            ? error.toString().replaceFirst('Exception: ', '')
            : 'Something went wrong. Please try again.',
        onRetry: onRetry,
      ),
      data: (members) {
        if (members.isEmpty) {
          return isSearching
              ? MemberEmptyState.noSearchResults()
              : MemberEmptyState.noMembers(
                  onAdd: () => context.push(RoutePaths.membersCreate),
                );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(membersListProvider.notifier).refresh(),
          child: ListView.separated(
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
                onTap: () =>
                    context.push(RoutePaths.memberDetail(member.id)),
              );
            },
          ),
        );
      },
    );
  }
}
