import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';

/// A simple labeled-value row used in member detail cards.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card containing labeled information rows for the member details screen.
class MemberInfoCard extends StatelessWidget {
  const MemberInfoCard({
    super.key,
    required this.title,
    required this.rows,
    this.trailing,
  });

  final String title;

  /// A map of label → value pairs shown as rows inside the card.
  final Map<String, String?> rows;

  /// Optional widget shown in the top-right of the card header.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final visibleRows = rows.entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (visibleRows.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Divider(color: colorScheme.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in visibleRows)
                _InfoRow(label: entry.key, value: entry.value!),
            ],
          ],
        ),
      ),
    );
  }
}
