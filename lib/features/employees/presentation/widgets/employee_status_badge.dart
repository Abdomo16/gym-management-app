import 'package:flutter/material.dart';

import 'package:gym_management_app/core/widgets/status_badge.dart';

class EmployeeStatusBadge extends StatelessWidget {
  const EmployeeStatusBadge({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: isActive ? 'Active' : 'Inactive',
      tone: isActive ? StatusBadgeTone.success : StatusBadgeTone.neutral,
      icon: isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
    );
  }
}
