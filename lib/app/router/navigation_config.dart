import 'package:flutter/material.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';

/// A single sidebar destination.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.path,
    this.allowedRoles,
  });

  final String label;
  final IconData icon;
  final String path;

  /// When set, only users with one of these roles may see the item.
  /// `null` means visible to every authenticated user.
  final Set<UserRole>? allowedRoles;
}

/// A titled group of navigation items.
class AppNavSection {
  const AppNavSection({this.title, required this.items});

  final String? title;
  final List<AppNavItem> items;
}

/// Sidebar configuration for the authenticated area.
const List<AppNavSection> appNavSections = [
  AppNavSection(items: [
    AppNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      path: RoutePaths.dashboard,
    ),
    AppNavItem(
      label: 'Check-in',
      icon: Icons.qr_code_scanner_outlined,
      path: RoutePaths.checkIn,
    ),
    AppNavItem(
      label: 'Attendance',
      icon: Icons.event_available_outlined,
      path: RoutePaths.attendance,
    ),
    AppNavItem(
      label: 'Members',
      icon: Icons.group_outlined,
      path: RoutePaths.members,
    ),
    AppNavItem(
      label: 'Subscriptions',
      icon: Icons.card_membership_outlined,
      path: RoutePaths.subscriptions,
    ),
    AppNavItem(
      label: 'Payments',
      icon: Icons.payments_outlined,
      path: RoutePaths.payments,
    ),
    AppNavItem(
      label: 'Employees',
      icon: Icons.badge_outlined,
      path: RoutePaths.employees,
    ),
    AppNavItem(
      label: 'Branches',
      icon: Icons.storefront_outlined,
      path: RoutePaths.branches,
    ),
    AppNavItem(
      label: 'Reports',
      icon: Icons.insights_outlined,
      path: RoutePaths.reports,
    ),
    AppNavItem(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      path: RoutePaths.notifications,
    ),
  ]),
  AppNavSection(title: 'System', items: [
    AppNavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      path: RoutePaths.settings,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      path: RoutePaths.profile,
    ),
  ]),
];

/// Resolves the page title for a route location.
String? navTitleForPath(String path) {
  for (final section in appNavSections) {
    for (final item in section.items) {
      if (item.path == path) {
        return item.label;
      }
    }
  }
  return null;
}
