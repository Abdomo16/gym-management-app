import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';

part 'dashboard_recent_check_in.freezed.dart';

@freezed
abstract class DashboardRecentCheckIn with _$DashboardRecentCheckIn {
  const factory DashboardRecentCheckIn({
    required Attendance attendance,
    required String memberName,
    String? memberCode,
  }) = _DashboardRecentCheckIn;
}
