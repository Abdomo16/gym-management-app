import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/navigation_config.dart';
import 'package:gym_management_app/app/theme/app_colors.dart';
import 'package:gym_management_app/core/widgets/app_sidebar.dart';

/// Responsive application shell used by the authenticated area.
///
/// Wide screens get a persistent sidebar; narrow screens get an app bar with
/// a drawer containing the same navigation.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          appBar: AppBar(
            title: Text(title),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  tooltip: 'Open navigation',
                  icon: Icon(
                    Icons.menu_rounded,
                    color: AppColors.textPrimaryLight,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
          ),
          drawer: Drawer(
            backgroundColor: colorScheme.surface,
            child: AppSidebar(
              onItemSelected: () => Navigator.of(context).pop(),
            ),
          ),
          body: child,
        );
      },
    );
  }
}
