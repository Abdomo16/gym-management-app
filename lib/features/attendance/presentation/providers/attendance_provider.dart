import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:gym_management_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:gym_management_app/features/attendance/domain/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return SupabaseAttendanceRepository(
    AttendanceRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});