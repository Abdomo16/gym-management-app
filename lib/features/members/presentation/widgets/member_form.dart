import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/utils/validators.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/organization_branches_provider.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

/// Shared create/edit member form.
///
/// When [initial] is null, the form is in "create" mode; otherwise it
/// pre-fills fields for editing. The form validates inline and calls
/// [onSubmit] only when all constraints pass.
class MemberForm extends ConsumerStatefulWidget {
  const MemberForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.submitLabel,
    this.busy = false,
    this.serverError,
    this.showBranchPicker = true,
  });

  /// Pre-filled values for edit mode; `null` means create mode.
  final Member? initial;

  /// Called with the collected values when the form is valid.
  final void Function({
    required String fullName,
    required String phone,
    String? branchId,
    String? gender,
    DateTime? dateOfBirth,
    String? notes,
    String? subscriptionPlanId,
  }) onSubmit;

  final String submitLabel;

  /// Disables the submit button while a save is in progress.
  final bool busy;

  /// An error message returned from the server (e.g. duplicate phone).
  final String? serverError;

  /// Whether to show the branch dropdown. Receptionists are auto-assigned
  /// their branch by the controller, so the picker is hidden.
  final bool showBranchPicker;

  @override
  ConsumerState<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends ConsumerState<MemberForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  String? _selectedBranchId;
  String? _selectedGender;
  DateTime? _dateOfBirth;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    _nameController = TextEditingController(text: m?.fullName ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
    _selectedBranchId = m?.branchId;
    _selectedGender = m?.gender?.name;
    _dateOfBirth = m?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      branchId: _selectedBranchId,
      gender: _selectedGender,
      dateOfBirth: _dateOfBirth,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      subscriptionPlanId: _selectedPlanId,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full name
          AppTextField(
            label: 'Full Name *',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.required(v, message: 'Name is required.'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Phone
          AppTextField(
            label: 'Phone *',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.phone_outlined, size: 18),
            validator: Validators.phone,
          ),
          const SizedBox(height: AppSpacing.md),

          // Gender
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Not specified')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => _selectedGender = v),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date of birth
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              child: Text(
                _dateOfBirth != null
                    ? _formatDate(_dateOfBirth!)
                    : 'Not specified',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _dateOfBirth != null
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Branch picker (owner/manager only)
          if (widget.showBranchPicker)
            ref.watch(organizationBranchesProvider).when(
              data: (branches) => _BranchDropdown(
                branches: branches,
                value: _selectedBranchId,
                onChanged: (id) => setState(() => _selectedBranchId = id),
              ),
              loading: () => const _BranchDropdown(
                branches: [],
                value: null,
                onChanged: null,
              ),
              error: (e, _) => const _BranchDropdown(
                branches: [],
                value: null,
                onChanged: null,
              ),
            ),

          if (widget.showBranchPicker) const SizedBox(height: AppSpacing.md),

          // Subscription duration (create mode only). Selecting a duration
          // creates a subscription for the new member from the matching
          // plan; the database computes the end date.
          if (widget.initial == null) ...[
            ref.watch(subscriptionPlansProvider).when(
              data: (plans) => _DurationDropdown(
                plans: _sortedPlans(plans),
                value: _selectedPlanId,
                onChanged: (id) => setState(() => _selectedPlanId = id),
              ),
              loading: () => const _DurationDropdown(
                plans: [],
                value: null,
                onChanged: null,
              ),
              error: (e, _) => const _DurationDropdown(
                plans: [],
                value: null,
                onChanged: null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Notes
          AppTextField(
            label: 'Notes',
            controller: _notesController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Server error
          if (widget.serverError != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                widget.serverError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Submit
          AppButton(
            label: widget.submitLabel,
            onPressed: widget.busy ? null : _submit,
            busy: widget.busy,
            expanded: true,
          ),
        ],
      ),
    );
  }

  /// Plans sorted by duration so the dropdown reads 1 month → 1 year.
  static List<SubscriptionPlan> _sortedPlans(List<SubscriptionPlan> plans) {
    final sorted = [...plans];
    sorted.sort(
      (a, b) => (a.durationDays ?? 0).compareTo(b.durationDays ?? 0),
    );
    return sorted;
  }
}

/// Subscription-plan picker shown when creating a member. Plans come from
/// the gym's Subscriptions catalog; the plan's duration drives the
/// membership end date and its price is charged.
class _DurationDropdown extends StatelessWidget {
  const _DurationDropdown({
    required this.plans,
    required this.value,
    required this.onChanged,
  });

  final List<SubscriptionPlan> plans;
  final String? value;
  final ValueChanged<String?>? onChanged;

  /// "1 month", "2 months", ... "1 year" for month-based plans; falls back
  /// to the plan's own duration label otherwise.
  static String _durationLabel(SubscriptionPlan plan) {
    final days = plan.durationDays;
    if (days != null && days > 0 && days % 30 == 0) {
      final months = days ~/ 30;
      if (months == 1) return '1 month';
      if (months == 12) return '1 year';
      return '$months months';
    }
    return plan.durationLabel;
  }

  static String _optionLabel(SubscriptionPlan plan) {
    final parts = <String>[plan.name, _durationLabel(plan)];
    final price = plan.price;
    if (price != null && price > 0 && plan.priceLabel != null) {
      parts.add(plan.priceLabel!);
    }
    return parts.join(' — ');
  }

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(
          labelText: 'Subscription plan',
          helperText: 'No plans yet — create one in the Subscriptions tab.',
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('No subscription')),
        ],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Subscription plan',
        helperText: 'A subscription is created from the selected plan.',
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('No subscription')),
        for (final plan in plans)
          DropdownMenuItem(value: plan.id, child: Text(_optionLabel(plan))),
      ],
      onChanged: onChanged,
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  const _BranchDropdown({
    required this.branches,
    required this.value,
    required this.onChanged,
  });

  final List<BranchSummary> branches;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return DropdownButtonFormField<String>(
        initialValue: null,
        decoration: const InputDecoration(labelText: 'Branch'),
        items: const [
          DropdownMenuItem(value: null, child: Text('No branches available')),
        ],
        onChanged: null,
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Branch'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Not assigned')),
        for (final branch in branches)
          DropdownMenuItem(value: branch.id, child: Text(branch.name)),
      ],
      onChanged: onChanged,
    );
  }
}
