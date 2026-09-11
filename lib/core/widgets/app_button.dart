import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

enum AppButtonSize { small, medium, large }

/// Production-grade button with variants, sizes, loading and disabled states.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.busy = false,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool busy;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = !busy && onPressed != null;

    final foreground = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      // Danger keeps white text regardless of the onPrimary ink color.
      AppButtonVariant.danger => colorScheme.onError,
      AppButtonVariant.secondary => colorScheme.onSecondaryContainer,
      AppButtonVariant.outline || AppButtonVariant.text => colorScheme.primary,
    };
    final background = switch (variant) {
      AppButtonVariant.primary => colorScheme.primary,
      AppButtonVariant.secondary => colorScheme.secondaryContainer,
      AppButtonVariant.danger => colorScheme.error,
      AppButtonVariant.outline || AppButtonVariant.text => Colors.transparent,
    };
    final side = variant == AppButtonVariant.outline
        ? BorderSide(color: colorScheme.outline)
        : BorderSide.none;

    final (horizontalPadding, verticalPadding, radius) = switch (size) {
      AppButtonSize.small => (12.0, 6.0, AppSpacing.radiusSm),
      AppButtonSize.medium => (16.0, 10.0, AppSpacing.radiusMd),
      AppButtonSize.large => (24.0, 14.0, AppSpacing.radiusLg),
    };

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }
        return foreground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        return foreground.withValues(alpha: 0.08);
      }),
      side: WidgetStatePropertyAll(side),
      elevation: const WidgetStatePropertyAll(0),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
      minimumSize: WidgetStatePropertyAll(
        expanded
            ? const Size(double.infinity, 0)
            : Size.zero,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      textStyle: WidgetStatePropertyAll(
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    final content = busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.text => TextButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: content,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: content,
      ),
      _ => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: content,
      ),
    };

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
