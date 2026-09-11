import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plan_controller.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

/// Subscriptions overview: the sellable plans of the current organization.
///
/// Plans drive both member signup and renewals; the database remains the
/// source of truth for durations and prices. Owners and managers can add
/// and delete plans; the database's RLS policy is the security boundary.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final canManage = _canManage(ref);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(subscriptionPlansProvider),
      child: plansAsync.when(
        loading: () => const AppLoading(label: 'Loading plans...'),
        error: (_, _) => AppErrorState(
          message: 'Unable to load subscription plans.',
          onRetry: () => ref.invalidate(subscriptionPlansProvider),
        ),
        data: (plans) {
          final sorted = [...plans]..sort(
            (a, b) => (a.durationDays ?? 0).compareTo(b.durationDays ?? 0),
          );
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (canManage) ...[
                AppButton(
                  label: 'Add plan',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      context.push(RoutePaths.subscriptionPlanCreate),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (sorted.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    title: 'No plans yet',
                    message: canManage
                        ? 'Create your first plan to sell memberships with '
                              'a duration and price.'
                        : 'Subscription plans appear here once the gym '
                              'owner adds them.',
                    icon: Icons.card_membership_outlined,
                  ),
                )
              else
                for (final plan in sorted) ...[
                  _PlanCard(
                    plan: plan,
                    canManage: canManage,
                    onDelete: () => _confirmDelete(context, ref, plan),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          );
        },
      ),
    );
  }

  /// UI-level gate only; the database's RLS write policy is the real
  /// security boundary for plan mutations.
  static bool _canManage(WidgetRef ref) {
    final role = ref.watch(currentProfileProvider)?.role;
    return role == UserRole.owner || role == UserRole.manager;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete plan?'),
        content: Text(
          '"${plan.name}" will no longer be offered to members. Existing '
          'subscriptions keep their original terms.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(planControllerProvider.notifier).deactivatePlan(plan.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan "${plan.name}" deleted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AppFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.canManage,
    required this.onDelete,
  });

  final SubscriptionPlan plan;
  final bool canManage;
  final VoidCallback onDelete;

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
          if (canManage) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              tooltip: 'Delete plan',
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
