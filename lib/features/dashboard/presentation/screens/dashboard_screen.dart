import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/dashboard_expiring_list.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/dashboard_recent_check_ins.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/dashboard_section.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    final displayName = user?.fullName ?? user?.email ?? 'there';

    return dashboard.when(
      loading: () => const AppLoading(label: 'Loading dashboard...'),
      error: (_, _) => AppErrorState(
        message: 'Unable to load dashboard.',
        onRetry: () => ref.invalidate(dashboardProvider),
      ),
      data: (snapshot) => _DashboardContent(
        snapshot: snapshot,
        greeting: '$greeting, $displayName',
        onRefresh: () => ref.invalidate(dashboardProvider),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.snapshot,
    required this.greeting,
    required this.onRefresh,
  });

  final DashboardSnapshot snapshot;
  final String greeting;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = snapshot.summary;
    final stats = [
      (
        label: 'Total members',
        value: summary.totalMembers,
        icon: Icons.group_outlined,
        path: RoutePaths.members,
      ),
      (
        label: 'Active members',
        value: summary.activeMembers,
        icon: Icons.verified_user_outlined,
        path: RoutePaths.members,
      ),
      (
        label: 'Active subscriptions',
        value: summary.activeSubscriptions,
        icon: Icons.card_membership_outlined,
        path: RoutePaths.subscriptions,
      ),
      (
        label: "Today's check-ins",
        value: summary.todayCheckIns,
        icon: Icons.login_rounded,
        path: RoutePaths.checkIn,
      ),
      (
        label: 'Expiring soon',
        value: summary.expiringSoonSubscriptions,
        icon: Icons.schedule_outlined,
        path: RoutePaths.members,
      ),
      (
        label: 'Expired subscriptions',
        value: summary.expiredSubscriptions,
        icon: Icons.event_busy_outlined,
        path: RoutePaths.members,
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Here is what is happening at your gym today.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.outline,
                onPressed: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final columns = wide ? 3 : constraints.maxWidth >= 560 ? 3 : 2;
              final horizontalPadding = AppSpacing.lg * 2;
              final gaps = AppSpacing.md * (columns - 1);
              final cardWidth =
                  (constraints.maxWidth - horizontalPadding - gaps) / columns;
              // Fixed card height keeps the grid compact at every width.
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: cardWidth / 112,
                children: [
                  for (final stat in stats)
                    StatCard(
                      label: stat.label,
                      icon: stat.icon,
                      value: '${stat.value}',
                      onTap: () => context.go(stat.path),
                    ),
                ],
              );
            },
          ),
          if (summary.totalMembers == 0) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: AppEmptyState(
                title: 'No members yet',
                message: 'Create your first member to start managing the gym.',
                icon: Icons.group_outlined,
                action: AppButton(
                  label: 'Add member',
                  icon: Icons.person_add_alt_1_outlined,
                  onPressed: () => context.go(RoutePaths.membersCreate),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final sections = [
                DashboardSection(
                  title: 'Expiring soon',
                  child: DashboardExpiringList(
                    items: snapshot.expiringSubscriptions,
                  ),
                ),
                DashboardSection(
                  title: 'Recent check-ins',
                  child: DashboardRecentCheckIns(
                    items: snapshot.recentCheckIns,
                  ),
                ),
              ];
              if (!wide) {
                return Column(
                  children: [
                    sections[0],
                    const SizedBox(height: AppSpacing.lg),
                    sections[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: sections[0]),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: sections[1]),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          DashboardSection(
            title: 'Quick actions',
            child: const DashboardQuickActions(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
