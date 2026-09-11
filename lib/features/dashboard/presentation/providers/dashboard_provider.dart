import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:gym_management_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:gym_management_app/features/dashboard/domain/usecases/get_dashboard.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return SupabaseDashboardRepository(
    DashboardRemoteDataSource(ref.watch(supabaseClientProvider)),
  );
});

// Kept alive across dashboard visits so tab switching doesn't refetch,
// but rebuilt whenever the signed-in user changes so a cached snapshot
// never crosses a sign-out/sign-in or a different account.
final dashboardProvider = FutureProvider<DashboardSnapshot>((ref) {
  ref.watch(currentUserProvider);
  return GetDashboard(ref.read(dashboardRepositoryProvider))();
});
