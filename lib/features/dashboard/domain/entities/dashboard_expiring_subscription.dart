import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';

part 'dashboard_expiring_subscription.freezed.dart';

@freezed
abstract class DashboardExpiringSubscription
    with _$DashboardExpiringSubscription {
  const factory DashboardExpiringSubscription({
    required Subscription subscription,
    required String memberName,
    String? memberCode,
    String? planName,
    required int remainingDays,
  }) = _DashboardExpiringSubscription;
}
