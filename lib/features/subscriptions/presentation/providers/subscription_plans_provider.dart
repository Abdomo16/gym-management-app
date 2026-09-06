import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/get_subscription_plans.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';

/// Available subscription plans for the current organization.
///
/// Plans come from the database — never hard-coded. Invalidating this
/// provider refetches plans after plan changes.
final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) {
  return GetSubscriptionPlans(ref.read(subscriptionRepositoryProvider))();
});
