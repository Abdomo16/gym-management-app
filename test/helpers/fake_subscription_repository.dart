import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// In-memory [SubscriptionRepository] for unit and controller tests.
///
/// Mirrors the approved database behavior: creating a subscription computes
/// the end date from the plan's `duration_days` and history is never
/// overwritten (renewal appends a new record). Failure flags let tests
/// exercise error-handling paths without touching Supabase.
class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({
    List<SubscriptionPlan> plans = const [],
    List<Subscription> subscriptions = const [],
    this.throwOnPlans = false,
    this.throwOnHistory = false,
    this.throwOnCreate = false,
    this.throwOnUpdate = false,
    this.throwOnPlanWrite = false,
  }) : _plans = List<SubscriptionPlan>.from(plans),
       _subscriptions = List<Subscription>.from(subscriptions);

  final List<SubscriptionPlan> _plans;
  final List<Subscription> _subscriptions;
  bool throwOnPlans;
  bool throwOnHistory;
  bool throwOnCreate;
  bool throwOnUpdate;
  bool throwOnPlanWrite;

  /// Read-only view of the stored plans for test assertions.
  List<SubscriptionPlan> get storedPlans => List.unmodifiable(_plans);

  // ---------------------------------------------------------------------------
  // Factory helpers
  // ---------------------------------------------------------------------------

  static SubscriptionPlan makeTestPlan({
    String id = 'plan-1',
    String organizationId = 'org-1',
    String name = 'Monthly',
    String? description,
    int? durationDays = 30,
    double? price = 500,
    bool isActive = true,
  }) {
    return SubscriptionPlan(
      id: id,
      organizationId: organizationId,
      name: name,
      description: description,
      durationDays: durationDays,
      price: price,
      isActive: isActive,
    );
  }

  static Subscription makeTestSubscription({
    String id = 'sub-1',
    String organizationId = 'org-1',
    String memberId = 'member-1',
    String planId = 'plan-1',
    DateTime? startDate,
    DateTime? endDate,
    double? price = 500,
    SubscriptionStatus status = SubscriptionStatus.active,
    DateTime? createdAt,
  }) {
    final start = startDate ?? DateTime(2026, 9, 6);
    return Subscription(
      id: id,
      organizationId: organizationId,
      memberId: memberId,
      planId: planId,
      startDate: start,
      endDate: endDate ?? start.add(const Duration(days: 30)),
      price: price,
      status: status,
      createdAt: createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // SubscriptionRepository interface
  // ---------------------------------------------------------------------------

  @override
  Future<List<SubscriptionPlan>> getPlans({bool activeOnly = true}) async {
    if (throwOnPlans) {
      throw const SupabaseFailure(message: 'Failed to load plans.');
    }
    return _plans.where((p) => !activeOnly || p.isActive).toList();
  }

  @override
  Future<SubscriptionPlan> createPlan({
    required String organizationId,
    required String name,
    required int durationDays,
    required double price,
    String? description,
  }) async {
    if (throwOnPlanWrite) {
      throw const SupabaseFailure(message: 'Simulated plan write error.');
    }
    final plan = makeTestPlan(
      id: 'plan-${_plans.length + 1}',
      organizationId: organizationId,
      name: name,
      description: description,
      durationDays: durationDays,
      price: price,
    );
    _plans.add(plan);
    return plan;
  }

  @override
  Future<void> deactivatePlan(String planId) async {
    if (throwOnPlanWrite) {
      throw const SupabaseFailure(message: 'Simulated plan write error.');
    }
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index >= 0) {
      _plans[index] = _plans[index].copyWith(isActive: false);
    }
  }

  @override
  Future<List<Subscription>> getMemberSubscriptions(String memberId) async {
    if (throwOnHistory) {
      throw const SupabaseFailure(message: 'Failed to load subscriptions.');
    }
    return _subscriptions.where((s) => s.memberId == memberId).toList();
  }

  @override
  Future<Subscription> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  }) async {
    if (throwOnCreate) {
      throw const SupabaseFailure(message: 'Simulated server error.');
    }
    final start = startDate ?? DateTime(2026, 1, 1);
    final plan = _planById(planId);
    final days = plan?.durationDays ?? 30;
    final subscription = makeTestSubscription(
      id: 'sub-${_subscriptions.length + 1}',
      organizationId: organizationId,
      memberId: memberId,
      planId: planId,
      startDate: start,
      price: price,
      // Calendar-day math (like Postgres date arithmetic): adding 91 days
      // to Sep 6 lands on Dec 6 regardless of DST transitions.
      endDate: DateTime(start.year, start.month, start.day + days),
    );
    _subscriptions.insert(0, subscription); // newest first, like the API
    return subscription;
  }

  @override
  Future<Subscription> updateSubscriptionStatus({
    required String id,
    required SubscriptionStatus status,
  }) async {
    if (throwOnUpdate) {
      throw const SupabaseFailure(message: 'Simulated server error.');
    }
    final index = _subscriptions.indexWhere((s) => s.id == id);
    final base = index >= 0
        ? _subscriptions[index]
        : makeTestSubscription(id: id, status: status);
    final updated = base.copyWith(status: status);
    if (index >= 0) {
      _subscriptions[index] = updated;
    }
    return updated;
  }

  SubscriptionPlan? _planById(String id) {
    for (final plan in _plans) {
      if (plan.id == id) {
        return plan;
      }
    }
    return null;
  }
}
