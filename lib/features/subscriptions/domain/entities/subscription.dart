import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';

/// Lifecycle states for a subscription, matching the `status` column in
/// `public.subscriptions`. The database remains the source of truth for
/// transitions; this enum only provides safe typed access for the UI.
enum SubscriptionStatus { active, expired, frozen, cancelled }

extension SubscriptionStatusX on SubscriptionStatus {
  /// Maps a database status string to a [SubscriptionStatus].
  ///
  /// Returns `null` for unknown values so callers can fail safely instead of
  /// silently downgrading.
  static SubscriptionStatus? fromWireName(String? value) {
    for (final status in SubscriptionStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return null;
  }

  /// Human-readable status label for the UI.
  String get label {
    return switch (this) {
      SubscriptionStatus.active => 'Active',
      SubscriptionStatus.expired => 'Expired',
      SubscriptionStatus.frozen => 'Frozen',
      SubscriptionStatus.cancelled => 'Cancelled',
    };
  }

  bool get isActive => this == SubscriptionStatus.active;
  bool get isTerminal => this == SubscriptionStatus.expired ||
      this == SubscriptionStatus.cancelled;
}

/// A member's subscription: the validity period granted by a plan.
///
/// The database owns the period calculation: [startDate] is chosen by
/// staff, while [endDate] is computed by the database from the plan's
/// duration. The client never fabricates validity values.
@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String organizationId,
    required String memberId,
    required String planId,
    required DateTime startDate,
    DateTime? endDate,
    @Default(SubscriptionStatus.active) SubscriptionStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Subscription;

  const Subscription._();

  /// Whole calendar days remaining until [endDate], counted from today.
  ///
  /// Returns `0` once the period has ended, and `null` when no end date is
  /// known. [now] is injectable for tests and defaults to the device clock.
  int? remainingDays({DateTime? now}) {
    final end = endDate;
    if (end == null) {
      return null;
    }
    final today = _dateOnly(now ?? DateTime.now());
    final diff = _dateOnly(end).difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Whether the member currently has valid access.
  ///
  /// This is the value Phase 5 check-in will rely on: the subscription must
  /// be active and the end date not yet passed.
  bool isValid({DateTime? now}) {
    if (status != SubscriptionStatus.active) {
      return false;
    }
    return (remainingDays(now: now) ?? 0) > 0;
  }

  /// True when the subscription is active and will lapse within 7 days.
  bool isExpiringSoon({DateTime? now}) {
    if (status != SubscriptionStatus.active) {
      return false;
    }
    final days = remainingDays(now: now);
    return days != null && days > 0 && days <= 7;
  }

  /// The status to display.
  ///
  /// An active subscription whose end date has passed is shown as expired
  /// even if the database has not yet flipped the stored status.
  SubscriptionStatus get displayStatus {
    if (status == SubscriptionStatus.active &&
        (remainingDays() ?? 0) <= 0) {
      return SubscriptionStatus.expired;
    }
    return status;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
