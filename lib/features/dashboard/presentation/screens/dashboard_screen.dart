import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/core/widgets/status_badge.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/dashboard/presentation/widgets/stat_card.dart';

/// Landing page of the authenticated area.
///
/// Content is placeholder-only for now: real KPIs will be wired to the
/// members/subscriptions/payments data sources in later phases.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    final displayName = user?.fullName ?? user?.email ?? 'there';

    final stats = <({String label, IconData icon, String value})>[
      (label: 'Members', icon: Icons.group_outlined, value: '—'),
      (
        label: 'Active subscriptions',
        icon: Icons.card_membership_outlined,
        value: '—',
      ),
      (
        label: "Today's check-ins",
        icon: Icons.qr_code_scanner_outlined,
        value: '—',
      ),
      (
        label: 'Revenue this month',
        icon: Icons.payments_outlined,
        value: '—',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('$greeting, $displayName', style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Here is what is happening at your gym today.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final stat in stats)
              SizedBox(
                width: 230,
                child: StatCard(
                  label: stat.label,
                  icon: stat.icon,
                  value: stat.value,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Recent check-ins',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const StatusBadge(
                    label: 'Live',
                    tone: StatusBadgeTone.success,
                    icon: Icons.circle,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppEmptyState(
                title: 'No check-ins yet',
                message: 'Check-ins will appear here as members scan in at '
                    'the front desk.',
                icon: Icons.qr_code_scanner_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
