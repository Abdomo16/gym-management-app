import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/navigation_config.dart';
import 'package:gym_management_app/app/theme/app_colors.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_logo.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Navigation sidebar used on wide layouts and inside the mobile drawer.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key, this.onItemSelected});

  /// Called after a destination is chosen (used to close the drawer).
  final VoidCallback? onItemSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final user = ref.watch(authControllerProvider).value;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(),
              ),
            ),
            Divider(color: colorScheme.outlineVariant, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  for (final section in appNavSections) ...[
                    if (section.title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.xxs,
                        ),
                        child: Text(
                          section.title!.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ),
                    for (final item in section.items)
                      _SidebarTile(
                        item: item,
                        selected: location == item.path,
                        onTap: () {
                          context.go(item.path);
                          onItemSelected?.call();
                        },
                      ),
                  ],
                ],
              ),
            ),
            Divider(color: colorScheme.outlineVariant, height: 1),
            _UserFooter(
              user: user,
              onSignOut: () {
                unawaited(ref.read(authControllerProvider.notifier).signOut());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.10),
        leading: Icon(
          item.icon,
          size: 20,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? colorScheme.primary : null,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        dense: true,
      ),
    );
  }
}

class _UserFooter extends StatelessWidget {
  const _UserFooter({required this.user, required this.onSignOut});

  final AppUser? user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = user?.displayName ?? user?.email ?? 'Account';
    final initials = displayName.isNotEmpty
        ? displayName.trim().characters.first.toUpperCase()
        : '?';
    final subtitle = user?.role.name ?? 'Signed out';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: Icon(Icons.logout_rounded, size: 20),
            color: AppColors.danger,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}
