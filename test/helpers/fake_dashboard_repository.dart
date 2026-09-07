import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({required this.snapshot, this.throwOnGet = false});

  final DashboardSnapshot snapshot;
  bool throwOnGet;

  @override
  Future<DashboardSnapshot> getDashboard() async {
    if (throwOnGet) {
      throw const SupabaseFailure(message: 'Unable to load the dashboard.');
    }
    return snapshot;
  }
}
