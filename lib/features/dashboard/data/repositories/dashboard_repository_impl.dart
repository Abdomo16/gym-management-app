import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:gym_management_app/features/dashboard/data/mappers/dashboard_mapper.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:gym_management_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  SupabaseDashboardRepository(this._dataSource);

  final DashboardRemoteDataSource _dataSource;

  @override
  Future<DashboardSnapshot> getDashboard() async {
    try {
      final data = await _dataSource.getDashboard();
      return DashboardMapper.fromRemoteData(data);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
