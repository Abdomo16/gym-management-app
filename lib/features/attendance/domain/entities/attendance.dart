import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';

@freezed
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String organizationId,
    required String memberId,
    String? branchId,
    required String checkedInBy,
    required DateTime checkInDay,
    required DateTime checkInAt,
  }) = _Attendance;
}
