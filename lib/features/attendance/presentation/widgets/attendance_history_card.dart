import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/features/attendance/domain/entities/attendance.dart';

class AttendanceHistoryCard extends StatelessWidget {
  const AttendanceHistoryCard({
    super.key,
    required this.attendance,
    this.title = 'Attendance',
  });

  final List<Attendance> attendance;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (attendance.isEmpty)
            const AppEmptyState(
              icon: Icons.event_available_outlined,
              title: 'No attendance yet',
              message: 'Check-in records for this member will appear here.',
            )
          else
            for (final (index, record) in attendance.indexed) ...[
              if (index > 0) const Divider(height: AppSpacing.md),
              _AttendanceRow(record: record),
            ],
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record});

  final Attendance record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkInAt = record.checkInAt;
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(record.checkInDay),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTime(checkInAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Checked in',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}