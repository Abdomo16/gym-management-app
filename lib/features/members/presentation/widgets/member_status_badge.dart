import 'package:flutter/material.dart';

import 'package:gym_management_app/core/widgets/status_badge.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

/// Maps a [MemberStatus] to the shared [StatusBadge] widget with the
/// appropriate semantic tone.
class MemberStatusBadge extends StatelessWidget {
  const MemberStatusBadge({super.key, required this.status});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    final (tone, icon) = switch (status) {
      MemberStatus.active => (StatusBadgeTone.success, Icons.check_circle_outline),
      MemberStatus.inactive => (StatusBadgeTone.neutral, Icons.pause_circle_outline),
      MemberStatus.blocked => (StatusBadgeTone.danger, Icons.block_outlined),
    };
    return StatusBadge(label: status.label, tone: tone, icon: icon);
  }
}
