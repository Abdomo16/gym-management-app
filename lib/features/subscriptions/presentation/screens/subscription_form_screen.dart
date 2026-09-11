import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/utils/organization_calendar.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

/// Whether the form creates a brand-new subscription or renews (which also
/// creates a new record, preserving history).
enum SubscriptionFormMode { create, renew }

/// Staff-facing form to create or renew a member's subscription.
///
/// The staff picks a plan and a start date; the database computes the end
/// date from the plan's duration. The form shows a preview of the period so
/// staff can confirm before submitting, and never allows typing an end date.
class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({
    super.key,
    required this.memberId,
    this.mode = SubscriptionFormMode.create,
  });

  final String memberId;
  final SubscriptionFormMode mode;

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPlanId;
  late DateTime _startDate;
  String? _serverError;

  bool get _isRenew => widget.mode == SubscriptionFormMode.renew;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
  }

  DateTime? get _estimatedEndDate {
    final plan = _selectedPlan;
    final days = plan?.durationDays;
    if (plan == null || days == null) {
      return null;
    }
    // Same inclusive computation the datasource persists, so the preview
    // always matches the stored end date exactly.
    return OrganizationCalendar.subscriptionEndDate(_startDate, days);
  }

  SubscriptionPlan? get _selectedPlan {
    final plans = ref
        .read(subscriptionPlansProvider)
        .whenOrNull(data: (plans) => plans);
    if (plans == null) return null;
    for (final plan in plans) {
      if (plan.id == _selectedPlanId) {
        return plan;
      }
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Select subscription start date',
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final planId = _selectedPlanId;
    if (planId == null) return;

    final organizationId =
        ref.read(organizationContextProvider)?.organizationId;
    if (organizationId == null || organizationId.isEmpty) {
      setState(() {
        _serverError =
            'Your account is missing an organization. Please contact your '
            'gym administrator.';
      });
      return;
    }

    final controller = ref.read(subscriptionControllerProvider.notifier);
    setState(() => _serverError = null);
    try {
      final subscription = _isRenew
          ? await controller.renewSubscription(
              organizationId: organizationId,
              memberId: widget.memberId,
              planId: planId,
              price: _selectedPlan?.price,
              startDate: _startDate,
            )
          : await controller.createSubscription(
              organizationId: organizationId,
              memberId: widget.memberId,
              planId: planId,
              price: _selectedPlan?.price,
              startDate: _startDate,
            );

      if (!mounted) return;
      final plan = _selectedPlan;
      final endText = subscription.endDate != null
          ? _formatDate(subscription.endDate!)
          : 'per the plan duration';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRenew
                ? 'Subscription renewed: ${plan?.name ?? 'Plan'} — valid '
                      'until $endText.'
                : 'Subscription created: ${plan?.name ?? 'Plan'} — valid '
                      'until $endText.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.message);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final busy = ref.watch(subscriptionControllerProvider) ==
        SubscriptionActionStatus.busy;
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final estimatedEnd = _estimatedEndDate;
    final plan = _selectedPlan;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRenew ? 'Renew Subscription' : 'Add Subscription'),
      ),
      body: plansAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load subscription plans.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Retry',
                  onPressed: () => ref.invalidate(subscriptionPlansProvider),
                ),
              ],
            ),
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No subscription plans are available yet.\n'
                  'Ask your gym administrator to add plans.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan selection
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPlanId,
                    decoration: const InputDecoration(labelText: 'Plan *'),
                    items: [
                      for (final plan in plans)
                        DropdownMenuItem(
                          value: plan.id,
                          child: Text(_planOptionLabel(plan)),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (id) => setState(() => _selectedPlanId = id),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a plan.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Start date
                  InkWell(
                    onTap: busy ? null : _pickStartDate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Date *',
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      child: Text(
                        _formatDate(_startDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The end date is calculated by the system from the '
                    'selected plan duration.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Summary preview
                  if (plan != null) ...[
                    _SummaryCard(
                      plan: plan,
                      startDate: _startDate,
                      estimatedEnd: estimatedEnd,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Server error
                  if (_serverError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        _serverError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Submit — disabled while busy to prevent double submission
                  AppButton(
                    label: _isRenew ? 'Renew Subscription' : 'Create Subscription',
                    onPressed: busy ? null : _submit,
                    busy: busy,
                    expanded: true,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _planOptionLabel(SubscriptionPlan plan) {
    final duration = plan.durationLabel;
    final price = plan.priceLabel;
    if (price == null) {
      return '$duration — ${plan.name}';
    }
    return '$duration — ${plan.name} ($price)';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.plan,
    required this.startDate,
    required this.estimatedEnd,
  });

  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime? estimatedEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Plan', value: plan.name),
          _SummaryRow(label: 'Duration', value: plan.durationLabel),
          if (plan.priceLabel != null)
            _SummaryRow(label: 'Price', value: plan.priceLabel!),
          _SummaryRow(label: 'Start', value: _formatDate(startDate)),
          _SummaryRow(
            label: 'End (estimated)',
            value: estimatedEnd != null ? _formatDate(estimatedEnd!) : '—',
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Final end date is confirmed by the system when the '
            'subscription is saved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
