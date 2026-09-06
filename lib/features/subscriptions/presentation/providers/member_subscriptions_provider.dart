import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/usecases/get_subscription_history.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscriptions_provider.dart';

/// Full subscription history for one member, newest first, keyed by
/// member id.
///
/// Auto-disposes when the screen is removed from the tree. Invalidating
/// the provider (e.g. after creating/renewing a subscription) triggers a
/// fresh fetch.
final memberSubscriptionsProvider =
    FutureProvider.family.autoDispose<List<Subscription>, String>((
      ref,
      memberId,
    ) async {
  return GetSubscriptionHistory(ref.read(subscriptionRepositoryProvider))(
    memberId,
  );
});
