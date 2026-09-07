import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int totalMembers,
    required int activeMembers,
    required int activeSubscriptions,
    required int expiringSoonSubscriptions,
    required int expiredSubscriptions,
    required int todayCheckIns,
  }) = _DashboardSummary;
}
