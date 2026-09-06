import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_logo.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:gym_management_app/features/auth/presentation/widgets/auth_form.dart';

/// Email/password sign-in for staff.
///
/// On success the router guard redirects to the appropriate destination
/// (dashboard, onboarding, or disabled screen), so this screen performs no
/// navigation of its own.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      await ref.read(authControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 48)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to manage your gym',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Form(
                  key: _formKey,
                  child: AuthForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onFieldSubmitted: _submit,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AuthErrorMessage(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Sign in',
                  onPressed: _isBusy ? null : _submit,
                  busy: _isBusy,
                  expanded: true,
                  size: AppButtonSize.large,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Multi-tenant gym management for owners, managers and '
                  'receptionists.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
