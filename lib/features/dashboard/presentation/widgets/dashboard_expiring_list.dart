import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_expiring_subscription.dart';

class DashboardExpiringList extends StatelessWidget {
  const DashboardExpiringList({super.key, required this.items});

  final List<DashboardExpiringSubscription> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          title: 'No subscriptions expiring soon',
          message:
              'There are no upcoming expirations in the configured window.',
          icon: Icons.event_available_outlined,
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ExpiringTile(item: items[index]),
            if (index < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ExpiringTile extends StatelessWidget {
  const _ExpiringTile({required this.item});

  final DashboardExpiringSubscription item;

  @override
  Widget build(BuildContext context) {
    final days = item.remainingDays;
    final remaining = days == 1 ? '1 day left' : '$days days left';
    return ListTile(
      onTap: () =>
          context.push(RoutePaths.memberDetail(item.subscription.memberId)),
      leading: const CircleAvatar(child: Icon(Icons.schedule_outlined)),
      title: Text(item.memberName),
      subtitle: Text(
        [
          if (item.memberCode != null) item.memberCode!,
          if (item.planName != null) item.planName!,
        ].join(' · '),
      ),
      trailing: Text(
        remaining,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }
}
