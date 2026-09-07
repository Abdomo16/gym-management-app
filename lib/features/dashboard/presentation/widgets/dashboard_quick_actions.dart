import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppButton(
          label: 'Check-in',
          icon: Icons.login_rounded,
          onPressed: () => context.go(RoutePaths.checkIn),
        ),
        AppButton(
          label: 'Add member',
          icon: Icons.person_add_alt_1_outlined,
          variant: AppButtonVariant.outline,
          onPressed: () => context.go(RoutePaths.membersCreate),
        ),
        AppButton(
          label: 'View members',
          icon: Icons.group_outlined,
          variant: AppButtonVariant.outline,
          onPressed: () => context.go(RoutePaths.members),
        ),
      ],
    );
  }
}
