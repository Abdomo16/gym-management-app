import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';

/// A sellable subscription plan from `public.subscription_plans`.
///
/// Plans are loaded from the database — never hard-coded. [durationDays]
/// drives the period calculation; the database computes the subscription's
/// end date from it.
@freezed
abstract class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String organizationId,
    required String name,
    String? description,
    int? durationDays,
    double? price,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionPlan;

  const SubscriptionPlan._();

  /// A short label describing the plan duration, e.g. "30 days".
  String get durationLabel {
    final days = durationDays;
    if (days == null) {
      return 'Duration not set';
    }
    if (days % 30 == 0) {
      final months = days ~/ 30;
      return months == 1 ? '1 month' : '$months months';
    }
    if (days % 7 == 0 && days != 0) {
      final weeks = days ~/ 7;
      return weeks == 1 ? '1 week' : '$weeks weeks';
    }
    return days == 1 ? '1 day' : '$days days';
  }

  /// Price formatted for display, or `null` when the plan has no price.
  String? get priceLabel {
    final value = price;
    if (value == null) {
      return null;
    }
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}
