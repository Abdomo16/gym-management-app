import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Creates a subscription plan for the current organization.
///
/// Basic invariants are enforced here as defense in depth; the form and
/// the database (RLS + constraints) remain the primary validators.
class CreateSubscriptionPlan {
  const CreateSubscriptionPlan(this._repository);

  final SubscriptionRepository _repository;

  Future<SubscriptionPlan> call({
    required String organizationId,
    required String name,
    required int durationDays,
    required double price,
    String? description,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure(message: 'Plan name is required.');
    }
    if (durationDays <= 0) {
      throw const ValidationFailure(
        message: 'Duration must be at least 1 day.',
      );
    }
    if (price < 0) {
      throw const ValidationFailure(message: 'Price cannot be negative.');
    }
    return _repository.createPlan(
      organizationId: organizationId,
      name: trimmedName,
      durationDays: durationDays,
      price: price,
      description: description?.trim(),
    );
  }
}

/// Deactivates (soft-deletes) a subscription plan, preserving subscription
/// history. The database remains the authority on whether the caller is
/// allowed to write.
class DeactivateSubscriptionPlan {
  const DeactivateSubscriptionPlan(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(String planId) {
    return _repository.deactivatePlan(planId);
  }
}
