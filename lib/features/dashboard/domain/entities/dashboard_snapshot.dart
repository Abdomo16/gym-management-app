import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_expiring_subscription.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_recent_check_in.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_summary.dart';

part 'dashboard_snapshot.freezed.dart';

@freezed
abstract class DashboardSnapshot with _$DashboardSnapshot {
  const factory DashboardSnapshot({
    required DashboardSummary summary,
    required DateTime businessDate,
    required List<DashboardRecentCheckIn> recentCheckIns,
    required List<DashboardExpiringSubscription> expiringSubscriptions,
  }) = _DashboardSnapshot;
}
