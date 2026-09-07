import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/employees/data/datasources/employee_remote_datasource.dart';
import 'package:gym_management_app/features/employees/data/repositories/employee_repository_impl.dart';
import 'package:gym_management_app/features/employees/domain/repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return SupabaseEmployeeRepository(
    EmployeeRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});
