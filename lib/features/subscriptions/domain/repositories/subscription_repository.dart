import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';

/// Contract for subscription operations.
///
/// Implementations must translate low-level errors into [AppFailure]
/// subtypes before they reach the rest of the application. Every query is
/// tenant-scoped by RLS; the client never selects an organization.
abstract interface class SubscriptionRepository {
  /// Loads available subscription plans for the current organization.
  ///
  /// When [activeOnly] is true (default), inactive plans are excluded
  /// server-side.
  Future<List<SubscriptionPlan>> getPlans({bool activeOnly = true});

  /// Creates a subscription plan. Only owners and managers are permitted
  /// by the database's RLS write policy; [organizationId] must come from
  /// the authenticated tenant context — never from user input.
  Future<SubscriptionPlan> createPlan({
    required String organizationId,
    required String name,
    required int durationDays,
    required double price,
    String? description,
  });

  /// Soft-deletes a plan by deactivating it, preserving subscription
  /// history. The database decides whether the caller may write.
  Future<void> deactivatePlan(String planId);

  /// Full subscription history for one member, newest first.
  ///
  /// The current subscription is derived from this list by the
  /// presentation layer (an active subscription whose end date has passed
  /// must be treated as expired, which a stored-status query cannot know).
  Future<List<Subscription>> getMemberSubscriptions(String memberId);

  /// Creates a subscription for [memberId] with the given [planId].
  ///
  /// [startDate] defaults to today. [organizationId] must come from the
  /// authenticated tenant context — never from user input. The database
  /// computes the end date from the plan's duration; the returned
  /// [Subscription] carries the authoritative period.
  Future<Subscription> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  });

  /// Changes a subscription's status (freeze/cancel) through the database.
  ///
  /// The database/RLS remains the authority for the transition; the client
  /// only requests it.
  Future<Subscription> updateSubscriptionStatus({
    required String id,
    required SubscriptionStatus status,
  });
}
