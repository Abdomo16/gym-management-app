import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';

/// Loading indicator, optionally centered and labeled.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label, this.centered = true});

  final String? label;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    return centered ? Center(child: content) : content;
  }
}
