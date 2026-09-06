import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/remaining_days_badge.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/subscription_status_badge.dart';

/// The member's current subscription, shown prominently on the member
/// details screen.
///
/// Communicates plan, period, remaining days and status at a glance, plus
/// the actions allowed for the current role. The widget is pure
/// presentation: all actions are delegated through callbacks so the
/// controller/state logic stays outside the widget tree.
class CurrentSubscriptionCard extends StatelessWidget {
  const CurrentSubscriptionCard({
    super.key,
    required this.subscription,
    required this.planName,
    required this.onRenew,
    this.onFreeze,
    this.onCancel,
  });

  final Subscription subscription;
  final String planName;
  final VoidCallback onRenew;

  /// Shown only for roles allowed to change subscription state.
  final VoidCallback? onFreeze;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = subscription.displayStatus;
    final showStateActions =
        (status == SubscriptionStatus.active ||
            status == SubscriptionStatus.frozen) &&
        (onFreeze != null || onCancel != null);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  planName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SubscriptionStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RemainingDaysBadge(subscription: subscription),
          const SizedBox(height: AppSpacing.md),
          _PeriodRow(label: 'Start', date: subscription.startDate),
          if (subscription.endDate != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _PeriodRow(label: 'End', date: subscription.endDate!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Renew Subscription',
                  variant: AppButtonVariant.primary,
                  icon: Icons.refresh_outlined,
                  onPressed: onRenew,
                  expanded: true,
                ),
              ),
              if (showStateActions) ...[
                const SizedBox(width: AppSpacing.xs),
                _StateActions(
                  status: status,
                  onFreeze: onFreeze,
                  onCancel: onCancel,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _formatDate(date),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _StateActions extends StatelessWidget {
  const _StateActions({
    required this.status,
    required this.onFreeze,
    required this.onCancel,
  });

  final SubscriptionStatus status;
  final VoidCallback? onFreeze;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final showFreeze = status == SubscriptionStatus.active && onFreeze != null;
    final showCancel = status != SubscriptionStatus.cancelled &&
        onCancel != null;

    if (!showFreeze && !showCancel) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'Subscription actions',
      itemBuilder: (_) => [
        if (showFreeze)
          const PopupMenuItem(value: 'freeze', child: Text('Freeze')),
        if (showCancel)
          const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
      ],
      onSelected: (value) {
        if (value == 'freeze') onFreeze?.call();
        if (value == 'cancel') onCancel?.call();
      },
    );
  }
}
