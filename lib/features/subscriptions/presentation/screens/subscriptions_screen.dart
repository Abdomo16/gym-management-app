import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

/// Subscriptions overview: the sellable plans of the current organization.
///
/// Plans drive both member signup (duration picker) and renewals; the
/// database remains the source of truth for durations and prices.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(subscriptionPlansProvider),
      child: plansAsync.when(
        loading: () => const AppLoading(label: 'Loading plans...'),
        error: (_, _) => AppErrorState(
          message: 'Unable to load subscription plans.',
          onRetry: () => ref.invalidate(subscriptionPlansProvider),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppCard(
                    child: AppEmptyState(
                      title: 'No plans yet',
                      message:
                          'Subscription plans appear here once they are '
                          'added for your gym.',
                      icon: Icons.card_membership_outlined,
                    ),
                  ),
                ),
              ],
            );
          }

          final sorted = [...plans]..sort(
            (a, b) => (a.durationDays ?? 0).compareTo(b.durationDays ?? 0),
          );

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _PlanCard(
              plan: sorted[index],
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final SubscriptionPlan plan;

  /// "1 month", "2 months", ... "1 year" for month-based plans; falls back
  /// to the plan's own duration label otherwise.
  String get _durationLabel {
    final days = plan.durationDays;
    if (days != null && days > 0 && days % 30 == 0) {
      final months = days ~/ 30;
      if (months == 1) return '1 month';
      if (months == 12) return '1 year';
      return '$months months';
    }
    return plan.durationLabel;
  }

  String? get _priceLabel {
    final price = plan.price;
    if (price == null || price <= 0) {
      return null;
    }
    return plan.priceLabel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final price = _priceLabel;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              Icons.card_membership_outlined,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _durationLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            price ?? 'No price',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: price != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
