import 'package:flutter/material.dart';

import 'package:gym_management_app/core/widgets/status_badge.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

/// Status pill for a subscription.
///
/// [status] is the display status (an active-but-past-end subscription
/// arrives as [SubscriptionStatus.expired] from the caller). Tones are
/// chosen per state; the label is always present so state is never
/// communicated by color alone.
class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({super.key, required this.status});

  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      SubscriptionStatus.active => const StatusBadge(
        label: 'Active',
        tone: StatusBadgeTone.success,
        icon: Icons.check_circle_outline,
      ),
      SubscriptionStatus.expiring => const StatusBadge(
        label: 'Expiring',
        tone: StatusBadgeTone.warning,
        icon: Icons.hourglass_bottom_outlined,
      ),
      SubscriptionStatus.expired => const StatusBadge(
        label: 'Expired',
        tone: StatusBadgeTone.danger,
        icon: Icons.event_busy_outlined,
      ),
      SubscriptionStatus.frozen => const StatusBadge(
        label: 'Frozen',
        tone: StatusBadgeTone.info,
        icon: Icons.ac_unit_outlined,
      ),
      SubscriptionStatus.cancelled => const StatusBadge(
        label: 'Cancelled',
        tone: StatusBadgeTone.neutral,
        icon: Icons.block_outlined,
      ),
    };
  }
}
