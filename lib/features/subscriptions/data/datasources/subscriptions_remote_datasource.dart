import 'package:flutter/foundation.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data access for `public.subscriptions` and `public.subscription_plans`.
///
/// Every query is tenant-scoped: the current organization is enforced by
/// RLS, and the client never sends an arbitrary organization id. The
/// database computes each subscription's `status` from the period; the
/// end date is derived here from the plan's duration and persisted
/// explicitly (the schema has no trigger that derives it).
class SubscriptionsRemoteDataSource {
  SubscriptionsRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _subscriptionsTable = 'subscriptions';
  static const String _plansTable = 'subscription_plans';

  /// Derives the last covered day from the start date and the plan's
  /// duration in days, inclusive of the start day: a 30-day plan starting
  /// on the 1st ends on the 30th.
  @visibleForTesting
  static DateTime computeSubscriptionEndDate(
    DateTime start,
    int durationDays,
  ) {
    return start.add(Duration(days: durationDays - 1));
  }

  /// Loads subscription plans for the current organization.
  Future<List<Map<String, dynamic>>> getPlans({bool activeOnly = true}) async {
    var query = _client.from(_plansTable).select();
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    return _asList(await query.order('name'));
  }

  /// Loads the full subscription history for a member, newest first.
  Future<List<Map<String, dynamic>>> getMemberSubscriptions(
    String memberId,
  ) async {
    final rows = await _client
        .from(_subscriptionsTable)
        .select()
        .eq('member_id', memberId)
        .order('created_at', ascending: false);
    return _asList(rows);
  }

  /// Inserts a subscription. The end date is derived from the plan's
  /// duration (inclusive of the start date) and sent explicitly; the
  /// database computes the authoritative `status` from the period.
  Future<Map<String, dynamic>> createSubscription({
    required String organizationId,
    required String memberId,
    required String planId,
    double? price,
    DateTime? startDate,
  }) async {
    try {
      final plan = await _client
          .from(_plansTable)
          .select('price, duration_days')
          .eq('id', planId)
          .single();
      final planPrice = (plan['price'] as num?)?.toDouble();
      final planDurationDays = (plan['duration_days'] as num?)?.toInt();
      if (planDurationDays == null || planDurationDays <= 0) {
        throw const ValidationFailure(
          message: 'The selected plan has no valid duration.',
        );
      }
      final resolvedPrice = price ?? planPrice;
      if (resolvedPrice == null) {
        throw const ValidationFailure(
          message: 'The selected subscription plan has no price.',
        );
      }
      final effectiveStart = startDate ?? DateTime.now();
      final effectiveEnd = computeSubscriptionEndDate(
        effectiveStart,
        planDurationDays,
      );
      final row = await _client
          .from(_subscriptionsTable)
          .insert({
            'organization_id': organizationId,
            'member_id': memberId,
            'plan_id': planId,
            'start_date': _dateOnly(effectiveStart),
            'end_date': _dateOnly(effectiveEnd),
            'price': resolvedPrice,
          })
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Inserts a subscription plan. Only owners and managers pass the
  /// database's RLS write policy; [organizationId] must come from the
  /// authenticated tenant context, never from user input.
  Future<Map<String, dynamic>> createPlan({
    required String organizationId,
    required String name,
    required int durationDays,
    required double price,
    String? description,
  }) async {
    try {
      return await _client
          .from(_plansTable)
          .insert({
            'organization_id': organizationId,
            'name': name,
            'duration_days': durationDays,
            'price': price,
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
          })
          .select()
          .single();
    } on PostgrestException catch (error) {
      throw _mapPlanWriteError(error);
    }
  }

  /// Soft-deletes a plan by deactivating it. Plans referenced by existing
  /// subscriptions cannot be hard-deleted (FK `ON DELETE RESTRICT`), and
  /// deactivation preserves subscription history. Server RLS still decides
  /// whether the caller may write.
  Future<void> deactivatePlan(String id) async {
    try {
      await _client.from(_plansTable).update({'is_active': false}).eq('id', id);
    } on PostgrestException catch (error) {
      throw _mapPlanWriteError(error);
    }
  }

  /// Requests a status transition (freeze/cancel) through the database.
  Future<Map<String, dynamic>> updateSubscriptionStatus({
    required String id,
    required String status,
  }) async {
    try {
      final row = await _client
          .from(_subscriptionsTable)
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();
      return row;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error);
    }
  }

  /// Maps PostgREST failures to friendly, non-technical messages.
  AppFailure _mapPostgrestError(PostgrestException error) {
    // 23505 = unique_violation. The approved schema constrains active
    // subscription overlap per member, so this maps to a clear message.
    if (error.code == '23505') {
      return const SupabaseFailure(
        message: 'This member already has an active subscription for that '
            'period.',
      );
    }
    if (error.code == '23514') {
      return const SupabaseFailure(
        message: 'This subscription change is not allowed by the current '
            'business rules.',
      );
    }
    return SupabaseFailure(
      message: 'Unable to save the subscription. Please try again.',
      code: error.code,
      cause: error,
    );
  }

  /// Maps write failures on `subscription_plans` (create/deactivate).
  AppFailure _mapPlanWriteError(PostgrestException error) {
    // 42501 = insufficient_privilege: the RLS write policy allows only
    // owners and managers of the current organization.
    if (error.code == '42501') {
      return const SupabaseFailure(
        message: 'Only the gym owner or a manager can manage subscription '
            'plans.',
      );
    }
    if (error.code == '23514') {
      return const SupabaseFailure(
        message: 'The plan details are not allowed by the current business '
            'rules.',
      );
    }
    return SupabaseFailure(
      message: 'Unable to save the plan. Please try again.',
      code: error.code,
      cause: error,
    );
  }

  static List<Map<String, dynamic>> _asList(Object? rows) {
    if (rows is! List) {
      return const [];
    }
    return rows.cast<Map<String, dynamic>>();
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
