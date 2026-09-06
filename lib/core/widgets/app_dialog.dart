import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';

/// Pre-styled dialog helpers used across the app.
abstract final class AppDialog {
  /// Shows a generic dialog with a title, content and custom actions.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: actions.isEmpty
              ? null
              : [
                  for (final action in actions)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: action,
                    ),
                ],
        );
      },
    );
  }

  /// Shows a confirmation dialog returning `true`/`false`.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppButtonVariant confirmVariant = AppButtonVariant.primary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            AppButton(
              label: confirmLabel,
              variant: confirmVariant,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
