import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/utils/validators.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';

/// Email + password fields shared by auth flows.
///
/// The owning screen keeps the [Form] and the controllers; this widget only
/// renders the two fields (with the show/hide password toggle) so every auth
/// form looks and behaves identically.
class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.onFieldSubmitted,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onFieldSubmitted;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Email',
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          validator: Validators.email,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Password',
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: Validators.required,
          onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
        ),
      ],
    );
  }
}
