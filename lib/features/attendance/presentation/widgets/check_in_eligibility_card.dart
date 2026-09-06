import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/features/attendance/domain/entities/check_in_eligibility.dart';

class CheckInEligibilityCard extends StatelessWidget {
  const CheckInEligibilityCard({
    super.key,
    required this.eligibility,
    required this.busy,
    required this.onCheckIn,
    this.onManageSubscription,
  });

  final CheckInEligibility eligibility;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback? onManageSubscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final eligible = eligibility.isEligible;
    final alreadyCheckedIn = eligibility.reason ==
        CheckInEligibilityReason.alreadyCheckedInToday;
    final tone = eligible
        ? colorScheme.primary
        : alreadyCheckedIn
            ? colorScheme.tertiary
            : colorScheme.error;
    final background = eligible
        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
        : alreadyCheckedIn
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.45)
            : colorScheme.errorContainer.withValues(alpha: 0.45);

    return AppCard(
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                eligible
                    ? Icons.check_circle_outline
                    : alreadyCheckedIn
                        ? Icons.event_available_outlined
                        : Icons.block_outlined,
                color: tone,
                size: 30,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eligibility.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tone,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      eligibility.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (alreadyCheckedIn &&
                        eligibility.attendanceToday?.checkInAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'Check-in time: ${_formatTime(eligibility.attendanceToday!.checkInAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (eligible) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Check In',
              icon: Icons.login_rounded,
              onPressed: busy ? null : onCheckIn,
              busy: busy,
              expanded: true,
            ),
          ] else if (onManageSubscription != null &&
              (eligibility.reason ==
                      CheckInEligibilityReason.noSubscription ||
                  eligibility.reason ==
                      CheckInEligibilityReason.subscriptionExpired)) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: eligibility.reason ==
                      CheckInEligibilityReason.subscriptionExpired
                  ? 'Renew Subscription'
                  : 'Add Subscription',
              variant: AppButtonVariant.outline,
              onPressed: onManageSubscription,
              expanded: true,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}