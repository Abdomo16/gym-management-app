import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/features/dashboard/domain/entities/dashboard_recent_check_in.dart';

class DashboardRecentCheckIns extends StatelessWidget {
  const DashboardRecentCheckIns({super.key, required this.items});

  final List<DashboardRecentCheckIn> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          title: 'No check-ins today',
          message: 'Confirmed check-ins will appear here.',
          icon: Icons.login_outlined,
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _RecentCheckInTile(item: items[index]),
            if (index < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _RecentCheckInTile extends StatelessWidget {
  const _RecentCheckInTile({required this.item});

  final DashboardRecentCheckIn item;

  @override
  Widget build(BuildContext context) {
    final attendance = item.attendance;
    final code = item.memberCode;
    return ListTile(
      onTap: () => context.push(RoutePaths.memberDetail(attendance.memberId)),
      leading: CircleAvatar(
        child: Text(
          item.memberName.isEmpty ? '?' : item.memberName[0].toUpperCase(),
        ),
      ),
      title: Text(item.memberName),
      subtitle: Text(code ?? 'Member'),
      trailing: Text(_formatTime(attendance.checkInAt)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour == 0 || value.hour == 12 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
