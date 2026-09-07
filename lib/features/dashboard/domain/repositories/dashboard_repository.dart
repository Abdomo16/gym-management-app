import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

abstract interface class DashboardRepository {
  Future<DashboardSnapshot> getDashboard();
}
