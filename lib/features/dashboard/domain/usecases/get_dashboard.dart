import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboard {
  const GetDashboard(this._repository);

  final DashboardRepository _repository;

  Future<DashboardSnapshot> call() {
    return _repository.getDashboard();
  }
}
