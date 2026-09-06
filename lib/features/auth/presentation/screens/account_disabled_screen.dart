import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_logo.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Shown when the authenticated user's profile is inactive.
///
/// The user cannot enter the application; they can only sign out. Signing
/// out transitions to the unauthenticated state, and the router guard moves
/// to the login screen.
class AccountDisabledScreen extends ConsumerWidget {
  const AccountDisabledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(height: AppSpacing.lg),
                  Icon(
                    Icons.block_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Account disabled',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your account has been disabled. Please contact your gym '
                    'administrator.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Sign out',
                    variant: AppButtonVariant.outline,
                    expanded: true,
                    onPressed: () {
                      unawaited(
                        ref
                            .read(authControllerProvider.notifier)
                            .signOut(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
