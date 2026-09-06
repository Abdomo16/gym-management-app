import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Loads available subscription plans for the current organization.
class GetSubscriptionPlans {
  const GetSubscriptionPlans(this._repository);

  final SubscriptionRepository _repository;

  Future<List<SubscriptionPlan>> call({bool activeOnly = true}) {
    return _repository.getPlans(activeOnly: activeOnly);
  }
}
