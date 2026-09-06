import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/core/widgets/app_logo.dart';

/// Shown while the initial auth session is being resolved.
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 56),
            const SizedBox(height: AppSpacing.xl),
            const AppLoading(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Loading your workspace…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
