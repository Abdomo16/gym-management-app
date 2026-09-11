import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/router/navigation_config.dart';
import 'package:gym_management_app/app/theme/app_colors.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_sidebar.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';

/// Responsive application shell used by the authenticated area.
///
/// Wide screens get a persistent sidebar; narrow screens get a bottom
/// navigation bar with the primary destinations and a "More" sheet for
/// the rest.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final title = navTitleForPath(location) ?? 'GymFlow';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed sidebar width keeps the shrink-wrapped column inside
                // a bounded box (required by the footer's Expanded row).
                const SizedBox(width: 260, child: AppSidebar()),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: child,
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: _AppBottomNav(location: location),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom navigation for narrow screens: the four primary destinations plus
/// a "More" sheet with everything else (role-filtered).
class _AppBottomNav extends ConsumerWidget {
  const _AppBottomNav({required this.location});

  final String location;

  static const List<AppNavItem> _primaryItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      path: RoutePaths.dashboard,
    ),
    AppNavItem(
      label: 'Check-in',
      icon: Icons.login_rounded,
      path: RoutePaths.checkIn,
    ),
    AppNavItem(
      label: 'Members',
      icon: Icons.group_outlined,
      path: RoutePaths.members,
    ),
    AppNavItem(
      label: 'Plans',
      icon: Icons.card_membership_outlined,
      path: RoutePaths.subscriptions,
    ),
  ];

  /// Filled-style glyph shown on the active destination.
  static const List<IconData> _activeIcons = [
    Icons.dashboard_rounded,
    Icons.login_rounded,
    Icons.groups_rounded,
    Icons.card_membership_rounded,
  ];

  /// Every nav item that is not pinned to the bar itself.
  static List<AppNavItem> get _secondaryItems => [
    for (final section in appNavSections)
      for (final item in section.items)
        if (!_primaryItems.any((primary) => primary.path == item.path)) item,
  ];

  bool _matches(String path) {
    if (location == path) return true;
    // Detail routes belong to their section (e.g. /members/:id, employees).
    if (path == RoutePaths.members &&
        location.startsWith('${RoutePaths.members}/')) {
      return true;
    }
    if (path == RoutePaths.employees &&
        location.startsWith('${RoutePaths.employees}/')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    final primary = _primaryItems;
    var selectedIndex = primary.indexWhere((item) => _matches(item.path));
    final onPrimary = selectedIndex >= 0;
    if (!onPrimary) selectedIndex = primary.length;

    final secondary = [
      for (final item in _secondaryItems)
        if (_isVisible(item, user?.role)) item,
    ];

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index < primary.length) {
          context.go(primary[index].path);
          return;
        }
        _showMoreSheet(context, ref, secondary);
      },
      destinations: [
        for (final (index, item) in primary.indexed)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(
              _activeIcons[index],
              color: colorScheme.primary,
            ),
            tooltip: item.label,
            label: item.label,
          ),
        NavigationDestination(
          icon: const Icon(Icons.menu_rounded),
          selectedIcon: Icon(
            Icons.menu_rounded,
            color: colorScheme.primary,
          ),
          tooltip: 'More',
          label: 'More',
        ),
      ],
    );
  }

  void _showMoreSheet(BuildContext context, WidgetRef ref,
      List<AppNavItem> items) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        // Cap the sheet at 70% of screen height and scroll anything that
        // does not fit, so many menu items never overflow.
        final maxSheetHeight = MediaQuery.of(sheetContext).size.height * 0.7;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'More',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ),
                  for (final item in items)
                    ListTile(
                      leading: Icon(
                        item.icon,
                        color: _matches(item.path)
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: _matches(item.path)
                              ? colorScheme.primary
                              : null,
                          fontWeight: _matches(item.path)
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: _matches(item.path)
                          ? Icon(Icons.chevron_right_rounded,
                              color: colorScheme.primary)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.go(item.path);
                      },
                    ),
                  const Divider(height: AppSpacing.lg),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.danger,
                    ),
                    title: Text(
                      'Sign out',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Whether a nav item is visible to the current role (UI decision only;
  /// RLS remains the security boundary).
  bool _isVisible(AppNavItem item, UserRole? role) {
    final allowedRoles = item.allowedRoles;
    if (allowedRoles == null) {
      return true;
    }
    return role != null && allowedRoles.contains(role);
  }
}
