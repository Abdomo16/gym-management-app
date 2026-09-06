import 'package:flutter/material.dart';

import 'package:gym_management_app/core/widgets/status_badge.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

/// Prominent remaining-days indicator for a subscription.
///
/// Renders "91 days remaining", "1 day remaining", or "Expired" with a
/// semantic tone. The label always accompanies the color so state is never
/// communicated by color alone.
class RemainingDaysBadge extends StatelessWidget {
  const RemainingDaysBadge({super.key, required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    if (!subscription.isValid()) {
      return const StatusBadge(
        label: 'Expired',
        tone: StatusBadgeTone.danger,
        icon: Icons.event_busy_outlined,
      );
    }

    final days = subscription.remainingDays() ?? 0;
    final label = switch (days) {
      0 => 'Expiring today',
      1 => '1 day remaining',
      _ => '$days days remaining',
    };

    return StatusBadge(
      label: label,
      tone: subscription.isExpiringSoon()
          ? StatusBadgeTone.warning
          : StatusBadgeTone.success,
      icon: Icons.hourglass_bottom_outlined,
    );
  }
}
