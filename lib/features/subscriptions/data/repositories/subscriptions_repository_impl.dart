import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/features/subscriptions/data/datasources/subscriptions_remote_datasource.dart';
import 'package:gym_management_app/features/subscriptions/data/mappers/subscription_mapper.dart';
import 'package:gym_management_app/features/subscriptions/data/mappers/subscription_plan_mapper.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Supabase-backed implementation of [SubscriptionRepository].
class SupabaseSubscriptionRepository implements SubscriptionRepository {
  SupabaseSubscriptionRepository(this._dataSource);

  final SubscriptionsRemoteDataSource _dataSource;

  @override
  Future<List<SubscriptionPlan>> getPlans({bool activeOnly = true}) async {
    try {
      final rows = await _dataSource.getPlans(activeOnly: activeOnly);
      return rows.map(SubscriptionPlanMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<List<Subscription>> getMemberSubscriptions(String memberId) async {
    try {
      final rows = await _dataSource.getMemberSubscriptions(memberId);
      return rows.map(SubscriptionMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Subscription> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  }) async {
    try {
      final row = await _dataSource.createSubscription(
        organizationId: organizationId,
        memberId: memberId,
        planId: planId,
        price: price,
        startDate: startDate,
      );
      return SubscriptionMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Subscription> updateSubscriptionStatus({
    required String id,
    required SubscriptionStatus status,
  }) async {
    try {
      final row = await _dataSource.updateSubscriptionStatus(
        id: id,
        status: status.name,
      );
      return SubscriptionMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
