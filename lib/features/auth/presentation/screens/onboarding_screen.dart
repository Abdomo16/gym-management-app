import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/core/utils/timezones.dart';
import 'package:gym_management_app/core/utils/validators.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_logo.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/widgets/auth_error_message.dart';

/// First-time owner onboarding: creates the gym's first organization through
/// the `create_organization_with_owner` RPC.
///
/// Reachable only when the session exists but no usable profile/organization
/// is present yet. On success the router guard moves the user into the
/// authenticated application.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late String _timezone;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _timezone = Timezones.defaultForDevice();
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).createOrganization(
        orgName: _orgNameController.text.trim(),
        ownerFullName: _ownerNameController.text.trim(),
        ownerPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        timezone: _timezone,
      );
      // The router guard redirects to the dashboard once authenticated.
    } on AppFailure catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = ExceptionMapper.map(error).message);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 48)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Create your gym',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Set up your organization to start managing members, '
                  'subscriptions and attendance.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Gym / organization name',
                        controller: _orgNameController,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(
                          Icons.storefront_outlined,
                        ),
                        validator: Validators.required,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Owner full name',
                        controller: _ownerNameController,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: Validators.required,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Phone (optional)',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _timezone,
                        decoration: const InputDecoration(
                          labelText: 'Timezone',
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                        items: [
                          for (final timezone in Timezones.supported)
                            DropdownMenuItem(
                              value: timezone,
                              child: Text(timezone),
                            ),
                        ],
                        onChanged: _isBusy
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _timezone = value);
                                }
                              },
                        validator: (value) => Validators.required(value),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AuthErrorMessage(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Create gym',
                  onPressed: _isBusy ? null : _submit,
                  busy: _isBusy,
                  expanded: true,
                  size: AppButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
