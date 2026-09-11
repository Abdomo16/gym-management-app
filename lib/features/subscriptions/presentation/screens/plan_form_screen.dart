import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/utils/validators.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plan_controller.dart';

/// Owner/manager form to create a subscription plan with a price.
///
/// The duration is picked in whole months (1–12, with 12 labeled as
/// "1 year") and stored as calendar days (months × 30), which the database
/// uses to compute subscription end dates.
class PlanFormScreen extends ConsumerStatefulWidget {
  const PlanFormScreen({super.key});

  @override
  ConsumerState<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends ConsumerState<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  int _durationMonths = 1;
  String? _serverError;

  static const int _maxDurationMonths = 12;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Parses the price field: accepts "300" or "300.50" (also with a
  /// decimal comma), rejects negatives and non-numeric input.
  double? _parsePrice(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value.isNaN || value < 0) {
      return null;
    }
    return value;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final price = _parsePrice(_priceController.text);
    if (price == null) {
      setState(
        () => _serverError = 'Enter a valid price (e.g. 300 or 300.50).',
      );
      return;
    }

    final organizationId =
        ref.read(organizationContextProvider)?.organizationId;
    if (organizationId == null || organizationId.isEmpty) {
      setState(
        () => _serverError =
            'No active organization. Please sign in again.',
      );
      return;
    }

    setState(() => _serverError = null);
    try {
      await ref.read(planControllerProvider.notifier).createPlan(
            organizationId: organizationId,
            name: _nameController.text,
            durationDays: _durationMonths * 30,
            price: price,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Plan created: ${_nameController.text.trim()} — '
            '${SubscriptionPlan.monthsLabel(_durationMonths)}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } on AppFailure catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(() => _serverError = 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(planControllerProvider) == PlanActionStatus.busy;

    return Scaffold(
      appBar: AppBar(title: const Text('New Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Plan Name *',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    Validators.required(v, message: 'Name is required.'),
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<int>(
                initialValue: _durationMonths,
                decoration: const InputDecoration(labelText: 'Duration *'),
                items: [
                  for (var months = 1; months <= _maxDurationMonths; months++)
                    DropdownMenuItem(
                      value: months,
                      child: Text(SubscriptionPlan.monthsLabel(months)),
                    ),
                ],
                onChanged: busy
                    ? null
                    : (months) {
                        if (months != null) {
                          setState(() => _durationMonths = months);
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                label: 'Price *',
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                validator: (v) =>
                    Validators.required(v, message: 'Price is required.'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Members who pick this plan are charged this price for the '
                'whole duration.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_serverError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    _serverError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              AppButton(
                label: 'Create Plan',
                onPressed: busy ? null : _submit,
                busy: busy,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
