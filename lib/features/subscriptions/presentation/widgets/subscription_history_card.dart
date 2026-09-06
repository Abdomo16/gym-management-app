import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/subscription_history_tile.dart';

/// Chronological subscription history for a member.
///
/// The most recent subscription is flagged as "Current". Empty histories
/// render a targeted empty state instead of a blank section.
class SubscriptionHistoryCard extends StatelessWidget {
  const SubscriptionHistoryCard({
    super.key,
    required this.subscriptions,
    required this.planNamesById,
    this.currentSubscriptionId,
  });

  final List<Subscription> subscriptions;
  final Map<String, String> planNamesById;
  final String? currentSubscriptionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Subscription History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (subscriptions.isEmpty)
            const AppEmptyState(
              icon: Icons.history_outlined,
              title: 'No subscriptions yet.',
              message:
                  'Add the first subscription to start tracking access '
                  'periods for this member.',
            )
          else
            Column(
              children: [
                for (final (index, subscription)
                    in subscriptions.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.xs),
                  SubscriptionHistoryTile(
                    subscription: subscription,
                    planName: planNamesById[subscription.planId] ??
                        'Subscription plan',
                    isCurrent: subscription.id == currentSubscriptionId,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
