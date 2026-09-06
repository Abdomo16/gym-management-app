import 'package:flutter/material.dart';

import 'package:gym_management_app/app/theme/app_colors.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';

/// Brand mark: gradient tile + product name.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.showLabel = true});

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brand, AppColors.brandDark],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
    if (!showLabel) {
      return mark;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpacing.sm),
        Text(
          'GymFlow',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
