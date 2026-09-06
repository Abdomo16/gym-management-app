import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_status_badge.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/remaining_days_badge.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/subscription_status_badge.dart';

class CheckInMemberSummary extends StatelessWidget {
  const CheckInMemberSummary({
    super.key,
    required this.member,
    required this.subscription,
    required this.planName,
  });

  final Member member;
  final Subscription? subscription;
  final String planName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  _initials(member.fullName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      member.memberCode ?? 'Member code unavailable',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              MemberStatusBadge(status: member.status),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          _InfoRow(label: 'Phone', value: member.phone),
          const SizedBox(height: AppSpacing.xs),
          if (subscription == null)
            const _InfoRow(label: 'Subscription', value: 'None')
          else ...[
            _InfoRow(label: 'Plan', value: planName),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(
              label: 'Start',
              value: _formatDate(subscription!.startDate),
            ),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(
              label: 'End',
              value: subscription!.endDate == null
                  ? 'Not available'
                  : _formatDate(subscription!.endDate!),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                RemainingDaysBadge(subscription: subscription!),
                SubscriptionStatusBadge(
                  status: subscription!.displayStatus,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}